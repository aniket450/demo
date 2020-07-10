function makeSLddFromTENdd(sourceFilename, targetFilename)

% This function is for creating a Simulink Data Dictionary file from
% objects for variables found in a legacy Tenneco _dd.m data dictionary.
% The source and target filenames must include the proper extensions:
%   Tenneco source file:   <filename>.m
%   Simulink target file:  <filename>.sldd
%
% Inputs:
%   sourceFilename (string) = data dictionary file name.  Must be in the
%       legacy Tenneco data dictionary format.  Must incluse extension.
%   targetFilename (string) = Simulink data dictionary file.  Must include
%       extension.
%
% Dependencies:
%   makeDataObjsFromTENdd function
%   TEN.Parameter class
%   TEN.Signal class

dictionaryObj = Simulink.data.dictionary.create(targetFilename);
sectionObj = getSection(dictionaryObj,'Design Data');

dataObjs = makeDataObjsFromTENdd(sourceFilename);
for idx = 1:length(dataObjs)
    entryObj = addEntry(sectionObj,dataObjs{idx}.Name,dataObjs{idx}.Value);
end

saveChanges(dictionaryObj)
close(dictionaryObj)
