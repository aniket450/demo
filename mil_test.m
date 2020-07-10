function mil_test()
% main_path = pwd;
script_path = dir('**/*mil_test.m');
main_path = script_path.folder;
addpath(main_path);

model_to_build = textread('test_file.txt', '%s', 'whitespace', '');
testfile_path = strcat(main_path, '\', cell2mat(model_to_build), '\');
if(length(model_to_build) == 1)
    try
        addpath scripts;
        
        cd (testfile_path);
        
        [model_name, in_port_names, out_port_names] = generate_test_harness();
        create_testvector(model_name, in_port_names, out_port_names, main_path, testfile_path);
        update_testvector();
        perform_test('mil');
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
        error(' error in mil_test');
    end
else
    error('error in test_file.txt');
end
exit;
end