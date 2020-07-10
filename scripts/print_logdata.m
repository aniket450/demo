
function print_logdata(input_args2, varargin)
%%
%print_logdata Summary of this function goes here
%   Detailed explanation goes here

% input_args1 - having GUI data. examples editbox, pushbutton info, etc
% to access log data edit box use: input_args1.Logdata_edit
% input_args1 : message data

%%
try
input_args1 = evalin('base','log_data_gui');

if (nargin > 1)
    if(~isnumeric(varargin{1,1}))
        if(strcmp(varargin{1,1},'clear_log'))
            set(input_args1.Logdata_edit,'String',''); 
        end
    end
end
old_msg = get(input_args1.Logdata_edit,'String');
old_msg1 = string(old_msg);
old_msg1 = sprintf('%s\n', old_msg1);
old_msg1 = string(old_msg1);
new_msg = string(input_args2);
new_msg = sprintf('%s\n', new_msg);
new_msg = string(new_msg);
% oldmsg = insertBefore(da1, d11);
log_msg = strcat(new_msg, old_msg1);

set(input_args1.Logdata_edit,'String',log_msg);
% uicontrol(input_args1.Logdata_edit)

% jhText1 = findjobj(input_args1.Logdata_edit);
% jhText1.setCaretPosition(jhText1.getDocument.getLength);
catch
    fprintf(input_args2);
end
end
