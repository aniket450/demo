function docBlocks = findDocBlocks(hSys,docBlockType)

%  This function finds the DocBlocks masked for MBDD automated report
%  generation.  docBlocks returns the sorted order of the DocBlock types
%  that was searched for.  Search is conducted only in the same level of
%  the subsystem.
%
%  Inputs:
%  hSys         :   Name or handle of the reported system
%  docBlockType :   The type of the DocBlock Mask
%                       - RptGenDetail
%                       - RptGenDescription
%                       - RptGenIntroduction
%
%  Outputs:
%  docBlocks    :   Cell array containing sorted DocBlock names

docBlocks = {};

% find the docBlocks in the system
docMasks = find_system(hSys,'LookUnderMasks','on','FollowLinks','on','SearchDepth','1','MaskType',docBlockType);

if ~isempty(docMasks)
    for idx = 1:length(docMasks)
        for idy = idx+1:length(docMasks)
            
            % sort the order of the docBlocks based on the mask parameter "rptgenOrder"
            if eval(get_param(docMasks{idx},'rptgenOrder')) > eval(get_param(docMasks{idy},'rptgenOrder'))
                dummy = docMasks{idx};
                docMasks{idx} = docMasks{idy};
                docMasks{idy} = dummy;
            end
        end
    end
    
    for idx = 1:length(docMasks)
        docBlocks = [docBlocks;find_system(docMasks{idx},'LookUnderMasks','on','SearchDepth','1','MaskType','DocBlock')];
    end
end
