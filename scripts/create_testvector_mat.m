function result = create_testvector_mat(test_vector_file_name,test_sheet_name,test_type)
%%
% created by :        LTTS, Bangalore.


% Date:               2nd August 2019

% Function Description:
%                     function create_testvector_mat creates a "test_sheet_name"_TestVector.mat
%                     file with timeseries data for input signals, expected output and
%                     parameter data, that can be used to
%                     simulate the model (_MILTest.slx) in the current workspace.

% input:              Test vector file name
%                     Test sheet name

% return :            True if mat file created successfully,
%                     False otherwise

% Example:            create_testvector_mat('test_vector_file_name', 'test_sheet_name')
%%

%init status
result = 0;

% naming convention used for input, output, expected output in testvector
% sheet
in_pat = 'in_';
out_pat = 'out_';
out_exp = '_exp';



%%
%%To create the mat file in the name of the model
model = dir('*.slx');
[row_tc,~] = size(model);
if (row_tc > 1)
    model = model(1);
    model.name = split(model.name,'.');
    model.name = model.name(1);
    assignin('base','model_name',model.name);
    main_struct_name = evalin('base', 'model_name');
    main_struct_name = char(main_struct_name);
else
    main_struct_name = evalin('base', 'model_name');
end

%%
Resolution_row = 4;
first_tc_row_nbr = 5;
ts_col_nbr = 2;
test_case_id_col_nbr =1;
header_row_nbr = 2;
testability_column_start = 3;
tab_space2 = '        ';
testvector_Changed = 1;

try
    if ~exist('testcase_MAT', 'dir')
        mkdir testcase_MAT
    end
catch
    mkdir testcase_MAT
end

% read particular excel sheet from file
[~,~,raw_data] = xlsread(test_vector_file_name,test_sheet_name);

[validation_type, tolerance] = get_tolerance(raw_data);
% validation_type = 2;
% tolerance = evalin('base', 'tolerance');

if validation_type == 2
    first_tc_row_nbr = 4;
end

%clear content when running for MIL test, not for SIL or other sequence of
%tests
if(strcmpi(test_type,'mil'))
    clear_contents_excel(test_vector_file_name,test_sheet_name,raw_data, first_tc_row_nbr);
end

is_testable = raw_data(first_tc_row_nbr:end, testability_column_start);
if find(cellfun('isclass',is_testable,'double'))
    error('The Testability column of Test Vector should not have empty cells');
end

testable_tc = find(ismember(is_testable, 'YES'));
if testvector_Changed == 1
    if(~isempty(raw_data))
        for header_indx = 1 : length(raw_data(header_row_nbr,:))
            header_name = raw_data{header_row_nbr,header_indx};
            
            % check if it is a input or expected output or parameter column!
            if_mat_data_col = ~isempty((regexp(header_name,in_pat, 'start'))) ||  ...
                (~isempty(regexp(header_name,out_pat, 'start')) && ~isempty(regexp(header_name,out_exp, 'end'))) ||...
                (strcmp(header_name,'Parameter'));
            
            mat_element_name = header_name;
            
            % if signal is input or expected output or parameter, include it in mat file
            if if_mat_data_col
                data.time = raw_data(testable_tc+(first_tc_row_nbr -1),ts_col_nbr);
                data.time = cell2mat(data.time);
                data.signals.values = raw_data(testable_tc+(first_tc_row_nbr -1),header_indx);
                if validation_type == 1
                    data.signals.resolution = raw_data(Resolution_row,header_indx);
                    data.signals.resolution = cell2mat(data.signals.resolution);
                else
                    data.signals.resolution = tolerance;
                end
                
                % if parameter, use as a string, else convert to mat data
                if(strcmp(header_name,'Parameter'))
                    data_signals_values = data.signals.values;
                    check_nan = find(cellfun('isclass',data_signals_values,'double'), 1);
                    if  ~isempty(check_nan)
                        if find(isnan(data_signals_values{check_nan}))
                            error('The Parameter update column in Test Vector should not have empty cells');
                        end
                    end
                elseif(strcmp(header_name,'Testability'))
                    data_signals_values = data.signals.values;
                    check_nan = find(cellfun('isclass',data_signals_values,'double'), 1);
                    if  ~isempty(check_nan)
                        if find(isnan(data_signals_values))
                            error('The Testability column of Test Vector should not have empty cells');
                        end
                    end
                    
                else
                    find_X = ~isempty((regexp(header_name,out_pat,'start')));
                    if ~find_X
                        
                        data.signals.values = cell2mat(data.signals.values);
                        if find(isnan(data.signals.values))
                            error('Testable TestCases data should be NON-empty cells');
                        elseif find(isnan(data.time))
                            error('Testable TestCases data should be NON-empty cells');
                        end
                    end
                end
                
                data.signals.dimensions = 1;
                disp(strcat(tab_space2,'updating mat file with Signal :', mat_element_name));
                s.(mat_element_name) = mat_element_name;
                s.(mat_element_name) = data;
            end
        end
        
        % create a structure with ts and test case IDs from 1st col
        s.test_case_ids.time = raw_data(testable_tc+(first_tc_row_nbr -1),ts_col_nbr);
        s.test_case_ids.test_case_id = raw_data(testable_tc+(first_tc_row_nbr -1),test_case_id_col_nbr);
        
        s.(main_struct_name) = s;
        %%
        %         file_to_save = strcat('Pump','_TestVector');
        disp(strcat(tab_space2,'creating a master test vector in current dir :', main_struct_name,'_TestVector'));
        
        cd testcase_MAT
        s = scaling_offset_correction(s);
        
        save(test_sheet_name,'-struct','s');
        
        result = 1;
        load_old_data = load(test_sheet_name);
        names = fieldnames(load_old_data);
        for i = 1:numel(names)
            assignin('base', names{i}, load_old_data.(names{i}));
        end
        
    else
        disp(tab_space2,'No test vector/Test sheet found');
    end
end
cd ..
end

function [mat_file] = scaling_offset_correction(mat_file)

interface = evalin('base','interface');
interface_names = fieldnames(interface);

mat_file_name = fieldnames(mat_file);
for i=1:length(interface_names)
    
    for j=1:length(mat_file_name)
        
        signal_name_mat = split((mat_file_name{j}),'_');
        if(length(signal_name_mat)> 1 && strcmp(signal_name_mat{1},'in'))
            if(strcmp(interface_names{i},signal_name_mat{2}))
                mat_file.(mat_file_name{j}).signals.values =  (mat_file.(mat_file_name{j}).signals.values *...
                    interface.(interface_names{i}).scalling) + interface.(interface_names{i}).offset;
            end
        end
    end
    
end
end
%EOF

