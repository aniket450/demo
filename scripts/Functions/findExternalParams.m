function extParams = findExternalParams(hMdl,localParams)

% This function will search the system or model from the "hMdl" input
% variable to find blocks with a Tag starting with "Ext -", with the
% assumption that the rest of the tag will be a filename indicating that
% one or more tunable parameters in the block are not part of the current
% model's data dictionary, but resides in a "global" dictionary or one from
% another software part.  It will provide a cell array list of any
% parameters who's source is an external data dictionary
%
% Inputs:
%   hMdl = the name (char array) or handle (double) of the system to search
%   for external parameters.
%
%   localParams (cell array) = a cell array of parameter structure data
%   (generated from the importDataDict function, for instance) of
%   parameters from the local data dictionary.  Since some blocks can have
%   more that one tunable parameter per block (lookup tables) this is
%   necessary to figure out which parameters are local and which are not.
%
% Outputs:
%   extParams (cell arrary) = a cell array of parameters found in the file
%   indicated by block tags.  Each parameter is a structure with the
%   following fields:
%       name = name of the parameter
%       units = engineering units
%       type = data type
%       min = minimum value
%       max = maximum value
%       rate = the sample rate in seconds for the variable.
%       description = description
%       resolution = resolution
%       extSource = The file name of the external data dictionary
%
% Dependencies:
%   getParamsFromDDFile

% initialization
extParams = {};
expSearch = 'Ext(\s)?-(\s)?[\w.]*';     % regexp string to search for "Ext - ", with and without whitespaces, followed by a word
expSplit = 'Ext(\s)?-(\s)?';            % regexp string to split using "Ext - " as the delimeter
lastExtFile = '';
paramsFromFile = {};

% Find blocks with the "Ext - <filename>" tag
extBlocks = find_system(hMdl,'LookUnderMasks','on','FollowLinks','on','RegExp','on','Tag',expSearch);

% Process any found
for idx = 1:length(extBlocks)
    
    % Extract the filename from the tag
    extTag = regexp(get_param(extBlocks{idx},'Tag'),expSearch,'match');
    extFile = regexp(extTag{1},expSplit,'split');
    extFile = extFile{2};
    
    % this is a timesaver strategy:  if the last external file is the same
    % as the one just found, then don't bother re-parsing the file, simply
    % reuse the stored data in "paramsFromFile" from the last loop.
    if ~isempty(lastExtFile)
        if ~strcmp(lastExtFile,extFile)
            
            % get parameter data only from the data dictionary file
            paramsFromFile = getParamsFromDDFile(extFile);
            lastExtFile = extFile;
        end
    else
        % always get parameters if this is the first loop (lastExtFile is empty)
        paramsFromFile = getParamsFromDDFile(extFile);
        lastExtFile = extFile;
    end
    
    if ~isempty(paramsFromFile)
        
        % calibratables will be in one of the block's dialog parameters,
        % search for a match between the dialog parameters and the list
        % from the data dictionary file.
        dialogParamObjs = get_param(extBlocks{idx},'DialogParameters');
        dialogParams = fieldnames(dialogParamObjs);
        for iDialog = 1:length(dialogParams)
            
            % initialize matching flags for each dialog parameter loop
            matchFound = false;
            localMatch = false;
            
            % check first if this parameter is part of the local data dictionary
            for iLocal = 1:length(localParams)
                if strcmp(get_param(extBlocks{idx},dialogParams{iDialog}),localParams{iLocal}.name)
                    
                    % a match was found, set this flag and break out of the loop early
                    localMatch = true;
                    break
                end
            end
            
            % if the parameter is NOT a local match
            if ~localMatch
                
                % first, check if parameter is already found in another
                % block, since many global parameter can be used in several
                % places.
                duplicateFound = false;
                for iParams = 1:length(extParams)
                    if strcmp(get_param(extBlocks{idx},dialogParams{iDialog}),extParams{iParams}.name)
                        duplicateFound = true;
                        break
                    end
                end
                
                % if it is not already found, now check the paramsFromFile list for a match
                if ~duplicateFound
                    for iFile = 1:length(paramsFromFile)
                        if strcmp(get_param(extBlocks{idx},dialogParams{iDialog}),paramsFromFile{iFile}.name)
                            
                            % if a match is found, add it to the list
                            matchFound = true;
                            newParam = paramsFromFile{iFile};
                            
                            % add the additonal field "extSource" to the parameter object for the report generator
                            newParam.extSource = extFile;
                            extParams = [extParams;newParam];
                        end
                        if matchFound
                            break
                        end
                    end
                end
            end
        end
    end
    
end
    
    