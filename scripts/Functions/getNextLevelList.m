function nextLvl = getNextLevelList(sysLvl,reportedSystems,promoTag)

% This function will return the next level in the hierarchy to report on.
% It includes subsystems to the systems and systems tagged to be promoted
% to the same level as given in the "promoTag" input variable.  It will not
% inclued any systems that have already been reported on as given in the
% "reportedSystems" input variable.
% 
% Inputs:
%   sysLvl (cell array) = hierarchy element that is the currently reported
%   system
%   reportedSystems (cell array) = list of systems already reported on
%   promoTag (string) = promotion level tag to search for in subsystems.
%   Allowed values are:
%       RptGenLevel-1
%       RptGenLevel-2
%       RptGenLevel-3
%       RptGenLevel-4
%
% Outputs:
%   nextLvl (cell array) = hierarchies of the next systems to be reported
%   on, one heading level down from the current one
%
% Dependencies:
%   findPromotedSystems

% initialize output
nextLvl = {};

% origninally this function was to process ALL the systems in a given
% level, thus it was expected that the row size of the input hierarchy 
% could be > 1.  However, it is now expected that the sysLvl input will
% always be only 1 row.  Hence why idSys exists to loop through a sysLvl
% with more than 1 row, but it doesn't affect the current use of it, so it
% was not modified.
for idSys = 1:size(sysLvl,1)
    
    % get the children from the current system.
    children = sysLvl{idSys,2};
    for idx = 1:size(children)
        isReported = false;
        
        % check the child against the already reported systems, and flag if a match is found
        for idy = 1:length(reportedSystems)
            if strcmp(reportedSystems{idy},children{idx,1})
                isReported = true;
            end
        end
        
        % if it is NOT a system already reported, then add the child's hierarchy to the list
        if ~isReported
            nextLvl = [nextLvl;{children{idx,1},children{idx,2}}];
            
            % also add to the list any hierarchies under this child that have the matching promoTag
            nextLvl = [nextLvl;findPromotedSystems({children{idx,1},children{idx,2}},promoTag)];
        end
    
    end
end
