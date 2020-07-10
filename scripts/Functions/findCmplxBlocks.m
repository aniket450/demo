function cmplxBlocks = findCmplxBlocks(hSys,cmplxBlockType)

%  This function finds the Complex Appendix, Description, or Detail blocks
%  masked for MBDD automated report generation.  docBlocks returns the
%  sorted order of the Complex blocks that were searched for.  Search is
%  conducted only in the same level of the subsystem.
%
%  Inputs:
%  hSys           :   Name or handle of the reported system
%  cmplxBlockType :   The type of the mask
%                       - RptGen Appendix
%                       - RptGen Complex Description
%                       - RptGen Complex Detail
%
%  Outputs:
%  cmplxBlocks    :   Cell array containing sorted complex block names

% Find all complex block in the system
cmplxBlocks = find_system(hSys,'LookUnderMasks','on','FollowLinks','on','SearchDepth','1','MaskType',cmplxBlockType);

if ~isempty(cmplxBlocks)
    for idx = 1:length(cmplxBlocks)
        for idy = idx+1:length(cmplxBlocks)
            
            % sort the blocks by the mask parameter "rptgenOrder"
            if eval(get_param(cmplxBlocks{idx},'rptgenOrder')) > eval(get_param(cmplxBlocks{idy},'rptgenOrder'))
                dummy = cmplxBlocks{idx};
                cmplxBlocks{idx} = cmplxBlocks{idy};
                cmplxBlocks{idy} = dummy;
            end
        end
    end
end
