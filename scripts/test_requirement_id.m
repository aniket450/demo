function[result_reqID, result_tcID] = test_requirement_id(req_nbr, test_type)
%%
% created by :         LTTS, Bangalore.


% Date:                2nd August 2019

% Function Description:
%                      function test_requirement_id executes all the test cases mapped to
%                      req_nbr in test_plan excel sheet

% input:               req_nbr - req number to be tested
%                      plot_on- plots result if set 1
%                      variable arg for tollerance, use default if no value passed

% returns:             result_reqID - cumulative result of test executed for req
%                      result_tcID - result of each test case id, mapped to req_nbr

% Example:             test_requirement_id(1, 0)
%                                    or
%                      test_requirement_id(2, 1, 0.01)

%%

clc;
% close all;

%%

tab_space2 = '        ';


% if (nargin == 2)
%     arg1 = varargin{1,1};
%     if (isnumeric(arg1))
%         tolerance =  arg1;
%         assignin('base','tolerance',tolerance);
%         print_logdata(strcat('Using tollerence value from user input as :', num2str(tolerance)));
%     end
% else
print_logdata(strcat('Using signals resolutions as tolerance'));
% end




test_plan_file = dir('*_TestPlan.xls');
if(isempty(test_plan_file))
    test_plan_file = dir('*_TestPlan.xlsx');
end

% close all plots
% close all;
if ~isempty(test_plan_file)
    tracebility_sheet = 'Traceability';
    [~,~,raw_data] = xlsread(test_plan_file.name,tracebility_sheet);
    test_case_size = raw_data(3:end,1);
    req_list = raw_data(2,2:end);
    
    % check if req is valid
    req_id_valid = 0;
    for i = 1 : length(req_list)
        split_req_id = split(req_list{i},'.');
        if (str2double(split_req_id(end,1)) == req_nbr)
            req_id_valid = 1;
            break;
        end
    end
    try
    if req_id_valid
        for req_nbr_size = 1 : length(req_list)
            req_nbr_i = split(req_list(req_nbr_size),'.');
            if(str2double(req_nbr_i(3)) == req_nbr)
                i =1;
                test_case_ID = 0;
                test_case_ID = cell(test_case_ID);
                for testcase_size = 1: length(test_case_size)
                    if(cell2mat(raw_data(testcase_size+2,req_nbr_size+1)) == 'X')
                        test_case_ID(i)= raw_data(testcase_size+2,1);
                        i = i+1;
                    end
                end
                test_case_ID = test_case_ID';
                break
            end
        end
        
        
        
        %   simulate the model and get results for identified testcases
        if ~isempty(test_case_ID)
            for tc_id = 1 : length(test_case_ID)
                tc_id_name = split(test_case_ID(tc_id), '_');
                [result_testcase, results_signals, ~] = test_testcase_id(str2double(tc_id_name(length(tc_id_name))), test_type);
                result{tc_id} = result_testcase;
                result_tcID.(test_case_ID{tc_id}) = results_signals;
            end
            fail_Index = strfind(result, 'FAIL');
            
            if cell2mat(fail_Index)
                result_reqID = 'FAIL';
            else
                result_reqID = 'PASS';
            end
            print_logdata(strcat('Result of Requirement ID - ', num2str(req_nbr),' is :--> ', result_reqID));
        else
            error('No Testcase_ID mapped to Requiremet_ID_%d \n', req_nbr)
        end
    else
        print_logdata('----------------------------------------------------------')
        error('Requirement ID is not found');
    end
    catch
        print_logdata('Update the "Traceability" sheet as per the format');
    end
else
    print_logdata('----------------------------------------------------------')
    error('Test Plan file is not found');
    
end
end
%EOF