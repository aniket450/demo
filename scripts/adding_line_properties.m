
function adding_line_properties

% this function sets a data logging property for the line from convert block

find_datatype_blck = find_system(bdroot,'SearchDepth',1,'BlockType','DataTypeConversion');
for conv_i = 1 : length(find_datatype_blck)
    blck_port_handls = get_param(find_datatype_blck{conv_i,1},'PortHandles'); %get data of port handles  
    blck_line_info = get_param(blck_port_handls.Outport,'Line');  % extract line info for each block
   
    blck_name = get_param(find_datatype_blck{conv_i,1},'Name');  % extract block name
    sig_name = strsplit(blck_name,'_conv');  % split by "_conv" (common name added when created test harness).
    set_param(blck_line_info,'Name',['in_' sig_name{1,1}]);
    %%
    log_port_info = blck_port_handls.Outport;   %extract line port info of outport from convert block
    set_param(log_port_info, 'DataLogging', 'on');  %set property for Data Logging
end
end