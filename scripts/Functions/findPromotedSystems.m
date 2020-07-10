function promotedSystems = findPromotedSystems(hierarchy,tagLvl)

% This function creates a list of promoted hierarchies of children, 
% grandchildren, etc. from the top or parent level of the "hierarchy"
% input.  Any systems with the Tag parameter set to the value in "tagLvl",
% will be copied to the promotedSystems list along with its hierarchy of
% children.  This function is very similar to its dependent function,
% findPromoTagInGenerations, however, this function is the "starter" for
% the recursion calling of its dependent.
%
% Inputs:
%   hierarchy (cell array) = cell array of at least one row and exactly 2
%   columns, where:
%       col 1 (char array) = name of the system
%       col 2 (cell array) = hierarchy of col 1's children
%   tagLvl (char array) = string indicating the promotion level to search
%   for.  Must be one of the following:
%       RptGenLevel-1
%       RptGenLevel-2
%       RptGenLevel-3
%       RptGenLevel-4
%
% Outputs:
%   promotedSystems (cell array) = hierarchies of promoted systems
%
% Dependencies:
%   findPromoTagInGenerations

promotedSystems = {};

for idx = 1:size(hierarchy,1)
    if ~isempty(hierarchy{idx,2})
        children = hierarchy{idx,2};
        
        % search for promotion tag in each child, recursive call for grandchildren
        promotedSystems = [promotedSystems;findPromoTagInGenerations(children,tagLvl)];
        
    end
end
