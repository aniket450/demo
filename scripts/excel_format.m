function excel_format(testvector_excel)

Excel = actxserver('Excel.Application');
% Show window (optional).
Excel.Visible = 1;
% Open file located in the current folder.

Workbook = Excel.Workbooks.Open([pwd,'\',testvector_excel]); % Full path is necessary!

% Workbook = Excel.Workbooks.Open(strcat(pwd, '\', filename_testplan.name));%Open Excel file

% Run Macro1, defined in "ThisWorkBook" with one parameter. A return value cannot be retrieved.
retVal = Excel.Run('Paste_format');
% Quit application and release object.
Workbook.Save;
Workbook.Close(true)
Excel.Quit
end 
