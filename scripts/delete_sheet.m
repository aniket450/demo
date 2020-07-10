clc
cd 'C:\Users\20063005\Desktop\v_1.0_1'
sheetName = 'Sheet5'; % EN: Sheet, DE: Tabelle, etc. (Lang. dependent)



excelFileName = 'test_delete.xlsx';
excelFilePath = pwd; % Current working directory.
% Open Excel file.
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open(fullfile(excelFilePath, excelFileName)); % Full path is necessary!
% Delete sheets.
% try
% Throws an error if the sheets do not exist.

[a,b,c] = xlsread(excelFileName,sheetName);
[c{:,:}] = deal('');
xlswrite(excelFileName, c, sheetName);
objExcel.ActiveWorkbook.Worksheets.Item([sheetName]).Delete;
%       objExcel.ActiveWorkbook.Worksheets.Item([sheetName]).Delete;
%       objExcel.ActiveWorkbook.Worksheets.Item([sheetName]).Delete;
% catch
; % Do nothing.
% end
% Save, close and clean up.
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;