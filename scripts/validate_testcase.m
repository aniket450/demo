function [testcase_result, signal_result, actual_output]  = validate_testcase(expected_results)
%%
% created by :           LTTS, Bangalore.


% Date:                  11th Nov 2019

% Function Description:
%                        function 'validate_testcase' will validate input test case id

% input:
%                        expected_results - expected output struct data.

% return :               testcase_result - cumulative result as PASS or
%                                          FAIL of all signals of test case id
%                        signal_result - struct of output signal, with PASS or FAIL
%                        status in timeseries
%                        actual_output - struct of output signal, with
%                        actual value or characteristics of signal data.

% Example:              validate_testcase(expected_results)

%%

% search for all to workspace block fromk model, and extract result from
% the workspace dynamically
% to_workspace_blocks = find_system(gcs,'BlockType','ToWorkspace');
% for j = 1: length(to_workspace_blocks)
%     extract_name_toworskspace = get_param(to_workspace_blocks{j}, 'VariableName');
%     timeseries_data = evalin('base',extract_name_toworskspace);
%     sim_results.(extract_name_toworskspace) = timeseries_data;
%     
% end

sim_results = evalin('base', 'output_logs');

out_pat = 'out';
header_name = fieldnames(expected_results);
sim_names = fieldnames(sim_results);
n = 0;
result = 0;

for i = 1 : length(header_name)
    signal_name = split(header_name(i),'_');
    
    if strcmp(signal_name(1),out_pat)
        
        for k = 1 : length(sim_names)
            
            if strcmp(header_name(i), (strcat('out_',sim_names(k),'_exp')))
                n = n + 1;
                expected_out_results.(sim_names{k}) = expected_results.(header_name{i});
                time_stamps = single(expected_out_results.(sim_names{k}).time(1:end));
                for m = 2:length(time_stamps)
                    
                    [validation_type] = find_validation_type(num2str(expected_out_results.(sim_names{k}).signals.values{m}));
                    
                    if validation_type.type == 1
                        % validation of simulation output w.r.t specific
                        % expected value (with tolerance) at specific timestamp
                        
                        find_index = find(ismember(single(sim_results.(sim_names{k}).Time), time_stamps(m)));
                        actual_output.(sim_names{k}){m} = double(sim_results.(sim_names{k}).Data(find_index));
                        difference = double(sim_results.(sim_names{k}).Data(find_index)) - expected_out_results.(sim_names{k}).signals.values{m};
                        rslt = (abs(difference) < expected_out_results.(sim_names{k}).signals.resolution);
                        if rslt
                            signal_result.(sim_names{k})(m) = 1;
                        else
                            signal_result.(sim_names{k})(m) = 0;
                        end
                        
                    elseif validation_type.type == 2
                        % validation of  simulated output w.r.t. specific
                        % expected value (with tolerance) at any timestamp
                        % within the time range given.
                        [signal_result_1, actual_output_1] = pulse_detection(sim_results.(sim_names{k}), validation_type.trigger_value, ...
                           time_stamps(m), validation_type.trigger_point, 0, expected_out_results.(sim_names{k}).signals.resolution);
                        
                        signal_result.(sim_names{k})(m) = signal_result_1;
                        actual_output.(sim_names{k}){m} = actual_output_1;
                        
                        
                    elseif validation_type.type == 3
                        % validation of  simulated output w.r.t. specific
                        % expected value (with tolerance)for specific time period, signal activation at any timestamp
                        % within the time range given.
                        
                        [signal_result_1, actual_output_1] = pulse_detection(sim_results.(sim_names{k}), validation_type.trigger_value, ...
                             time_stamps(m), validation_type.trigger_point, validation_type.time_period, expected_out_results.(sim_names{k}).signals.resolution);
                        
                        
                        signal_result.(sim_names{k})(m) = signal_result_1;
                        actual_output.(sim_names{k}){m} = actual_output_1;
                        
                    elseif validation_type.type == 4
                        % validation for ramp up characteristics
                        
                        [signal_result_1, actual_output_1] = ramp_detection(sim_results.(sim_names{k}), validation_type.trigger_value, ...
                             time_stamps(m), validation_type.trigger_point, 1, expected_out_results.(sim_names{k}).signals.resolution);
                        
                        signal_result.(sim_names{k})(m) = signal_result_1;
                        actual_output.(sim_names{k}){m} = actual_output_1;
                        
                        
                    elseif validation_type.type == 5
                        % validation for ramp down characteristics
                        
                        [signal_result_1, actual_output_1] = ramp_detection(sim_results.(sim_names{k}), validation_type.trigger_value, ...
                            time_stamps(m), validation_type.trigger_point, -1, expected_out_results.(sim_names{k}).signals.resolution);
                        
                        signal_result.(sim_names{k})(m) = signal_result_1;
                        actual_output.(sim_names{k}){m} = actual_output_1;
                        
                    elseif validation_type.type == 6
                        signal_result.(sim_names{k})(m) = 2;
                        actual_output.(sim_names{k}){m} = 'NA';
                        
                        
                    end
                end
                check_reslt_pass = ismember(signal_result.(sim_names{k})(2:end), 1);
                if check_reslt_pass
                    result(n) = 1;
                else
                    result(n) = 0;
                end
            end
        end
    end
    
end
if result
    
    testcase_result = 'PASS';
else
    testcase_result = 'FAIL';
end
end



