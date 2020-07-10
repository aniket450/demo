function param_updated = check_param_update(parm_str_data)
%%
% created by :      LTTS, Bangalore.

% project name :    Tenneco, Auto division

% Date:             2nd August 2019

% Function Description:
%                   function check_param_update will check if parameter update needed from
%                   test vector,and updates corresponding parameter value in base workspace
%                   from excel sheet for all output signal

% input:            parm_str_data - data from Parameter column in TestVector

% returns:          raw_data - stauts as 1 if updated else 0

%Example:           check_param_update('SignalName1=0.02&SignalName2=12')
%                                       or
%                   check_param_update('Initial_Parameters')
%%

param_updated = 0;

if (~strcmp(parm_str_data, 'Initial_Parameters'))
    param_updated = 1;
    param_list = char(split(parm_str_data,'&'));
    for i = 1 : size(param_list, 1) 
        param_val = regexp(param_list(i, :),'=','split');
        param_base = evalin('base', cell2mat(param_val(1,1)));
        if isa(param_base,'Simulink.Parameter')
            param_base.Value = str2num(param_val{1, 2});
            assignin('base', cell2mat(param_val(1, 1)),param_base);
        else
            param_base = str2num(param_val{1,2});
            assignin('base', cell2mat(param_val(1,1)),param_base);
        end
    end
end
%EOF
