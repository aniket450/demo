function create_simulation_log(file_name, sheet_name)

try
fileattrib(file_name, '+w');
catch
disp('')
end
input_logs =  evalin('base', 'input_logs');
in_signals = fieldnames(input_logs);

output_logs = evalin('base', 'output_logs');
out_signals = fieldnames(output_logs);

header1 = {'Time'};
data1 = single(input_logs.(in_signals{1}).Time); %common time for all signals 
for in_signal = 1 : length(in_signals)
    input_data = input_logs.(in_signals{in_signal}).Data;
    header1{end + 1} = in_signals{in_signal};
    data1 = [ data1, single(input_data)];
     
end

for out_sig = 1 : length(out_signals)
    output_data = output_logs.(out_signals{out_sig}).Data;
    header1{end + 1} = out_signals{out_sig};
    data1 = [ data1, single(output_data)];
end
xlswrite(file_name, [header1; num2cell(data1)], sheet_name); 
fileattrib(file_name, '-w');
end