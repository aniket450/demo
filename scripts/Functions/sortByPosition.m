function sortedSystems = sortByPosition(listSystems,posTol)

% This function will sort the blocks given in the cell array "listSystems"
% by their relative positions on the screen, from right to left, and then
% by top to bottom.  The blocks are consdered at the same level if the
% position of the left or top corner are equal to eachother within the
% tolerance given in the "posTol" variable.
%
% Inputs:
%   listSystems (cell array) = a list of names (char array) or handles
%   (double) of blocks in the same system
%   posTol (double) = the blocks are considered to be at the same position
%   coordinate if the positions are within this tolerance value in pixels
%
% Outputs:
%   sortedSystems (cell array) = the blocks given in listSystems sorted

% Position array: (left, top, right, bottom)
for sortLoop = 1:length(listSystems)-1
    for id1 = 1:length(listSystems)-1
        id2 = id1+1;
        pos1 = get_param(listSystems{id1},'Position');
        pos2 = get_param(listSystems{id2},'Position');

        % compare left positions within a certain tolerance
        if pos1(1) > pos2(1)+posTol
            dummy = listSystems{id1};
            listSystems{id1} = listSystems{id2};
            listSystems{id2} = dummy;

        % if they are positioned at the same level within tolerance, then
        % compare top positions
        elseif abs(pos1(1)-pos2(1)) < posTol
            if pos1(2) > pos2(2)+posTol
                dummy = listSystems{id1};
                listSystems{id1} = listSystems{id2};
                listSystems{id2} = dummy;
            end
        end
    end
end

sortedSystems = listSystems;
