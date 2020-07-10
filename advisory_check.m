function advisory_check()
model_to_build = textread('test_file.txt', '%s', 'whitespace', '');
if(length(model_to_build) == 1)
    try
        addpath scripts;
        
        cd (cell2mat(model_to_build));
        %%
        filename = 'advisory_report.txt';
        text_iso = strcat('Below details are ISO26262 Guidelines Check Report');
        fetch_guidelines_data(filename,text_iso,'w+') %open or create file for reading and writing; discard existing contents
        %%
        model_name = dir('*.slx');
        [~, test_model, extm] = fileparts(model_name(1).name);
        load_system(model_name(1).name);
        top_ss = find_system(test_model,'BlockType','SubSystem');
        %%no change
        %iso_26262_chk_list
        iso_26262_chk_list ={'mathworks.iec61508.hisl_0032',...
            'mathworks.iec61508.hisl_0032','mathworks.iec61508.MdlMetricsInfo',...
            'mathworks.iec61508.UnconnectedObjects',...
            'mathworks.iec61508.RootLevelInports'...
            'mathworks.iec61508.InportRange',...
            'mathworks.iec61508.OutportRange',...
            'mathworks.iec61508.PCGSupport',...
            'mathworks.iec61508.StateflowProperUsage',...
            'mathworks.iec61508.hisf_0001',...
            'mathworks.iec61508.MathOperationsBlocksUsage',...
            'mathworks.iec61508.SignalRoutingBlockUsage',...
            'mathworks.iec61508.LogicBlockUsage',...
            'mathworks.iec61508.PortsSubsystemsUsage',...
            'mathworks.iec61508.hisl_0021',...
            'mathworks.iec61508.RequirementInfo',...
            'mathworks.iec61508.himl_0002',...
            'mathworks.iec61508.himl_0003',...
            'mathworks.iec61508.himl_0004',...
            'mathworks.iec61508.himl_0005'};
        
        try
            mkdir 'iso_check_report'
            cd 'iso_check_report'
            
            SysResultObjArray = ModelAdvisor.run(top_ss{1,1},iso_26262_chk_list);
            cd ..
            data_iso = SysResultObjArray{1, 1}.report;
            fetch_guidelines_data(filename,data_iso,'at+') %open or create file for reading and writing; append data to end of file
            
        catch
            fprintf('iso check failed');
            text_iso = ('iso check failed');
            fetch_guidelines_data(filename,text_iso,'at+')
        end
        close_system(model_name(1).name);
        %% maab Check
        text_maab = strcat('Below details are MAAB Guidelines Check Report');
        fetch_guidelines_data(filename,text_maab,'at+')
        
        load_system(model_name(1).name);
        maab_check_list = {'mathworks.maab.ar_0001',...
            'mathworks.maab.ar_0002',...
            'mathworks.maab.jc_0281',...
            'mathworks.maab.db_0081',...
            'mathworks.maab.jm_0010',...
            'mathworks.maab.db_0110'
            };
        try
            mkdir 'maab_check_report'
            cd 'maab_check_report'
            
            SysResultObjArray_maab = ModelAdvisor.run(top_ss{1,1},maab_check_list);
            cd ..
            data_maab = SysResultObjArray_maab{1, 1}.report;
            fetch_guidelines_data(filename,data_maab,'at+')
        catch
            fprintf('maab check failed');
            text_maab = ('maab check failed');
            fetch_guidelines_data(filename,text_maab,'at+')
        end
        close_system(model_name(1).name);
        %%
        cd ..
        cd ..
    catch
        cd ..
        cd ..
        close_system();
        error(' error in advisory check');
        
    end
else
    error('error in test_file.txt');
end
exit;
end
