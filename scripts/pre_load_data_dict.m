function result = pre_load_data_dict()
%%
% created by :        LTTS, Bangalore.


% Date:               2nd August 2019

% Function Description:
%                     function pre_load_data_dict intertacts with all the .sldd/_dd.m files in current matlab workspace
%                     and creates instances of all the variables/parameters in matlab base workspace

% input:              none

% returns:            true if sldd data loaded into base workspace,
%                     false otherwise

% Example:            pre_load_data_dict
%%

extract_sldd = dir('*.sldd');
if ~isempty(extract_sldd)
    extract_info = {extract_sldd.name};
    for i = 1:length(extract_info)
        hDict = Simulink.dd.open((extract_info {i}));
        child_name_list = hDict.getChildNames('Global');
        for n = 1:numel(child_name_list)
            assignin('base',child_name_list{n},hDict.getEntry(['Global.',child_name_list{n}]));
        end
    end
    result = 1;
else
    result = load_dd_mfile();
end
end

function result = load_dd_mfile()

%%
% function load_dd_mfile intertacts with all the _dd.m files in current matlab workspace
% and creates instances of all the variables/parameters into matlab base workspace
% input: none

%%

result= 0;
check_dd_m = dir('*_dd.m');
if ~isempty(check_dd_m)
    [~,check_dd_m_file,~] = fileparts(check_dd_m.name);
    mat_file_dd = strcat(check_dd_m_file,'.mat');
    if(~isempty(dir(mat_file_dd)))
        disp('using existing Data dictionary mat file');
        load_dd = load(mat_file_dd);
    else
        run(check_dd_m_file);
        save(mat_file_dd)
        load_dd = load(mat_file_dd);
    end
    field_dd = fieldnames(load_dd);
    for i = 1 : length(field_dd)
        names_dd = field_dd{i};
        value_dd = load_dd.(names_dd);
        
        assignin('base', names_dd, value_dd);
    end
    result = 1;
end
end
%EOF
