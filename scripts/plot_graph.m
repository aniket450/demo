function plot_graph(test_vector_tc_ID)

to_workspace_blocks = find_system(gcs,'BlockType','ToWorkspace');
load_tv_file_plot =  evalin('base', 'tv_signal_to_plot_base'); %load(testcase_mat_plot.name);
tv_signal_info = fieldnames(load_tv_file_plot);
if length(tv_signal_info) > 1
    tv_signal_plot1 = split(tv_signal_info,'_');  %need to check
else
    tv_signal_plot1 = split(tv_signal_info,'_')';
end
test_case_ID_1 = split(test_vector_tc_ID,'_')';
tv_signal_idx = find(str2double(tv_signal_plot1(:,end)) == str2double(test_case_ID_1(:,end)));
tv_signal_plot = tv_signal_info{tv_signal_idx};
tv_plot_data = load_tv_file_plot.(tv_signal_plot);
tv_input_fieldnames = fieldnames(tv_plot_data);
cd testcase_MAT
testcase_mat_plot = dir(strcat(test_vector_tc_ID,'.mat'));

load_mat_file_plot = load(testcase_mat_plot.name);
input_fieldnames = fieldnames(load_mat_file_plot);
% input_plot_data = load_mat_file_plot.(input_fieldnames);
% input_fieldnames = fieldnames(load_mat_file_plot.(input_fieldnames));
% input_fieldnames = fieldnames(input_plot_data);
cd ..
max_inp_value = max(load_mat_file_plot.(input_fieldnames{1}).signals.values);
textloc_yaxis = max_inp_value;
fig_name = figure('name', 'Input Signal vs Actual Output Signals');
subplot(2,1,1);
hold on;
% color_code = {'r*-','gs','b*-','k*-','m*-','y*-','c*-','rs-','gs-','bs-','ks-','ms-','ys-','cs-'};
color_code = rand(length(input_fieldnames) ,3);
color_code_i = 1;
legend_info_i = 1;
tab_space = ' ';
xmin_in = -0.1;
xmax_in = 0.5;
ymin_in = -0.5;
ymax_in = 0.5;
input_logs =  evalin('base', 'input_logs');
in_signals = fieldnames(input_logs);

for plot_i = 3 : length(tv_input_fieldnames)
    get_plot = tv_plot_data.(tv_input_fieldnames{plot_i});
    if get_plot
        find_signal = strcat('in_',tv_input_fieldnames{plot_i});
        get_signal_idx = find(ismember(in_signals, find_signal),1);
        time_plot = input_logs.(in_signals{get_signal_idx}).Time;
        input_data = input_logs.(in_signals{get_signal_idx}).Data;
%         max_inp_value1 = max(load_mat_file_plot.(input_fieldnames{get_signal_idx}).signals.values);
        %         yyaxis left
        stairs(time_plot,input_data,'Color', color_code(color_code_i,:), 'LineWidth',1);
        %             stairs(time_plot,input_data,color_code{color_code_i});
        xlabel('<--------------------- Time --------------------->');
        ylabel('<---------- Input Signal ------>');
        title('Simulation Time Vs Input Signal');
        
        %         axis([-1 max(time_plot) + 20 -1 (max_inp_value +1000)]);
        %%adding offset for axis for timeplot other than 0
        [xmin_in, xmax_in, ymin_in, ymax_in] = get_ranges(time_plot, input_data, xmin_in, xmax_in, ymin_in, ymax_in);
        
        hold on;
        grid on;
        legend_info{legend_info_i} = tv_input_fieldnames{plot_i};
        legend(legend_info);
        legend show
        color_code_i = color_code_i + 1;
        legend_info_i = legend_info_i + 1;
    end
    
end
axis([xmin_in xmax_in ymin_in ymax_in]);

subplot(2,1,2);
a='out_';
b='_exp';
legend_info_i = 1;
xmin = -0.1;
xmax = 0.5;
ymin = -0.5;
ymax = 0.5;

for plot_i = (length(input_fieldnames) -2) : -1 : 1
    split_in = strsplit((input_fieldnames{plot_i}));
    if strcmp(split_in{1}, 'Parameter')
        break;
    else
        sim_results = evalin('base', 'output_logs');
        out_signals = fieldnames(sim_results);
        for j = 1: length(out_signals)
