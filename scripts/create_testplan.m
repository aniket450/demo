function create_testplan(name, mainpath_name, testpathName)

warning off;
cd (mainpath_name);
sheetname_testvector = name;
% sheetname_testplan = strcat(sheetname_testvector, '_Report');
sheetname_testplan = 'Report';


%% Test Plan
filename_testplan = dir('*_TestPlan.xls');
newfilename_testplan = strcat(sheetname_testvector, '_TestPlan.xls');

e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open(strcat(filename_testplan.folder, '\', filename_testplan.name)); % # open file (enter full path!)
% ewb.Worksheets.Item(5).Name = sheetname_testplan; % # rename 1st sheet
e.Visible = 1;
ewb.SaveAs(strcat(testpathName, newfilename_testplan));
ewb.Close(false)
e.Quit
cd(testpathName);

end

