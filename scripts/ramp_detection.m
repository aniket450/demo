function [signal_result, actual_output] = ramp_detection(signal, sig_incr, start_time, time_range, slope, toll)
%%
% created by :           LTTS, Bangalore.


% Date:                  11th Nov 2019

% Function Description:

%                        function 'ramp_detection' will validate input
%                        signal for rampup or rampdown characteristics
%

% input:
%                        signal - input signal timeseries data
%                        sig_incr - magnetude of signal data that shall
%                        rampup or rampdown
%                        start_time - start time of rampup or rampdown
%                        time_range - expected time range in which rampup
%                        or rampdown shall occure
%                        slope - 1 for rampup & -1 for rampdown

% return :               signal_result - 1 for PASS, 0 for FAIL
%                        actual_output - string states that rampup or
%                        rampdown with magnetude and  endtime.

% Example:              
%%

% function ramp_detection()

% % TC1: rampup
% Data = [1,1, 1:1:10, 10,10];
% Time = [1:14];
% signal = timeseries(Data', Time');
% sig_incr = 9;
% start_time = 1;
% time_range = 13;
% slope = 1;

% % TC2: rampdown
% Data = [10,10, 10:-1:1, 1,1];
% Time = [1:14];
% signal = timeseries(Data', Time');
% sig_incr = 9;
% start_time = 1;
% time_range = 13;
% slope = -1;

% % TC3: rampup fail
% Data = [1,1, 1,10, 10,10];
% Time = [1:6];
% signal = timeseries(Data', Time');
% sig_incr = 9;
% start_time = 1;
% time_range = 5;
% slope = 1;

% % TC4: rampdown fail
% Data = [10,10, 10,1, 1,1];
% Time = [1:6];
% signal = timeseries(Data', Time');
% sig_incr = 9;
% start_time = 1;
% time_range = 5;
% slope = -1;

% % TC5: rampup
% Data = [1:1:10];
% Time = [1:10];
% signal = timeseries(Data', Time');
% sig_incr = 9;
% start_time = 1;
% time_range = 9;
% slope = 1;

% % TC6: rampdown
% Data = [10:-1:1];
% Time = [1:10];
% signal = timeseries(Data', Time');
% sig_incr = 9;
% start_time = 1;
% time_range = 9;
% slope = -1;

% % TC7: rampup fail
% Data = [1:1:10];
% Time = [1:10];
% signal = timeseries(Data', Time');
% sig_incr = 10;
% start_time = 1;
% time_range = 9;
% slope = 1;

% TC8: rampdown fail
% Data = [10:-1:1];
% Time = [1:10];
% signal = timeseries(Data', Time');
% sig_incr = 10;
% start_time = 1;
% time_range = 9;
% slope = -1;

% % TC9: rampup fail
% Data = [1,1,1,1,1,1];
% Time = [1:6];
% signal = timeseries(Data', Time');
% sig_incr = 2;
% start_time = 1;
% time_range = 5;
% slope = 1;


% toll = 0;

signal_array = getsampleusingtime(signal, start_time, start_time + time_range);
check_max = signal_array.Data(1);
count = 0;
start_Time = [];
rampup_break = 0;
start_index = 0;
unit_diff = 0;
total_ramp_data = 0;
for i = 1 : length(signal_array.Data)
    
    if slope > 0
        check_ramp = check_max < signal_array.Data(i);
    else
        check_ramp = check_max > signal_array.Data(i);
    end
        
    if check_ramp
        check_max = signal_array.Data(i);
        if isempty(start_Time)
            start_index = i;
            start_Time = signal_array.Time(i);
        end
        end_index = i;
        end_point_time = signal_array.Time(i);
        flag_set = 1;
        rampup_break = 1;
    else
        if rampup_break == 1
            break;
        end
        flag_set = 0;
    end
    if flag_set == 1
        count = count + 1;
    end
end


if start_index > 0
    unit_diff = abs(signal_array.Data(start_index) - signal_array.Data(start_index-1));
    total_ramp_data = abs(signal_array.Data(end_index) - signal_array.Data(start_index-1));
    
    stauration_data = getsampleusingtime(signal_array, end_point_time, start_time + time_range);
    index = find(ismembertol(double(stauration_data.Data) , double(signal_array.Data(end_index)), (toll*0.1)));
    if length(stauration_data.Data) == length(index)
        saturation_check = 1;
    else
        saturation_check = 0;
    end
else
    saturation_check = 0;
end


if (abs(total_ramp_data - sig_incr) <= toll)...
        && (((abs(unit_diff*count)) - sig_incr) <= toll) && (count > 1) && saturation_check
    signal_result = 1;
    Data = signal_array.Data(end_index);
    Time = signal_array.Time(end_index) - start_time;
    if slope > 0
        actual_output = strcat('rampup(', num2str(total_ramp_data), ', ', num2str(Time), ')');
    else
        actual_output = strcat('rampdown(', num2str(total_ramp_data), ', ', num2str(Time), ')');
    end
else
    signal_result = 0;
    if slope > 0
        actual_output = 'No rampup detected';
    else
        actual_output = 'No rampup detected';
    end
    
end

end