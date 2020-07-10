
function [model_name, in_port_names, out_port_names] = generate_test_harness()
warning off;

% close if any system open in backgorund
% delete if any test harness file exists in the repo
try
    close_system();
catch
    save_system();
    close_system();
end
delete *_MIL_Test.slx;
delete *_SIL_Test.slx;

model = dir('*.slx');
[~,model_name,~] = fileparts(model.name);

load_system(model_name);
curr_sys = bdroot;

%clear functions if not valid
set_param(model_name,'PostLoadFcn','');
set_param(model_name,'DataDictionary','');


% load model configuration 
cs = float_configuration();
attachConfigSet(model_name, cs, 1);
setActiveConfigSet(model_name, cs.name);
save_system(model_name);



in_ = 'in_';
% out_ = 'out_';

% get the top subsystem name %
top_sub_sys = find_system(gcs,'SearchDepth',1,'BlockType','SubSystem');
%top_sub_sys_flag = false;
if(length(top_sub_sys) > 1)
    [top_sub_sys_name] = create_subsystem_from_selection(curr_sys);
else
    top_sub_sys_name = split(top_sub_sys{1,1},'/');
    top_sub_sys_name = top_sub_sys_name{2,1};
    top_sub_sys_name = replace(top_sub_sys_name,' ','_');
    set_param(top_sub_sys{1,1},'Name',replace(top_sub_sys_name,' ','_'));
end

in_ports = find_system('LookUnderMasks','all','SearchDepth',1,'BlockType','Inport');
out_ports = find_system('LookUnderMasks','all','SearchDepth',1,'BlockType','Outport');

in_port_names = get_param(in_ports,'Name'); % extract name of the block
in_port_names = replace(in_port_names,' ','_');

out_port_names = get_param(out_ports,'Name'); % extract name of the block
out_port_names = replace(out_port_names,' ','_');
%%
if(numel(in_ports) > 0 && numel(out_ports) > 0)
    for x = 1 : length(in_ports)
        pc = get_param(in_ports{x},'Position');
        
        delete_block(in_ports{x});
        
        add_block('Simulink/Sources/From Workspace',in_ports{x});
        set_param(in_ports{x},'Position',[pc(1)-300 pc(2) pc(3) pc(4)]);
        set_param(in_ports{x},'VariableName',strcat(model_name,'.',in_,in_port_names{x}));
        
        delete_line(curr_sys,strcat(in_port_names{x},'/1'),strcat(top_sub_sys_name,'/',num2str(x)));
        
        add_block('Simulink/Signal Attributes/Data Type Conversion',strcat(in_ports{x},'_conv'));
        set_param(strcat(in_ports{x},'_conv'),'Position',[pc(1)+50 pc(2) pc(1)+150 pc(4)]);
        
        add_line(curr_sys,strcat(in_port_names{x},'/1'), strcat(in_port_names{x},'_conv','/1'));
        add_line(curr_sys,strcat(in_port_names{x},'_conv','/1'),  strcat(top_sub_sys_name,'/',num2str(x)));
        
        set_param(in_ports{x},'Position',[pc(1)-300 pc(2) pc(3)-100 pc(4)]);
    end
    
    for x = 1 : length(out_ports)
        
        pc = get_param(out_ports{x},'Position');
        pc(3) = pc(3) + 200;
        
        delete_block(out_ports{x});
        
        add_block('Simulink/Sinks/To Workspace',out_ports{x});
        set_param(out_ports{x},'Position',pc);
        set_param(out_ports{x},'VariableName',out_port_names{x});
    end
    %%
else
    %%
    in_ports = find_system(model_name,'LookUnderMasks','all','SearchDepth',2,'BlockType','Inport');
    in_port_names = get_param(in_ports,'Name');
    in_port_names = replace(in_port_names,' ','_');
    
    pc = get_param(strcat(model_name,'/',top_sub_sys_name),'PortConnectivity');
    pc_itr = 1;
    for itr_in = 1 : length(in_ports)
        port_name_in = strcat(curr_sys,'/',(in_port_names{itr_in}));
        add_block('Simulink/Sources/From Workspace',port_name_in);
        
        y_in = pc(pc_itr).Position(2) - 10;
        x_in = pc(pc_itr).Position(1) - 200;
        pos = [x_in - 300 y_in x_in - 150 y_in + 20];
        set_param(port_name_in,'Position',pos);
        set_param(port_name_in,'VariableName',strcat(model_name,'.',in_,in_port_names{itr_in}));
        
        add_block('Simulink/Signal Attributes/Data Type Conversion',strcat(port_name_in,'_conv'));
        set_param(strcat(port_name_in,'_conv'),'Position',[x_in y_in x_in+150 y_in+20]);
        
        add_line(curr_sys,strcat(in_port_names{itr_in},'/1'), strcat(in_port_names{itr_in},'_conv','/1'))
        add_line(curr_sys,strcat(in_port_names{itr_in},'_conv','/1'),  strcat(top_sub_sys_name,'/',num2str(itr_in)))
        
        pc_itr = pc_itr + 1;
    end
    
    out_ports = find_system(model_name,'LookUnderMasks','all','SearchDepth',2,'BlockType','Outport');
    out_port_names = get_param(out_ports,'Name');
    out_port_names = replace(out_port_names,' ','_');
    
    for itr_out = 1 : length(out_ports)
        port_name_out = strcat(curr_sys,'/',(out_port_names{itr_out}));
        add_block('Simulink/Sinks/To Workspace',port_name_out);
        
        y_out = pc(pc_itr).Position(2) - 10;
        x_out = pc(pc_itr).Position(1) + 100;
        pos = [x_out y_out x_out + 150 y_out + 20];
        set_param(port_name_out,'Position',pos);
        set_param(port_name_out,'VariableName',out_port_names{itr_out});
        add_line(curr_sys,strcat(top_sub_sys_name,'/',num2str(itr_out)),strcat(out_port_names{itr_out},'/1'));
        pc_itr = pc_itr + 1;
    end
end
%%
%%Properties of From Workspace
find_subsystem = find_system(gcs,'BlockType','FromWorkspace');
for n = 1:length(find_subsystem)
    %        name_extract =  get_param(find_subsystem(n),'VariableName');
    set_param(char(find_subsystem(n)),'BackgroundColor','Cyan');
    set_param(char(find_subsystem(n)),'Interpolate','OFF');
    set_param(char(find_subsystem(n)),'OutputAfterFinalValue','Holding final value');
    set_param(char(find_subsystem(n)),'SampleTime','-1');
end
%%
%%Properties of To Workspace
find_subsystem_to = find_system(gcs,'BlockType','ToWorkspace');
for m = 1:length(find_subsystem_to)
    set_param(char(find_subsystem_to(m)),'BackgroundColor','Cyan');
end
%%
adding_line_properties;
newsys = strcat(model_name,'_MIL_Test');
save_system(model_name,newsys);
close_system(newsys);
%open_system(newsys);

% create_testvector(model_name, in_port_names, out_port_names);
end

