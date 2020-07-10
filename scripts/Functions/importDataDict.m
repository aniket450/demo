function [myParamObj,mySignalObj] = importDataDict(modelName,swcName)

% This function will create a list of output variables and calibratables
% from the data dictionary file associated with the software component
% subsystem given in the "swcName" input variable.  The data dictionary
% file may be either a .sldd type or the Tenneco old style _dd.m type.
%
% Inputs:
%   modelName = the name (char array) or handle (double) of the model
%   swcName (char array) = the name of the software component subsystem
%
% Outputs:
%   myParamObj (cell array) = each cell represents a parameter or
%   calibratable.  Each cell is a structure with the following fields:
%       name = name of the parameter
%       units = engineering units
%       type = data type
%       min = minimum value
%       max = maximum value
%       rate = the sample rate in seconds for the variable.
%       description = description
%       resolution = resolution
%   mySignalObj (cell array) = each cell represents an output variable
%   with each one a structure with the following fields:
%       name = name of the output
%       units = engineering units
%       type = data type
%       min = minimum value
%       max = maximum value
%       description = description
%       resolution = resolution
%
% Dependencies:
%   makeDataObjsFromTENdd
%   TEN.Parameter class
%   TEN.Signal class

% Determine what data file the software component has
hasSlddFile = false;
hasMfile = false;
ddFileName = '';

% Determine if SWC has the DataDictionary parameter (the new style SWC)
swcParams = get_param(swcName,'ObjectParameters');
if isfield(swcParams,'DataDictionary')
    ddFileName = get_param(swcName,'DataDictionary');
    
% or, try model parameter for .sldd file
elseif ~isempty(get_param(modelName,'DataDictionary'))
    ddFileName = get_param(modelName,'DataDictionary');
    
% or, try finding a <swcName>_dd.m file
elseif exist([get_param(swcName,'Name'),'_dd.m'],'file')
    ddFileName = [get_param(swcName,'Name'),'_dd.m'];
    
% or, try finding a <swcName>_dd.sldd file
elseif exist([get_param(swcName,'Name'),'_dd.sldd'],'file')
    ddFileName = [get_param(swcName,'Name'),'_dd.sldd'];
end

% Determine if data dictionary file is simulink .sldd file or .m file
if strfind(ddFileName,'.sldd')
    hasSlddFile = true;
elseif strfind(ddFileName,'.m')
    hasMfile = true;
end

sigObj = {};
paramObj = {};

% Populate the Parameter and Signal object lists if SlddFile exists
if hasSlddFile
    
    % Extract info from dictionary object.
    % Assumes data is Simulink.<type> or TEN.<type>
    myDictionaryObj = Simulink.data.dictionary.open(ddFileName);
    dDataSectObj = getSection(myDictionaryObj,'Design Data');
    
    paramIdx = 1;
    % Check for TEN.Parameter, AUTOSAR.Parameter and then Simulink.Parameter
    searchList = {'TEN.Parameter','Simulink.Parameter','AUTOSAR.Parameter'};
    for listIdx = 1:length(searchList)
        paramEntries = find(dDataSectObj,'-value','-class',searchList{listIdx});
        % Include only those entries in the base data dictionary, no references
        paramEntries = find(paramEntries,'DataSource',ddFileName);
        if ~isempty(paramEntries)
            for idx = 1:length(paramEntries)
                paramObj{paramIdx}.Name = paramEntries(idx).Name;
                paramObj{paramIdx}.Value = getValue(paramEntries(idx));
                paramIdx = paramIdx + 1;
            end
        end
    end
    
    sigIdx = 1;
    % Check for TEN.Signal, AUTOSAR.Signal and then Simulink.Signal
    searchList = {'TEN.Signal', 'Simulink.Signal','AUTOSAR.Signal'};
    for listIdx = 1:length(searchList)
        sigEntries = find(dDataSectObj,'-value','-class',searchList{listIdx});
        % Include only those entries in the base data dictionary, no references
        sigEntries = find(sigEntries,'DataSource',ddFileName);
        if ~isempty(sigEntries)
            for idx = 1:length(sigEntries)
                sigObj{sigIdx}.Name = sigEntries(idx).Name;
                sigObj{sigIdx}.Value = getValue(sigEntries(idx));
                sigIdx = sigIdx + 1;
            end
        end
    end
end

% Populate the Parameter and Signal object lists if Mfile exists
if hasMfile
    % load data from _dd.m file
    dataObjs = makeDataObjsFromTENdd(ddFileName);
    
    % separate into parameter and signal data
    paramIdx = 1;
    sigIdx = 1;
    for idx = 1:length(dataObjs)
        if strcmp(class(dataObjs{idx}.Value),'TEN.Parameter')
            paramObj{paramIdx} = dataObjs{idx};
            paramIdx = paramIdx+1;
        else
            sigObj{sigIdx} = dataObjs{idx};
            sigIdx = sigIdx+1;
        end
    end
end

% Sort lists alphabetically
for idx = 1:length(sigObj)
    sigList{idx} = sigObj{idx}.Name;
end

sortedSigList = sort(sigList);
sortedSigObj = {};

for idx = 1:length(sortedSigList)
    for idy = 1:length(sigObj)
        if strcmp(sortedSigList{idx},sigObj{idy}.Name)
            sortedSigObj{idx} = sigObj{idy};
            break
        end
    end
end
sigObj = sortedSigObj;

for idx = 1:length(paramObj)
    paramList{idx} = paramObj{idx}.Name;
end

sortedParamList = sort(paramList);
sortedParamObj = {};

for idx = 1:length(sortedParamList)
    for idy = 1:length(paramObj)
        if strcmp(sortedParamList{idx},paramObj{idy}.Name)
            sortedParamObj{idx} = paramObj{idy};
            break
        end
    end
end
paramObj = sortedParamObj;

% Create Output data for report generator structure
myParamObj = {};
mySignalObj = {};

if ~isempty(paramObj)
    for idx = 1:length(paramObj)
        myParamObj{idx}.name = paramObj{idx}.Name;
        myParamObj{idx}.units = paramObj{idx}.Value.DocUnits;
        myParamObj{idx}.type = paramObj{idx}.Value.DataType;
        myParamObj{idx}.min = paramObj{idx}.Value.Min;
        myParamObj{idx}.max = paramObj{idx}.Value.Max;
        if strcmp(class(paramObj{idx}.Value),'TEN.Parameter')
            myParamObj{idx}.description = paramObj{idx}.Value.Description;
            myParamObj{idx}.resolution = paramObj{idx}.Value.Res;
        else
            myParamObj{idx}.description = paramObj{idx}.Value.Description;
            myParamObj{idx}.resolution = '[]';
        end
    end
end

if ~isempty(sigObj)
    for idx = 1:length(sigObj)
        mySignalObj{idx}.name = sigObj{idx}.Name;
        mySignalObj{idx}.units = sigObj{idx}.Value.DocUnits;
        mySignalObj{idx}.type = sigObj{idx}.Value.DataType;
        mySignalObj{idx}.min = sigObj{idx}.Value.Min;
        mySignalObj{idx}.max = sigObj{idx}.Value.Max;
        mySignalObj{idx}.rate = sigObj{idx}.Value.SampleTime;
        mySignalObj{idx}.description = sigObj{idx}.Value.Description;
        if strcmp(class(sigObj{idx}.Value),'TEN.Signal')
            mySignalObj{idx}.resolution = sigObj{idx}.Value.Res;
        else
            mySignalObj{idx}.resolution = '[]';
        end
    end
end
