function [validation_type, tolerance] = get_tolerance(raw_data_temp)
%%
% created by :      LTTS, Bangalore.

% project name :    Tenneco, Auto division

% Date:             2nd August 2019

% input :           raw_data_temp (raw data of test vector)

% output:           Validation_type- 1 if tolerance as output signal's resolution
%                   tolerance - tolerance value(s)

% Function Description:
%                    fucntion get_tolerance.m find the tolerance value as
%                    resultion of output signals if Resolution row exists
%                    in test vector else it consider the user input
%                    tolerance value.

% Example:           [validation_type, tolerance] = get_tolerance(raw_data_temp)
%%

Resolution_row = 4;
header_row_nbr = 2;
out_pat = 'out_';
out_exp = '_exp';
fprintf('before strcmp');
resolution_row = strcmp(raw_data_temp(Resolution_row, 1), 'Resolution');
fprintf('after strcmp');
if resolution_row
    validation_type = 1;
    
    for header_idx = 1 : length(raw_data_temp(header_row_nbr,:))
       header_name = raw_data_temp{header_row_nbr, header_idx}; 
       if_mat_data_col = (~isempty(regexp(header_name,out_pat, 'start')) && ~isempty(regexp(header_name,out_exp, 'end')));
         if if_mat_data_col
             tolerance.(header_name) = cell2mat(raw_data_temp(Resolution_row, header_idx));
         end
             
    end
    
else
    validation_type = 2;
    tolerance = evalin('base', 'tolerance');
    
end

end