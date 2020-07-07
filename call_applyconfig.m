function [ret]=call_applyconfig()
try
    addpath('D:\Aniket\Sample_modelss')
    apply_config_setting()
catch
    disp('Erro in calling function')
end
