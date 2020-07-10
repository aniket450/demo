function RevHist = parseRevisionHistory(hMdl,sortFirst2Last)

% This function will get the "ModifiedHistory" parameter of the Simulink
% model specified in the "hMdl" input variable.  Furthermore, it will sort
% each revision found in ascending order if "sortFirst2Last" is set to
% true.  The output is a cell array where each row is a revision and each
% column is data regarding that revison
%
% Inputs:
%   hMdl = handle (double) or full name (char array) of the Simulink model
%   sortFirst2Last (boolean) = If true, output will be sorted based on
%   revision number
%
% Output:
%   RevHist (cell array) =  Revision history data where:
%       row = revision entry
%       col 1 = Version
%       col 2 = Author
%       col 3 = Description of Changes
%       col 4 = Date

revHist = {};
% Set reqular expressions to sort the string data
exprLines = '[^\n]*[^\n]*';     % Get each line separately (blank lines skipped)
exprVer = '\<[0-9.]*';          % Get version number

textRevHist = get_param(hMdl,'ModifiedHistory');

% Separate textRevHist into lines by newline characters \n
linesRevHist = regexp(textRevHist,exprLines,'match');

revIdx = 0;
for idx = 1:length(linesRevHist)
    
    % Revision history has a "header" with entry metadata.  The header has
    % '--' characters to separate the data.  Lines beneath that header will
    % contain the Description of changes until the next header is found.
    if strfind(linesRevHist{idx},'--')
        
        % if a line is found with header information.  Parse line this way
        revIdx = revIdx + 1;
        revInfo = strsplit(linesRevHist{idx},' -- ');
        RevHist{revIdx,2} = revInfo{1};         % Author
        RevHist{revIdx,4} = datestr(datenum(revInfo{2},'ddd mmm dd HH:MM:SS yyyy'),'dd-mmm-yyyy');      % Date
        RevHist{revIdx,1} = regexp(revInfo{3},exprVer,'match');     % Version
        RevHist{revIdx,1} = RevHist{revIdx,1}{1};
        RevHist{revIdx,3} = '';     % Changes, a placeholder until the lines beneath the header are parsed.
    else
        
        % if a line is NOT a header AND not the first line, then they will
        % be the Changes portion of the entry described by the previouly
        % found header.
        if revIdx > 0
            
            % Skip any blank lines
            if ~isempty(RevHist{revIdx,3})
                RevHist{revIdx,3} = [RevHist{revIdx,3},newline,linesRevHist{idx}];
            else
                RevHist{revIdx,3} = linesRevHist{idx};
            end
        end
    end
end

% If sortFirst2Last is true, then sort the revisions in ascending order by
% the Version number
for idx = 1:size(RevHist,1)
    for idy = idx+1:size(RevHist,1)
        if (eval(RevHist{idx,1}) > eval(RevHist{idy,1})) && sortFirst2Last
            for sortLoop = 1:4
                dummy = RevHist{idx,sortLoop};
                RevHist{idx,sortLoop} = RevHist{idy,sortLoop};
                RevHist{idy,sortLoop} = dummy;
            end
        end
    end
end
