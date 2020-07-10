function [validation_type] = find_validation_type(extrac_data)

if isa(extrac_data, 'char')
    find_open_chara = split(extrac_data ,'(');
    if strcmp(find_open_chara{1}, 'trigger')
        validation_type.type = 2;
        validation_type.name = find_open_chara{1};
        find_close_chara = split(find_open_chara{2} ,')')';
        find_comma_char = split(find_close_chara{1},',');
        validation_type.trigger_value = str2double(find_comma_char{1});
        validation_type.trigger_point = str2double(find_comma_char{2});
        validation_type.time_period = 0;
        
    elseif strcmp(find_open_chara{1}, 'pulse')
        validation_type.type = 3;
        validation_type.name = find_open_chara{1};
        find_close_chara = split(find_open_chara{2} ,')')';
        find_comma_char = split(find_close_chara{1},',');
        validation_type.trigger_value = str2double(find_comma_char{1});
        validation_type.trigger_point = str2double(find_comma_char{2});
        validation_type.time_period = str2double(find_comma_char{3});
    elseif strcmp(find_open_chara{1}, 'rampup')
        validation_type.type = 4;
        validation_type.name = find_open_chara{1};
        find_close_chara = split(find_open_chara{2} ,')')';
        find_comma_char = split(find_close_chara{1},',');
        validation_type.trigger_value = str2double(find_comma_char{1});
        validation_type.trigger_point = str2double(find_comma_char{2});
        validation_type.time_period = 0;
    elseif strcmp(find_open_chara{1}, 'rampdown')
        validation_type.type = 5;
        validation_type.name = find_open_chara{1};
        find_close_chara = split(find_open_chara{2} ,')')';
        find_comma_char = split(find_close_chara{1},',');
        validation_type.trigger_value = str2double(find_comma_char{1});
        validation_type.trigger_point = str2double(find_comma_char{2});
        validation_type.time_period = 0;
        
    elseif strcmp(find_open_chara{1}, 'Manual_Varification')
        validation_type.type  = 6;
        validation_type.name = find_open_chara{1};
        validation_type.trigger_value = 0;
        find_close_chara = split(find_open_chara{2} ,')')';
        validation_type.trigger_point = str2double(find_close_chara{1});
        validation_type.time_period = 0;
        
    else
        validation_type.type  = 1;
        validation_type.name = 'Nan';
        validation_type.trigger_value = 0;
        validation_type.trigger_point = 0;
        validation_type.time_period = 0;
    end
else
    validation_type.type  = 1;
    validation_type.trigger_value = 0;
    validation_type.trigger_point = 0;
    validation_type.time_period = 0;
    validation_type.name = 'Nan';
end

end
