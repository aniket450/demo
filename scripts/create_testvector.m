function create_testvector(name, input, output, mainpath_name, testpathName)
% (name, input, output)


warning off;
cd (mainpath_name);

array = {};
sheetname_testvector = name;
% sheetname_testplan = strcat(sheetname_testvector, '_Report');


in_pat = 'in_';
% xlRange_input = 'D2';
for i = 1 : length(input)
    input(i) = strcat(in_pat, input(i));
    array{end+1} = input{i};
end

array{end+1} = 'Parameter';

xlRange_header = 'D2';
xlRange_units_data = 'D3';
xlRange_resl_value = 'D4';

%% Test Vector

filename_testvector = dir('*_TestVector.xlsm');
newfilename_testvector = strcat(sheetname_testvector, '_TestVector.xlsm');

e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open(strcat(filename_testvector.folder, '\', filename_testvector.name)); % # open file (enter full path!)
ewb.Worksheets.Item(1).Name = sheetname_testvector; % # rename 1st sheet
e.Visible = 1;
ewb.SaveAs(strcat(testpathName, newfilename_testvector));
ewb.Close(false)
e.Quit

%%
xlswrite(fullfile(testpathName,newfilename_testvector), array,sheetname_testvector,xlRange_header);% # create test file

C    = cell(1, (length(array)));
C(:) = {'NA'};
xlswrite(fullfile(testpathName,newfilename_testvector),C,sheetname_testvector,xlRange_units_data);
D    = cell(1, (length(array)-1));
D(:) = {'0'};
xlswrite(fullfile(testpathName,newfilename_testvector), D,sheetname_testvector,xlRange_resl_value)
%%
xlRange3 ='A1';
str1 = 'Last Run  :   ';
DATE=strcat(str1,{datestr(now)});
xlswrite(fullfile(testpathName,newfilename_testvector), DATE, sheetname_testvector,xlRange3);
% filename1 = strcat(name, '_TestVector.xlsx');
% winopen(newfilename_testvector)
cd(testpathName);


end

