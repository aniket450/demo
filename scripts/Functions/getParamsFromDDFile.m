function paramData = getParamsFromDDFile(fileName)

% This function is similar to the importDataDict function, but has a
% filename as the input and only outputs the parameter objects.
%
% Inputs:
%   fileName (string) = data dictionary file name.  Can be either  .sldd
%   type or .m file.
%
% Outputs:
%   paramData (cell array) = each cell represents a parameter or
%   calibratable.  Each cell is a structure with the following fields:
%       name = name of the parameter
%       units = engineering units
%       type = data type
%       min = minimum value
%       max = maximum value
%       rate = the sample rate in seconds for the variable.
%       description = description
%       resolution = resolution
%
% Dependencies:
%   Ten.Parameter class

% Determine what data file the software component has
hasSlddFile = false;
hasMfile = false;

% Determine if data dictionary file is simulink .sldd file or .m file
if strfind(fileName,'.sldd')
    hasSlddFile = true;
elseif strfind(fileName,'.m')
    hasMfile = true;
end

paramObjs = {};

% Populate the Parameter list if SlddFile exists
if hasSlddFile
    
    % Extract info from dictionary object.
    % Assumes data is Simulink.<type> or TEN.<type>
    myDictionaryObj = Simulink.data.dictionary.open(fileName);
    dDataSectObj = getSection(myDictionaryObj,'Design Data');
    
    paramIdx = 1;
    % Check for TEN.Parameter and then Simulink.Parameter
    searchList = {'TEN.Parameter','Simulink.Parameter'};
    for listIdx = 1:length(searchList)
        paramEntries = find(dDataSectObj,'-value','-class',searchList{listIdx});
        if ~isempty(paramEntries)
            for idx = 1:length(paramEntries)
                paramObjs{paramIdx}.Name = paramEntries(idx).Name;
                paramObjs{paramIdx}.Value = getValue(paramEntries(idx));
                paramIdx = paramIdx + 1;
            end
        end
    end
    
end

% Populate the Parameter and Signal object lists if Mfile exists
if hasMfile
    % load data from _dd.m file
    dataObjs = makeDataObjsFromTENdd(fileName);
    
    % extract parameter data
    paramIdx = 1;
    for idx = 1:length(dataObjs)
        if strcmp(class(dataObjs{idx}.Value),'TEN.Parameter')
            paramObjs{paramIdx} = dataObjs{idx};
            paramIdx = paramIdx+1;
        end
    end
end

% Create Output data
paramData = {};

if ~isempty(paramObjs)
    for idx = 1:length(paramObjs)
        paramData{idx}.name = paramObjs{idx}.Name;
        paramData{idx}.units = paramObjs{idx}.Value.DocUnits;
        paramData{idx}.type = paramObjs{idx}.Value.DataType;
        paramData{idx}.min = paramObjs{idx}.Value.Min;
        paramData{idx}.max = paramObjs{idx}.Value.Max;
        if strcmp(class(paramObjs{idx}.Value),'TEN.Parameter')
            paramData{idx}.description = paramObjs{idx}.Value.A2L_Description;
            paramData{idx}.resolution = paramObjs{idx}.Value.Res;
        else
            paramData{idx}.description = paramObjs{idx}.Value.Description;
            paramData{idx}.resolution = '[]';
        end
    end
end