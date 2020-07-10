model_to_build = textread('test_file.txt', '%s', 'whitespace', '');
if(length(model_to_build) == 1)
    try
    cd (cell2mat(model_to_build));
    model_file = dir('*.slx');
    [~,model_name,~] = fileparts(model_file(1).name);
    rtwbuild(model_name) ;
    cd ..
    cd ..
    catch
    cd ..
    cd ..
    error('error in build');
    end
else
    error('test_file error');
end
exit;