%             extract_name_toworskspace = get_param(to_workspace_blocks{j}, 'VariableName');
            split_in = strsplit((input_fieldnames{plot_i}),a);
            split_in_name = strsplit(cell2mat(split_in(2)),b);
            split_in = cell2mat(split_in_name(1));
            if strcmp(strcat('out_',out_signals{j}, '_exp'), input_fieldnames{plot_i})
                time_plot_1 = load_mat_file_plot.(input_fieldnames{plot_i}).time;
                %                 time_plot = timeseries_data.Time;
                timeseries_data = sim_results.(out_signals{j}); % access workspace variables
                time_plot = timeseries_data.Time;
                actual_output_plot =  timeseries_data.Data;
                %                 timeseries_time_plot = find(ismember(single(timeseries_data.Time),single(time_plot)));
                %                 actual_output_plot = timeseries_data.Data(timeseries_time_plot);
                %                 yyaxis right
                stairs(time_plot,actual_output_plot,'Color',[color_code(color_code_i,:)], 'LineWidth',1)
                %                     stairs(time_plot,actual_output_plot,color_code{color_code_i});
                xlabel('<--------------------- Time --------------------->');
                ylabel('<---------- Actual Output Signals ------>');
                title('Simulation Time Vs Actual Output Signal');
                %axis([-1 max(time_plot) + 10 min(actual_output_plot) - 2 max(actual_output_plot) + 2])
                
                
                [xmin, xmax, ymin, ymax] = get_ranges(time_plot, actual_output_plot, xmin, xmax, ymin, ymax);
                hold on;
                grid on;
                legend_info_1{legend_info_i} = strcat('out-',split_in);
                legend(legend_info_1);
                legend show
                
                color_code_i = color_code_i + 1;
                legend_info_i = legend_info_i + 1;
                data_str = load_mat_file_plot.(input_fieldnames{plot_i}).signals.values;
                data_time = load_mat_file_plot.(input_fieldnames{plot_i}).time;
                for data_str_i = 2 : length(data_str)
                    string_data = find_validation_type(data_str{data_str_i});
                    if strcmp(string_data.name,'pulse')
                        text_write = [string_data.name,':-' ,split_in,tab_space,'for',tab_space,num2str(string_data.trigger_point),tab_space];
                        text_pro = text(data_time(data_str_i), string_data.trigger_value, text_write);
                        text_pro.HorizontalAlignment = 'left';
                        
                    elseif strcmp(string_data.name,'trigger')
                        text_write = [string_data.name,':-' ,split_in,tab_space,'within',tab_space,num2str(string_data.trigger_point),tab_space];
                        text_pro = text(data_time(data_str_i), string_data.trigger_value, text_write);
                        text_pro.HorizontalAlignment = 'left';
                        
                    elseif  strcmp(string_data.name,'rampup')
                        get_time = find(time_plot == time_plot_1(data_str_i));
                        text_write = [string_data.name,':-' ,split_in,tab_space,'within',tab_space,num2str(string_data.trigger_point),tab_space];
                        text_pro = text((time_plot(get_time) + string_data.trigger_point),(actual_output_plot(get_time) + string_data.trigger_value), text_write);
                        text_pro.HorizontalAlignment = 'left';
                        
                    elseif strcmp(string_data.name,'rampdown')
                        get_time = find(time_plot == time_plot_1(data_str_i));
                        text_write = [string_data.name,':-' ,split_in,tab_space,'within',tab_space,num2str(string_data.trigger_point),tab_space];
                        text_pro = text((time_plot(get_time) + string_data.trigger_point),(actual_output_plot(get_time) - string_data.trigger_value), text_write);
                        text_pro.HorizontalAlignment = 'left';
                        
                    end
                end
                
            end
        end
        axis([xmin xmax ymin ymax]);
    end
end

try
    if ~exist('Graphs', 'dir')
        mkdir Graphs
    end
catch
    mkdir Graphs
end
cd Graphs
saveFigure(num2str(test_vector_tc_ID));
close(gcf);
cd ..

% saveas(h,sprintf('Testcase_testvector_id.png',k))
% savefig('Input_Signal_vs_Actual_Output_Signals');
% log_data_gui = evalin('base','log_data_gui');

% close all;
% openfig('Input_Signal_vs_Actual_Output_Signals', 'reuse');

% pos = get(gcf,'Position');
% width = pos(1,3);
% height = pos(1,4);

% set(gcf,'Position',[ pos(1:2) width height])

% xlsPasteTo(log_data_gui.Testvector_edit.String,test_vector_tc_ID,width,height,fig_name,'Z9');
end