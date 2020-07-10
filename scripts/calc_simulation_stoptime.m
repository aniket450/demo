
function [simulation_stoptime] = calc_simulation_stoptime(mat_data_struct)
simulation_stoptime = [];
offset_time = 0.1;
pat_out_exp = '_exp';
% load_mat_data = load('Pump_1.mat');
field_names_info = fieldnames(mat_data_struct);
% get_inp_out_info = mat_data_struct.(field_names_info{1});
% inp_out_field_names = fieldnames(get_inp_out_info);
stop_time = max(mat_data_struct.(field_names_info{1,1}).time);

for field_i = 1 : length(field_names_info)
    signal_name = field_names_info{field_i};
    if regexp(signal_name, pat_out_exp, 'end')
        extrac_data = mat_data_struct.(signal_name);
        extract_signal = extrac_data.signals.values;
        
        for k = 2 : length(extract_signal)
            [validation_type] = find_validation_type(extract_signal{k});
            
            if validation_type.type ~= 1
                simulation_stoptime1 = validation_type.trigger_point + validation_type.time_period + offset_time;
                simulation_stoptime = [simulation_stoptime simulation_stoptime1];
            else
                simulation_stoptime1 = offset_time;
                simulation_stoptime = [simulation_stoptime simulation_stoptime1];
            end
        end
        
        
    end
end

simulation_stoptime = max(simulation_stoptime);
simulation_stoptime = stop_time + simulation_stoptime;
disp(simulation_stoptime);

end



