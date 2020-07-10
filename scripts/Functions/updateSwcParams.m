function updateSwcParams()

mdlBlk = find_system(bdroot(gcs),'MaskType','Software Component Subsystem');

set_param(mdlBlk{1}, 'libVer', get_param(bdroot(gcs),'ModelVersion'))
set_param(mdlBlk{1}, 'swDescription', get_param(bdroot(gcs),'Description'))
set_param(mdlBlk{1}, 'Description', get_param(bdroot(gcs),'Description'))
set_param(mdlBlk{1}, 'logEntry', get_param(bdroot(gcs),'ModifiedComment'))

if ~isempty(get_param(bdroot(gcs),'DataDictionary'))
    set_param(mdlBlk{1}, 'DataDictionary', get_param(bdroot(gcs),'DataDictionary'))
end
