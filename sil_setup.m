function sil_setup()

try
    % create a basic ert s_fcn block here
    create_s_fcn();
    
    model_files = dir('*.slx');
    
    % assuming 3 models are present at this level now,
    % model.slx
    % model_MIL_test.slx
    % model_SILtest.slx
    % so, processing the main model
    [~,model_name,~] = fileparts(model_files(1).name);
    
    load_system(model_name);
    
    %check if autosar.tlc selected, if YES, do the next action
    tlc_selected = get_param(model_name,'SystemTargetFile');
    
    if(strcmp(tlc_selected,'autosar.tlc'))
        
        % data types as per rte_types or autosar
        ar_datatype_list = struct('boolean','boolean_T','int16','int16_T','uint8','uint8_T');
        
        % build autosar sw module
        rtwbuild(model_name);
        
        % auto generated RTE header file, change this to original header file
        % if necessary
        autosar_prop = autosar.api.getAUTOSARProperties(model_name);
        autosar_sim_mapping = autosar.api.getSimulinkMapping(model_name);
        
        aswcPath = find(autosar_prop,[],'AtomicComponent','PathType','FullyQualified');
        aswcPath = split(aswcPath,'/');
        sw_header_name = aswcPath(end);
        sw_header_file = strcat(model_name,'_autosar_rtw/stub/Rte_',sw_header_name,'.h');
        
        DD1 = py.importlib.import_module('UTFrameExtractFuntion');
        DD2 = py.importlib.import_module('write_sfcn_file');
        % get all matlab ports and its Autosar mapped port and element names
        % from the model
        model_in_ports = find_system(bdroot,'searchDepth',1,'BlockType','Inport');
        model_out_ports = find_system(bdroot,'searchDepth',1,'BlockType','Outport');
        
        
        
        % process model_in_ports
        ar_in_ports_array = {};
        ar_in_port_elements_array ={};
        ar_in_data_access_mode_array= {};
        model_in_ports_datatype ={};
        
        % interface name that has to match with the RTE header file
        ar_in_interface_name = {};
        
        for i=1:length(model_in_ports)
            in_name = get_param(model_in_ports{i,1},'Name');
            model_in_ports_datatype{i} =get_param(model_in_ports{i,1},'OutDataTypeStr');
            if(strfind(model_in_ports_datatype{i},'Bus:'))
                bus_obj = split(model_in_ports_datatype{i},':');
                bus_data_type = char(bus_obj(2));
                model_in_ports_datatype{i} = bus_data_type;
                ar_datatype_list.(bus_data_type) = bus_data_type;
            end
            [arPortName,arDataElementName,arDataAccessMode]=getInport(autosar_sim_mapping,in_name);
            ar_in_ports_array{i} = arPortName;
            ar_in_port_elements_array{i} = arDataElementName;
            ar_in_data_access_mode_array{i} = arDataAccessMode;
            ar_in_interface_name{i} = strcat(arPortName,'_',arDataElementName);
        end
        
        % process model_out_ports
        ar_out_ports_array = {};
        arOutDataElementName_array ={};
        ar_out_ports_accessmode_array= {};
        out_datatype ={};
        % interface name that has to match with the RTE header file
        ar_out_interface_name = {};
        
        for i=1:length(model_out_ports)
            out_name = get_param(model_out_ports{i,1},'Name');
            out_datatype{i} =get_param(model_out_ports{i,1},'OutDataTypeStr');
            [arPortName,arDataElementName,arDataAccessMode]=getOutport(autosar_sim_mapping,out_name);
            ar_out_ports_array{i} = arPortName;
            ar_out_port_elements_array{i} = arDataElementName;
            ar_out_ports_accessmode_array{i} = arDataAccessMode;
            
            % rte_XXX_portname_elemtname
            ar_out_interface_name{i} = strcat(arPortName,'_',arDataElementName);
        end
        
        % get autosar runnables,i.e main and init runnables
        autosar_prop = autosar.api.getAUTOSARProperties(model_name);
        runabbles  = find(autosar_prop,[],'Runnable','PathType','FullyQualified');
        
        for i=1:length(runabbles)
            runnables1 = split(runabbles{1,i}, '/');
            if strfind(runnables1(end), '_Init')
                runnables_init = runnables1(end);
            else
                runnables_main = runnables1(end);
            end
        end
        
        total_interface = [ar_in_interface_name,ar_out_interface_name];
        save_system(model_name);
        close_system(model_name);
        
        % call python script to process the rte header file
        %py.importlib.reload(DD1);
        global_str = DD1.processing_info(char(sw_header_file),total_interface);
        
        %%
        % modify the s fucntion c file and insert custom code here
        
        % DO NOT TOUCH BELOW CUSTOME CODE SECTION
        custom_code ='';
        custom_code =['static  boolean_T first_run = true;' char(10) 'if(first_run){',char(10),char(runnables_init),'();' char(10) 'first_run = false;}'  char(10) ];
        for i =1:length(ar_in_interface_name)
            
            % check if it is a status signal or not
            data_type = ar_datatype_list.(model_in_ports_datatype{i});
            sufix ='';
            
            % add all possible status sheck data type here
            if(strfind(ar_in_data_access_mode_array{i},'Status'))
                sufix ='ref';
            end
            custom_code = [custom_code ar_in_interface_name{i},sufix,'_g= *((const ',data_type,' **)ssGetInputPortSignalPtrs(S, ',num2str(i-1),'))[0];',char(10)];
        end
        
        custom_code = [custom_code char(runnables_main) '();' char(10)];
        
        for i =1:length(ar_out_interface_name)
            data_type = ar_datatype_list.(out_datatype{i});
            custom_code = [custom_code,'((',data_type,' *)ssGetOutputPortSignal(S, ',num2str(i-1),'))[0] = (real_T) ',ar_out_interface_name{i},'_u;',char(10)];
        end
        
        % add custome code to s-fcn source code .c file

        %py.importlib.reload(DD);
        DD2.write_src_file('s_fcn_model_sfcn_rtw/s_fcn_model_sf.c',custom_code,'static void mdlOutputs',['}',char(10)], 2)
        
        DD2.write_src_file('s_fcn_model_sfcn_rtw/s_fcn_model_sf.c',global_str,'#include "rt_nonfinite.c"',char(10),1)
        % DO NOT TOUCH TILL HERE
        
        %%
        % mex all the sourch file
        mex_build();
    else
        close_system(model_name);
    end
catch
    save_system();
    close_system();
end

end

function mex_build()

autosar_dir = dir('*_autosar_rtw')
autosar_dir = autosar_dir.name

s_fcn_dir = dir('*_sfcn_rtw')
s_fcn_dir = s_fcn_dir.name

% remove rt_nonfinite.c
delete(strcat(s_fcn_dir,'/rt_nonfinite.c'));

source_file_list = [strcat(autosar_dir,'/*.c') strcat(s_fcn_dir,'/*.c')];

simulink_h_files=strcat('-I','"C:/Program Files/MATLAB/R2016b/simulink/include"');
rtw_h_files = strcat('-I','"C:/Program Files/MATLAB/R2016b/rtw/c/src"');
ar_h_files = strcat('-I"',autosar_dir,'"');
ar_stub_h_files = strcat('-I"',autosar_dir,'/stub','"');
sf_h_files = strcat('-I"',s_fcn_dir,'"');
mex('-g',strcat(autosar_dir,'/*.c'),strcat(s_fcn_dir,'/*.c'),...
    simulink_h_files,...
    rtw_h_files,...
    ar_h_files,...
    ar_stub_h_files,...
    sf_h_files)
end