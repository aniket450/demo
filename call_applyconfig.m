function [ret]=call_applyconfig()
try
    addpath('D:\Aniket\Sample_models')
    apply_config_setting()
catch
    disp('Erro in calling function')
end
