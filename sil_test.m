function sil_test()
% main_path = pwd;
script_path = dir('**/*sil_test.m');
main_path = script_path.folder;
addpath(main_path);

model_to_build = textread('test_file.txt', '%s', 'whitespace', '');
testfile_path = strcat(main_path, '\', cell2mat(model_to_build), '\');

if(length(model_to_build) == 1)
    try
        addpath scripts;
        cd (testfile_path);
        % generate s function for the application model
        sil_setup();
        perform_test('sil');
        
        cd (main_path);
    catch
        % close if any system open in backgorund
        try
            close_system();
        catch
            save_system();
            close_system();
        end
        cd (main_path);
        error(' error in sil_test. retry Marelli test Demo. Retest');
    end
	
	
else
	fprintf('demo');
    error('error in test_file.txt. retry Marelli test Demo');
end
exit;
end