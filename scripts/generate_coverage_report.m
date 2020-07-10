%%
%This function is to set the configuration settings for MCDC coverage for
%EntireSystem
%%
function  generate_coverage_report(cov_enable)
model = dir('*_MIL_Test.slx');
% open_system(model.name);
load_system(model.name);

if cov_enable
    
    set_param(gcs,'CovScope','EntireSystem')
    set_param(gcs,'CovMetricSettings','m')
    set_param(gcs,'CovMetricStructuralLevel','MCDC');
    
    set_param(gcs,'RecordCoverage','on')
    set_param(gcs,'CovHtmlReporting','on');
    set_param(gcs,'CovSaveCumulativeToWorkspaceVar','on');
    
    set_param(gcs,'CovCumulativeReport','on')
    set_param(gcs,'CovCumulativeVarName','covCumulativeData')
    set_param(gcs,'CovHTMLOptions','-sRT=1')
%     close_system(model.name);
else
    load_system(model.name);
    set_param(gcs,'RecordCoverage','off')
    set_param(gcs,'CovHtmlReporting','off');
    set_param(gcs,'CovSaveCumulativeToWorkspaceVar','off');
%     close_system(model.name);

end
save_system(model.name);
close_system(model.name);
end