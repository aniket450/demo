function hierarchy = getHierarchyChildren(sysName)

% This function searches the subsystem, given in the input "sysName," for
% other sybsystems that pass the TennecoSystemFilter.  A hierarchy of
% subsystems is created in nested cell arrarys.  The output will be a cell
% array with x rows and 2 columns.  The number of rows equals the number of
% children subsystems are found in sysName.  Column 1 = the name of the
% child and column 2 = a cell array of its children subsystems found by
% recursively calling this function.  The recursion ends when no more
% children are found, and an empty cell array is returned.
%
% Inputs:
%   sysName = current system name (char array) or handle (double)
%
% Outputs:
%   hierarchy = Nx2 cell array where:
%       N row = the Nth child system found in sysName
%       col 1 (char array) = name of the child found
%       col 2 (cell array) = the children of the child system
%
% Dependencies:
%   TennecoSystemFilter
%   sortByPosition
%   getHierarchyChildren (recursive)

% initialize output and local variables
hierarchy = {};
childSysNames = {}; % cell array list of children subsystems found

% Find all subsystem blocks in sysName, only looking one level down
unfiltSysNames = find_system(sysName,'LookUnderMasks','on','FollowLinks','on','SearchDepth','1','BlockType','SubSystem');

% if sysName contains subsystems, run it through the TennecoSystemFilter to
% see if it is a system that will be reported.
if ~isempty(unfiltSysNames)
    for idx = 1:length(unfiltSysNames)
        if ~TennecoSystemFilter(unfiltSysNames{idx},{sysName})
            
            % add to the list if it passes the filter
            childSysNames = [childSysNames;unfiltSysNames{idx}];
        end
    end
end

% sort the block order by its position on the screen (left to right, then
% top to bottom with a "at the same level" tolerance of 5 pixels
childSysNames = sortByPosition(childSysNames,5);

% call this function recursively to find the children's children
if ~isempty(childSysNames)
    for idx = 1:length(childSysNames)
        hierarchy = [hierarchy;{childSysNames{idx},getHierarchyChildren(childSysNames{idx})}];
    end
end
