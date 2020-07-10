function clear_contents_excel(test_vector_file_name,test_sheet_name,raw_data,first_tc_row_nbr)
%%
% created by :       LTTS, Bangalore.


% Date:              2nd August 2019

% Function Description:
%                    function clear_contents_excel will clear actual and result column data
%                    from excel sheet for all output signal

% input:             raw_data - raw data from xlsread of test vector

% returns:           raw_data - raw data with cleared expected and result columns

% Example:           clear_contents_excel(raw_data)

%%

 
header_row_nbr = 2;
out_act = '_act';
out_result = '_Result';

fileattrib(test_vector_file_name, '+w');
if ~isempty(raw_data)
    for header_indx = 1 : length(raw_data(header_row_nbr,:))
        header_name = raw_data{header_row_nbr,header_indx};
        if_in_out =(~isempty(regexp(header_name,out_result, 'end'))) || (~isempty(regexp(header_name,out_act, 'end')));
        if if_in_out == 1
            [raw_data{first_tc_row_nbr:end, header_indx}]= deal('');
        else
            %do nothing
        end
    end
     xlswrite(test_vector_file_name, raw_data, test_sheet_name);
end
fileattrib(test_vector_file_name, '-w');
end
%EOF