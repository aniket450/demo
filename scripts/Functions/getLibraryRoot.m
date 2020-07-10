function libRoot = getLibraryRoot(hBlk)

% This function returns the library name of the block given in the input
% variable "hBlk".  The output will return "none" rather than a name if:
%   The block is not a linked library block
%   The library link is disabled
%
% Inputs:
%   hBlk = the name (char array) or handle (double) of the block
%
% Outputs:
%   libRoot (char array) = the name of the library.  It will = "none" if
%   there is no valid libary link.

libRoot = 'none';

linkStat = get_param(hBlk,'LinkStatus');
if strcmp(linkStat,'resolved') || strcmp(linkStat,'implicit')
    strList = strsplit(get_param(hBlk,'ReferenceBlock'),'/');
    libRoot = strList{1};
end
