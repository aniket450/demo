function [TestCase] = create_testvector_struct(extract_inp_data, TestID, extract_parameter_data,default_input_values_prev)
TestVet_Struct_Index = 1;
split_newline_inp = (strsplit(extract_inp_data,'\n'));
if isempty(split_newline_inp{end})
    split_newline_inp = split_newline_inp(1 : end - 1);
end

split_newline_cell = {split_newline_inp};
remvoe_space = cellfun(@(s) strrep(s, ' ', ''), split_newline_cell, 'UniformOutput', false); % remove space
pat = {'='}; % pattern to split
split_equal = cellfun(@split, remvoe_space, pat, 'UniformOutput', false);
get_ts = split_equal{:,:,1}(1);
if strcmp(get_ts, 'ts')
    timets = get_ts;
    compare_ts = cellfun(@strcmp, split_equal, {timets}, 'UniformOutput', false);
    
    extract_ts_index = find(compare_ts{:,:,1} == 1);
    if extract_ts_index == 1
        data1 = split_newline_inp(extract_ts_index : end);
        [TestVect] = testvector_struct(data1, TestID, extract_parameter_data,default_input_values_prev);
        TestCase(TestVet_Struct_Index) = TestVect;
        
    else
        for i2 = 1 : length(extract_ts_index)
            if i2 == length(extract_ts_index)
                data1 = split_newline_inp(extract_ts_index(i2) : end);
            else
                data1 = split_newline_inp(extract_ts_index(i2) :(extract_ts_index(i2 + 1) - 1));
            end
            [TestVect] = testvector_struct(data1, TestID, extract_parameter_data,default_input_values_prev);
            default_input_values_prev = TestVect;
            TestCase(TestVet_Struct_Index) = TestVect;
            TestVet_Struct_Index = TestVet_Struct_Index + 1;
        end
    end
else
    error('Input and Output Cell should start with ts : Please Check ');
end
end

function [TestCase] = testvector_struct( input_args,TestID, extract_parameter_data,default_input_values_prev)
% testvector_struct Summary of this function goes here
%   Detailed explanation goes here
%
TestCase = default_input_values_prev;
TestCase.TestCase_id = TestID;
split_semicolon = split(input_args,'=');
if(~isempty(find(contains(input_args, 'rampup'))) || ~isempty(find(contains(input_args, 'rampdown'))) ||...
        ~isempty(find(contains(input_args, 'pulse'))) || ~isempty(find(contains(input_args, 'trigger'))) || ~isempty(find(contains(input_args, 'Manual_Varification'))))
    for i = 1 : length(split_semicolon)
        str_Data1 = char(strtrim(split_semicolon(:,i,1)));
        if strcmp(str_Data1,'ts')
            str_Data1 = 'sim_time';
            str_value = regexp(split_semicolon(:,i,2), '[-.0-9X]','Match');
            Value1 = cellfun(@cellstr, {str_value}, 'UniformOutput',false);
            key_value = cellfun(@cell2mat, Value1, 'UniformOutput',false);
            TestCase.(str_Data1) = key_value;
        else
            split_semicolon1 = split(char(strtrim(split_semicolon(:,i,2))), ';');
            str_value = split_semicolon1(1);
            TestCase.(str_Data1) = str_value;
        end        
    end
else
    for i = 1 : length(split_semicolon)
        str_Data1 = char(strtrim(split_semicolon(:,i,1)));
        if strcmp(str_Data1,'ts')
            str_Data1 = 'sim_time';
        end
        str_value = regexp(split_semicolon(:,i,2), '[-.0-9X]','Match');
        Value1 = cellfun(@cellstr, {str_value}, 'UniformOutput',false);
        key_value = cellfun(@cell2mat, Value1, 'UniformOutput',false);        
        TestCase.(str_Data1) = key_value;
    end
end

% parameter update
extract_parameter_info = extract_param_data(extract_parameter_data);
TestCase.('Parameter') = extract_parameter_info;

end

function [ extract_parameter_data1 ] = extract_param_data( input_args )
% extract_param_data Summary of this function goes here
%   Detailed explanation goes here

find_equal = strfind(input_args, '=');
if ~isempty(find_equal)
    str_split = (strsplit(input_args,'\n'));
    if length(str_split) > 1
        extract_parameter_data1 = {};
        for str_i = 1 : length(str_split)
            if str_i == length(str_split)
                input_args = param_remove_space(str_split{1,str_i});
                input_args(end) = [];
            else
                input_args = param_remove_space(str_split{1,str_i});
                input_args(end) = '&';
            end
            extract_parameter_data1{str_i} = input_args;
        end
        extract_parameter_data1 = cell2mat(extract_parameter_data1);
        
    else
        extract_parameter_data1 = param_remove_space(input_args);
        extract_parameter_data1(end) = [];
        
    end
else
    extract_parameter_data1 = 'Initial_Parameters';
end

end


function extract_parameter_data = param_remove_space(inp)
% remove space between equal in parameter
find_equal = split(inp, '=');
find_equal_1 = strtrim(find_equal(1));
find_equal_2 = strtrim(find_equal(2));
extract_parameter_data =  char(strcat(find_equal_1,'=',find_equal_2));

end


