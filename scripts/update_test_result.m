function update_test_result(test_vector_file_name,test_sheet_name,signal_result, actual_output,test_type)

% read particular excel sheet from file
fileattrib(test_vector_file_name, '+w');
[~,~,raw_data] = xlsread(test_vector_file_name,test_sheet_name);


header_row = 2;

header_row_data = raw_data(header_row,:);

if(strcmpi(test_type,'mil'))
    str_postfix = '_mil_act';
else
    str_postfix = '_sil_act';
end
out_sig_names = fieldnames(signal_result);
for sig_name_idx =1 : length(out_sig_names)
    first_tc_row = 6;
    pos = strcmp(header_row_data(1:end),strcat('out_',out_sig_names(sig_name_idx),str_postfix));
    col = find(pos);
    for no_of_time_stamps =2: length(actual_output.(out_sig_names{sig_name_idx}))
        raw_data{first_tc_row, col} = actual_output.(out_sig_names{sig_name_idx}){no_of_time_stamps};
        if(signal_result.(out_sig_names{sig_name_idx})(no_of_time_stamps) == 1)
            raw_data{first_tc_row, col+1} = 'PASS';
        elseif(signal_result.(out_sig_names{sig_name_idx})(no_of_time_stamps) == 2)
            raw_data{first_tc_row, col+1} = 'NA';
        else
            raw_data{first_tc_row, col+1} = 'FAIL';
        end
        first_tc_row = first_tc_row+1;
    end
end

xlswrite(test_vector_file_name,raw_data,test_sheet_name);
fileattrib(test_vector_file_name, '-w');
end