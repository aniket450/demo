function simulate_test_case(model,mat_data_struct)

warning off;
tab_space2 =' ';
% cd 'testcase_MAT'
% 
% mat_file = dir(strcat(test_sheet_name,'.mat'));
% 

in_struct_name = fieldnames(mat_data_struct);
% in_struct = mat_data_struct.(in_struct_name{1,1})

for i = 1 : numel(in_struct_name)
    assignin('base', in_struct_name{i}, mat_data_struct.(in_struct_name{i}));
end

% cd ..
% pre load dd data into base workspace before model simulation %
% fprintf(strcat(tab_space2,'Execute pre_load_data_dict function'));
fprintf(strcat(tab_space2,'Execute pre_load_data_dict function'));
pre_load_data_dict();
param_inst = evalin('base','Parameter');
fprintf(strcat(tab_space2,'Execute check_param_update function'));
param_updated = check_param_update(param_inst.signals.values{2,1});

% signal_names = fieldnames(mat_data_struct);
[simulation_stoptime] = calc_simulation_stoptime(mat_data_struct);

set_param(bdroot,'StopTime',num2str(simulation_stoptime));
fprintf(strcat(tab_space2,'simulate system :',model.name));
save_system(model.name)
sim(model.name)

%get simulated inputs
in_signals = logsout.getElementNames;
for i = 1 : length(in_signals)
    split_signalname = split(in_signals{i}, '_');
    if strcmp(split_signalname(1), 'in')
        input_logs.(in_signals{i}) = logsout.getElement(i).Values;
    else
        %donothing
    end
end
assignin('base', 'input_logs', input_logs);

%save system
save_system(model.name)

% if parameter updated happened, then reset parameters to default %
% if(param_updated)
%     fprintf(strcat(tab_space2,'Execute pre_load_data_dict function, since parameter updated'));
%     pre_load_data_dict();
% end

to_workspace_blocks = find_system(gcs,'BlockType','ToWorkspace');
for j = 1: length(to_workspace_blocks)
    extract_name_toworskspace = get_param(to_workspace_blocks{j}, 'VariableName');
    g = eval(extract_name_toworskspace);
    output_logs.(extract_name_toworskspace) = g;
end

assignin('base', 'output_logs', output_logs);
end

%EOF