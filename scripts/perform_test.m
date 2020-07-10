function perform_test(test_type, varargin)


if nargin == 2
    caller = varargin;
else
    caller = 'CI';
end

tolerance = 0.0000001;
assignin('base', 'tolerance', tolerance);

%clear console and workspace
clc;
if exist ('Graphs', 'dir')
    rmdir('Graphs', 's')
end

% close if any system open in backgorund
try
    close_system();
catch
    save_system();
    close_system();
end

%control variables
first_sheet_nbr_in_tv = 2;

% read different formats of test vector here %
test_vector_file = dir('*_TestVector.xlsx');
if(isempty(test_vector_file))
    test_vector_file = dir('*_TestVector.xlsm');
elseif(isempty(test_vector_file))
    test_vector_file = dir('*_TestVector.xls');
end

auto_gen_sim_log_name = 'Auto_gen_simulation_log.xlsx';

% check if file found
if ~isempty(test_vector_file)
    
    % close all test vector file, if found open
    check_and_close_excel_files(test_vector_file);
    
    test_vector_file_name = test_vector_file.name;
    
    if(strcmpi(test_type,'mil'))
        tm_file_name = '*_MIL_Test.slx';
    else
        tm_file_name = '*_SIL_Test.slx';
    end
    % open model %
    model = dir(tm_file_name);
    %open_system(model.name);
    load_system(model.name);
    print_logdata(strcat('Loading the test model :', model.name));
    
    % get test vector file info
    [~,sheets,~] = xlsfinfo(test_vector_file_name);
    
    % iterate from sheet 1 till all sheet
    if strcmp(caller, 'GUI')
        wait_bar_status = waitbar(0, 'Plesae wait...Executing Test cases');
    end
    for sheet_nbr =  first_sheet_nbr_in_tv : length(sheets)
         print_logdata(strcat('Executing the test case ID : ', num2str(sheet_nbr - 1)));
        
        test_sheet_name = cell2mat(sheets(sheet_nbr));
        
        if(strcmp(test_type, 'sil') && strcmp(caller, 'CI'))
            create_test_vector_stat = 1;
        else
            %ToDo iterate to create mat file for individual test cases
            create_test_vector_stat = create_testvector_mat(test_vector_file_name,...
                test_sheet_name,test_type);
        end
        mat_data_struct = load_tc_mat_data(test_sheet_name);
        
        if(create_test_vector_stat == 1)
            %[stop_time] = find_stop_time(data);
            simulate_test_case(model, mat_data_struct);
            [testcase_result, signal_result, actual_output]  = validate_testcase(mat_data_struct);
            if strcmp(caller, 'GUI')
                plot_graph(test_sheet_name);
            end
            update_test_result(test_vector_file_name,test_sheet_name,signal_result, actual_output,test_type);
            if(strcmpi(test_type,'mil'))
                create_simulation_log(auto_gen_sim_log_name, test_sheet_name);
            end
        else
            print_logdata('Test vector creation failed -- Terminating');
            error('Test vector creation failed -- Terminating');
        end
        if strcmp(caller, 'GUI')
            waitbar(sheet_nbr/length(sheets),wait_bar_status);
        end
    end
    if strcmp(caller, 'GUI')
        close(wait_bar_status);
    end
else
    %warning('No Test Vector Found');
    print_logdata('No Test Vector Found');
    error('No Test Vector Found');
end
if strcmp(caller, 'GUI')
    helpdlg('Execution Completed');
end
save_system(model.name);
close_system(model.name);
print_logdata(strcat('Cumulative Test Execution Completed for - ', test_type, '. Please refer the Test Vector for test results.'));
end
%%

%%
function mat_data_struct = load_tc_mat_data(test_sheet_name)

mat_file = dir(strcat('testcase_MAT\',test_sheet_name,'.mat'));

mat_data_struct = load(fullfile(mat_file.folder,mat_file.name));
mat_data_struct_name = fieldnames(mat_data_struct);


for i = 1 : numel(mat_data_struct_name)
    assignin('base', mat_data_struct_name{i}, mat_data_struct.(mat_data_struct_name{i}));
end

end
%%
%EOF