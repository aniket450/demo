function isFiltered = TennecoSystemFilter(sysName,blkList)

% This function will determine if the Simulink Block from the input
% variable "sysName" shall be filtered out from the autogenerated report.
% There are 4 local parameters that will exclude a block based on:
%   library source (if it's a library linked block)
%   background color
%   number of child blocks (so that empty subsystems are not reported on)
%   mask types
%
% Also, the cell array input "blkList" will also exclude any blocks by
% specific name, if the filter parameters are not enough.  blkList can be
% an empty cell array if that list is not needed.
%
% The output will be true if the block does not pass any of the filters
%
% Inputs:
%   sysName = block name (char array) or block handle (double)
%   blkList (cell array) = list of block names to exclude
%
% Outputs:
%   isFiltered (boolean) = status of the filter for the sysName block
%
% Dependencies:
%   getLibraryRoot

% Filter parameters
% Library links to exclude from report
libFilter = {'simulink','tenneco_lib'};
% Background colors to exclude
colorFilter = {'gray','[0.627451, 0.627451, 0.627451]'};
% Subsystems with blocks fewer than this value will be excluded
numBlkFilter = 3;
% Masked blocks with these Mask Type will be excluded
maskFilter = {'RptGen Appendix','RptGen Complex Description','RptGen Complex Detail'};

isFiltered = false;

% Only subsystems will pass the filter
if ~strcmp('SubSystem',get_param(sysName,'BlockType'))
    isFiltered = true;
end

% Get the library name of the block if it is a linked library and test to
% filter
libRoot = getLibraryRoot(sysName);
if ~strcmp(libRoot,'none')
    for idx = 1:length(libFilter)
        if strcmp(libFilter{idx},libRoot)
            isFiltered = true;
        end
    end
end

% Test the color filter
for idx = 1:length(colorFilter)
    if strcmp(get_param(sysName,'BackgroundColor'),colorFilter{idx})
        isFiltered = true;
    end
end

% Test the number of child blocks filter
if length(get_param(sysName,'Blocks')) < numBlkFilter
    isFiltered = true;
end

% Test the blkList filter
if ~isempty(blkList)
    for idx =1:length(blkList)
        if strcmp(blkList{idx},sysName)
            isFiltered = true;
        end
    end
end

% Test the Mask type filter
for idx = 1:length(maskFilter)
    if strcmp(get_param(sysName,'MaskType'),maskFilter{idx})
        isFiltered = true;
    end
end