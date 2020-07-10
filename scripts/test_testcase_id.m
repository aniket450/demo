function [testcase_result, signal_result, actual_output] = test_testcase_id(test_id, test_type)
%%
% created by :          LTTS, Bangalore.


% Date:                 2nd August 2019

% Function Description:
%                       function test_testcase_id will execute and validate input test case id
%                       and plot expected vs actual output signals if plot is enabled

% input:                test_case_ID - number value of test case id to be executed and tested.
%                       plot_on - 1 or 0 to enable/disable plot option .
%                       variable arg for tollerance, use default if no value passed


% return :              testcase_result - cumulative result as PASS or FAIL of test case
%                       signal_result - struct of output signal, with PASS or FAIL
%                       status in timeseries
%                       actual_output - struct of output signal, with actual value in
%                       timeseries

% Example:              test_testcase_id(1, 0)
%                                    or
%                      test_testcase_id(2, 1, 0.01)

%%

default_tolerance = 0.0000001;
assignin('base', 'tolerance', default_tolerance);

%clear console and workspace
clc;

%control variables
first_sheet_nbr_in_tv = 2;

% close if any system open in backgorund
try
    close_system();
catch
    save_system();
    close_system();
end

% read different formats of test vector here %
test_vector_file = dir('*_TestVector.xlsx');
if(isempty(test_vector_file))
    test_vector_file = dir('*_TestVector.xlsm');
elseif(isempty(test_vector_file))
    test_vector_file = dir('*_TestVector.xls');
end

% check if file found
if ~isempty(test_vector_file)
    
    % close all test vector file, if found open
    check_and_close_excel_files(test_vector_file);
    
    test_vector_file_name = test_vector_file.name;
    
    % open model %
    if(strcmpi(test_type,'mil'))
        tm_file_name = '*_MIL_Test.slx';
    else
        tm_file_name = '*_SIL_Test.slx';
    end
    % open model %
    model = dir(tm_file_name);
%     model = dir('*_MIL_Test.slx');
%         open_system(model.name);
    load_system(strcat(model.folder, '\', model.name));
    print_logdata(strcat('Opening the test model :', model.name));
    
    % get test vector file info
    [~,sheets,~] = xlsfinfo(test_vector_file_name);
    
    % iterate from sheet 1 till all sheet
%     wait_bar_status = waitbar(0,'Plesae wait');
    for sheet_nbr =  first_sheet_nbr_in_tv : length(sheets)
        
        test_sheet_name = cell2mat(sheets(sheet_nbr));
        
        splitsheetname =  split(test_sheet_name, '_');
        
        if str2double(splitsheetname(end)) == test_id
            
            
            % iterate to create mat file for individual test cases
            create_test_vector_stat = create_testvector_mat(test_vector_file_name,...
                test_sheet_name, 'mil');
            
            mat_data_struct = load_tc_mat_data(test_sheet_name);
            
            if(create_test_vector_stat == 1)
                %[stop_time] = find_stop_time(data);
                simulate_test_case(model, mat_data_struct);
                [testcase_result, signal_result, actual_output]  = validate_testcase(mat_data_struct);
                plot_graph(test_sheet_name);
                print_logdata(strcat('Result of Test case ID - ', num2str(test_id), ' is: --> ', testcase_result));

            else
                error('Test vector creation failed -- Terminating');
            end
%             waitbar(sheet_nbr/length(sheets),wait_bar_status);
        end
    end
    save_system(strcat(model.folder, '\', model.name));
    close_system(strcat(model.folder, '\', model.name));
%     close(wait_bar_status);
else
    warning('No Test Vector Found');
end
% helpdlg('Execution Completed');
end
%%

%%
function mat_data_struct = load_tc_mat_data(test_sheet_name)

cd 'testcase_MAT'
mat_file = dir(strcat(test_sheet_name,'.mat'));

mat_data_struct = load(mat_file.name);
mat_data_struct_name = fieldnames(mat_data_struct);


for i = 1 : numel(mat_data_struct_name)
    assignin('base', mat_data_struct_name{i}, mat_data_struct.(mat_data_struct_name{i}));
end
cd ..
end


%EOF