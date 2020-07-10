function promotedSystems = findPromoTagInGenerations(children,tagLvl)

% This function looks inside the subsytem blocks identified by the
% "children" input hierarchy for any subsystems with a Tag matching the
% "tagLvl" input variable.  System hierarchies matching this criteria shall
% be added to the "promotedSystems" cell array list of hierarchies.
%
% Inputs:
%   children (cell array) = hierarchies of systems to be searched for the
%   "tagLvl" Tag
%   tagLvl (char array) = string indicating the promotion level to search
%   for.  Must be one of the following:
%       RptGenLevel-1
%       RptGenLevel-2
%       RptGenLevel-3
%       RptGenLevel-4
%
% Outputs:
%   promotedSystems (cell array) = hierarchies of promoted systems

promotedSystems = {};

% search for promotion tag in each child
for idx = 1:size(children)
    if strcmp(tagLvl,get_param(children{idx,1},'Tag'))
        
        % add to list if the tag is found
        promotedSystems = [promotedSystems;{children{idx,1},children{idx,2}}];
    end
    
    % if the child has children, then search the them for the tag as well,
    % with a recursive function call
    if ~isempty(children{idx,2})
        promotedSystems = [promotedSystems;findPromoTagInGenerations(children{idx,2},tagLvl)];
    end

end