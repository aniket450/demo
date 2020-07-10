function check_and_close_excel_files(test_vector_file)
% close all opened test vector file
if ~isempty(test_vector_file)
    xlsfile = fullfile(pwd, test_vector_file(1).name);
    try
        Excel = actxGetRunningServer('Excel.Application');
        Workbooks = Excel.Workbooks; % get the names of all open Excel files
        for ii = 1:Workbooks.Count
            if strcmp(xlsfile, Workbooks.Item(ii).FullName)
                %         Workbooks.Item(ii).Save % save changes
                Workbooks.Item(ii).Close; % close the Excel file
                print_logdata('Test Vector Excel was found open, and its closed now');
                break
            else
                print_logdata('Test Vector Excel file is not opened');
            end
        end
    catch
        print_logdata('Test Vector Excel file is not opened');
    end
end
end