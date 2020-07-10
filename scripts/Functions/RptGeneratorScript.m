% Tenneco Report Generator Script. 
%
% Calling This script is the first thing the TEN_MBDD_AutoReportGen routine
% will do.  This script will create a structure, "mbdd," in the base
% workspace which contains information about the model to be reported on.
%
% Dependencies:
%   parseRevisionHistory
%   getHierachyChildren
%   findPromotedSystems
%   importDataDict
%   findExternalParams
%   getOuputSampleTimes

% Root level of Model
mbdd = struct('model',bdroot(gcs));

% Max reporting level on systems
mbdd.maxLvl = 4;

% Get model revision history, calls function parseRevisionHistory
mbdd.revHist = parseRevisionHistory(mbdd.model,true);

% Get list of software components.  The software component is considered to
% be the top level of a chaper entery in the report.  Each software
% component must have the text "SoftwareComponent" set in the Tag parameter
swcList = find_system(bdroot,'LookUnderMasks','on','FollowLinks','on','Tag','SoftwareComponent');

% Create an entry in the mbdd structure for each software component
for idSWC = 1:length(swcList)
    swc.name = swcList{idSWC};

    % Get system hierarchy of each SWC.  Hierarchy consists of nested cell
    % arrays.  Each entry consists of at least one row, representing a
    % subsytem to be reported on.  Each row consists of 2 columns.  The
    % first column is the name of the subsystem itself, and the next column
    % consists of a cell array of it's child subsystems.  If there are no
    % children, then the cell is empty.
    swc.reportedSystems = {};
    % calls the recursive function getHierarchyChildren to get Subsystems
    swc.hierarchy = {swcList{idSWC},getHierarchyChildren(swcList{idSWC})};
    
    % Get list of promoted sybsystems for levels 1 to max sublevel
    for idx = 1:mbdd.maxLvl
        swc.promotions{idx} = findPromotedSystems(swc.hierarchy,['RptGenLevel-',num2str(idx)]);
    end
    
    % Get list of inputs (top level inport names) and create signal structure from data
    % 
    inportList = find_system(swcList{idSWC},'LookUnderMasks','on','SearchDepth','1','BlockType','Inport');
    swc.inputs = {};
    if ~isempty(inportList)
        for idx = 1:length(inportList)
            swc.inputs{idx}.name = get_param(inportList{idx},'Name');
            swc.inputs{idx}.units = get_param(inportList{idx},'Unit');
            swc.inputs{idx}.type = get_param(inportList{idx},'OutDataTypeStr');
            swc.inputs{idx}.min = get_param(inportList{idx},'OutMin');
            swc.inputs{idx}.max = get_param(inportList{idx},'OutMax');
            swc.inputs{idx}.rate = get_param(inportList{idx},'SampleTime');
            swc.inputs{idx}.description = get_param(inportList{idx},'Description');
            if isfield(get_param(inportList{idx},'ObjectParameters'),'varSource')
                swc.inputs{idx}.source = get_param(inportList{idx},'varSource');
            else
                swc.inputs{idx}.source = '';
            end
            
            if isfield(get_param(inportList{idx},'ObjectParameters'),'Resolution')
                swc.inputs{idx}.resolution = get_param(inportList{idx},'Resolution');
            else
                swc.inputs{idx}.resolution = '[]';
            end
        end
    end
    clear inportList idx
    
    % Get data dictionary info and assign to calibrations and outputs.
    % Data dictionaries can be either .sldd type with TEN class datatypes
    % or the old _dd.m file type
    [swc.calibrations,swc.outputs] = importDataDict(mbdd.model,swcList{idSWC});
    
    % Get any calibrations that are external to the SWC's data dictionary.
    % Blocks with Ext - <filename> in the Tag field will be found and the
    % calibratable(s) in that block will be added to this list
    swc.externals = findExternalParams(swcList{idSWC},swc.calibrations);
    
    % Get complied sample times for the outputs to replace the inherited
    % with the actual, otherwise all sample times will display "-1".
    swc.outputs = getOuputSampleTimes(swcList{idSWC},swc.outputs);
    
    mbdd.swcArray{idSWC} = swc;
    clear idx swc
end
clear idSWC swcList

