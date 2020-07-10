function[signal_result, actual_output] = pulse_detection(signal_array, sig_val, start_time, time_range, pulse_width, toll)
%%
% created by :           LTTS, Bangalore.


% Date:                  11th Nov 2019

% Function Description:

%                        function 'pulse_detection' will validate input
%                        signal for trigger or pulse characteristics
%

% input:
%                        signal_array - input signal timeseries data
%                        sig_val - expected magnetude of pulse
%                        start_time - start time of pulse
%                        time_range - expected time range in which pulse
%                        shall occure
%                        pulse_width - pulse width ('0' for trigger)


% return :               signal_result - 1 for PASS, 0 for FAIL
%                        actual_output - string states that pulse or
%                        trigger with magnetude, pulse time, and pulse
%                        width

% Example:              
%%

% function[signal_result, actual_output] = pulse_detection()

% %TC1: trigger pass
% Data = [0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0];
% Time = [1:18];
% signal_array = timeseries(Data', Time');
% sig_val = 1;
% start_time = 1;
% time_range = 12;
% pulse_width = 0;

% %TC2: trigger fail 
% Data = [0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0];
% Time = [1:18];
% signal_array = timeseries(Data', Time');
% sig_val = 1;
% start_time = 1;
% time_range = 13;
% pulse_width = 0;

% %TC3: trigger fail
% Data = [1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0];
% Time = [1:18];
% signal_array = timeseries(Data', Time');
% sig_val = 1;
% start_time = 1;
% time_range = 12;
% pulse_width = 0;

% %TC4: pulse pass
% Data = [0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0];
% Time = [1:18];
% signal_array = timeseries(Data', Time');
% sig_val = 1;
% start_time = 1;
% time_range = 14;
% pulse_width = 4;

% %TC5: pulse fail
% Data = [0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0];
% Time = [1:18];
% signal_array = timeseries(Data', Time');
% sig_val = 1;
% start_time = 1;
% time_range = 12;
% pulse_width = 4;

% %TC6: pulse fail
% Data = [1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0];
% Time = [1:18];
% signal_array = timeseries(Data', Time');
% sig_val = 1;
% start_time = 1;
% time_range = 14;
% pulse_width = 12;

%TC7: pulse fail
% Data = [0,1,1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0];
% Time = [1:18];
% signal_array = timeseries(Data', Time');
% sig_val = 1;
% start_time = 1;
% time_range = 14;
% pulse_width = 4;


% toll =0;


signal_data = getsampleusingtime(signal_array, start_time, start_time+time_range);
reslt_index = find(ismembertol(double(signal_data.Data), sig_val, (toll*0.1)));
if ~isempty(reslt_index)
    pulse_pos = reslt_index(1);
    start_val = double(signal_data.Data(1));
    base_width = pulse_pos - 1;
    if base_width > 0
        base_data = getsampleusingtime(signal_data, signal_data.Time(1), signal_data.Time(base_width));
        index_basedata = find(ismembertol(double(base_data.Data), start_val, (toll*0.1)));
        if length(index_basedata) == length(base_data.Data)
            base_check = 1;
        else
            base_check = 0;
        end
    else
        base_check = 0;
    end
    if(base_check)
        if pulse_width > 0
            end_time = signal_data.Time(pulse_pos-1) + pulse_width;
            pulse_width_data = getsampleusingtime(signal_data, signal_data.Time(pulse_pos), end_time);
            pulse_index = find(ismembertol(double(pulse_width_data.Data), sig_val, (toll*0.1)));
            tail_data = double(signal_data.Data((length(pulse_width_data.Data) + base_width + 1):end));
            tail_index = find(ismembertol(tail_data, start_val, (toll*0.1)));
            if ~isempty(tail_index)
                if length(pulse_width_data.Data) == length(pulse_index) && length(tail_data) == length(tail_index)
                    pulse_check = 1;
                else
                    pulse_check = 0;
                end
            else
                pulse_check = 0;
            end
        else
            end_time = start_time + time_range;
            pulse_width_data = getsampleusingtime(signal_data, signal_data.Time(pulse_pos), end_time);
            pulse_index = find(ismembertol(double(pulse_width_data.Data), sig_val, (toll*0.1)));
            if length(pulse_width_data.Data) == length(pulse_index)
                pulse_check = 1;
            else
                pulse_check = 0;
            end
        end
    else
        pulse_check = 0;
    end
else
    pulse_check = 0;
    base_check = 0;
end

if pulse_check == 1 && base_check == 1
    signal_result = 1;
    Value = signal_data.Data(pulse_pos);
    time = signal_data.Time(pulse_pos) - start_time; 
    if pulse_width == 0
        actual_output = strcat('trigger(', num2str(Value), ', ', num2str(time), ')');
    else
        actual_output = strcat('pulse(', num2str(Value), ', ', num2str(time+pulse_width), ',', num2str(pulse_width), ')');
    end
else
    signal_result = 0;
    if pulse_width == 0
        actual_output = 'No trigger detected';
    else
        actual_output = 'No pulse detected';
    end
end
% figure;
% plot(signal_data.Time, signal_data.Data);
end
