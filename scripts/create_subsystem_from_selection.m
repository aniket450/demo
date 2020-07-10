function [sys] = create_subsystem_from_selection(sys)
blocks = find_system(sys, 'SearchDepth', 1);
top_sub_sys =sys;
block_handles = [];
for i = 2 : length(blocks)
    if ~strcmp(get_param(blocks{i},'BlockType'),'Inport')
        block_handles = [block_handles get_param(blocks{i}, 'handle')];
    end
    
end
Simulink.BlockDiagram.createSubSystem(block_handles);
get_inport = find_system(bdroot,'SearchDepth', 1,'BlockType','Inport');
get_subsystem = find_system(gcs,'SearchDepth', 1,'BlockType','SubSystem');

get_subsys_name = get_param(get_subsystem{1,1}, 'Name');
for i1 = 1 : length(get_inport)
    in_name = get_param(get_inport{i1,1}, 'Name');
    delete_line(gcs,strcat(in_name,'/1'),strcat(get_subsys_name,'/',num2str(i1)));
end

get_outport = find_system(gcs,'SearchDepth', 1,'BlockType','Outport');

for i1 = 1 : length(get_outport)
    out_name = get_param(get_outport{i1,1}, 'Name');
    delete_line(gcs,strcat(get_subsys_name,'/',num2str(i1)),strcat(out_name,'/1'));
end
subsystem_pos = get_param(get_subsystem{1,1},'Position');
set_param(get_subsystem{1,1},'Position',[subsystem_pos(1)-200 subsystem_pos(2) subsystem_pos(3) subsystem_pos(4)+100]);
set_param(get_subsystem{1,1},'Name',top_sub_sys);


delete_block(get_inport);
delete_block(get_outport);
%save_system(sys);
end