function create_s_fcn()
try
    delete '*_SIL_Test.slx';
    model_file = dir('*_MIL_test.slx');
    
    % consider 2 models present at this time of execution
    % model.slx
    % model_mil_test.slx
    
    % considering 2nd list item is the MIL_test model file, process the mil
    % test model file
    [~,model_name,~] = fileparts(model_file(1).name);
    load_system(model_name);
    
    [~,model_name1,~] = fileparts(model_file(1).name);
    sil_test_file = [model_name1, '_SIL_Test'];
    save_system(model_name, sil_test_file);
    close_system(model_name);
    
    load_system(sil_test_file);
    find_subsys = find_system(sil_test_file,'searchDepth',1, 'BlockType','SubSystem');  %finding subsystem
    
    % only one subsystem to be expected at top level
    if(length(find_subsys) == 1)
        pos = get_param(find_subsys{1},'position');
        new_system('s_fcn_model','Model',find_subsys{1});
        delete_block(find_subsys{1});
        
        % model simulation config settings
        set_param('s_fcn_model','SolverType','Fixed-step');
        set_param('s_fcn_model','RTWSystemTargetFile','rtwsfcn.tlc');
        set_param('s_fcn_model','RTWTemplateMakefile','rtwsfcn_default_tmf');
        set_param('s_fcn_model','DefaultUnderspecifiedDataType','single')
        rtwbuild('s_fcn_model');
        
        add_block('untitled/Generated S-Function',find_subsys{1},'position',pos);
        bdclose untitled;
        bdclose s_fcn_model;
        clear pos;
    else
        save_system(sil_test_file);
        close_system(sil_test_file); 
        error('more than 1 subsystem found on top-level');
    end
    save_system(sil_test_file);
    close_system(sil_test_file);    
catch
    save_system();
    close_system();
    error('SIL execution failed at SS to Sfunction export');
end