%function Updated_write_testvector(test_plan_excel, testvector_excel)
function update_testvector(varargin)


if nargin == 1
    caller = varargin;
else
    caller = 'CI';
end
print_logdata('Updating the Test Vector for the latest Test Plan  ');

% clear
param_col_number = 5;  % parameter
in_col_number = 6;     %inputs
out_col_number = 7;    % expected o/p column no.
test_plan_sheet = 'Report';  % to find Report sheet in testplan excel;
test_plan_interface = 'Interface';

if strcmp(caller, 'GUI')
    wait_bar_status = waitbar(0,'Please Wait... Test Vector is updating.');
end
test_plan_excel = dir('*_TestPlan.xls');
testvector_excel = dir('*_TestVector.xlsm');

if (length(test_plan_excel) > 1)
    error('More than one test plan found');
elseif(length(testvector_excel) > 1)
    error('More than one test vector found');
end

testvector_excel = testvector_excel.name;
test_plan_excel = test_plan_excel.name;
fileattrib(testvector_excel, '+w');

% Delete if any sheet present, other than default sheet %
[~,sheet_info_tv] = xlsfinfo(testvector_excel);

for delete_sheet_i = 2 : length(sheet_info_tv)
    [~,~,raw_data_delete] = xlsread(testvector_excel,sheet_info_tv{delete_sheet_i});
    [raw_data_delete{:,:}] = deal('');
    xlswrite(testvector_excel, raw_data_delete, sheet_info_tv{delete_sheet_i});
end

excel = actxserver('Excel.Application');

excel.Workbooks.Open([pwd,'\',testvector_excel]); % Full path is necessary!

for delete_sheet_i = 2 : length(sheet_info_tv)
    try
        excel.ActiveWorkbook.Worksheets.Item([sheet_info_tv{delete_sheet_i}]).Delete;
    catch
        %do nothing
        pass = 1;
    end
end
excel.ActiveWorkbook.Save;
excel.ActiveWorkbook.Close;
excel.Quit;
excel.delete;


%% extract the interface shaeet data from test plan
[~, sheet_info] = xlsfinfo(test_plan_excel);
find_report_interface = regexpi(sheet_info, test_plan_interface, 'Match');
find_report_interface = cellfun(@isempty,find_report_interface);
find_interface_sheet_idx = find_report_interface == 0;
get_sheet_name_interface = sheet_info{find_interface_sheet_idx};

[~,~,raw_data_interface_temp] = xlsread(test_plan_excel,get_sheet_name_interface);
raw_data_interface = raw_data_interface_temp(2 : end, :);

for interface_cor =1:length(raw_data_interface)
    interface.(raw_data_interface{interface_cor,1}).scalling = raw_data_interface{interface_cor, 3};
    interface.(raw_data_interface{interface_cor,1}).offset = raw_data_interface{interface_cor, 4};
end

assignin('base','interface',interface);
%%

% get sheet report from test plan file
find_report_sheet = regexpi(sheet_info, test_plan_sheet, 'Match');
find_report_sheet = cellfun(@isempty,find_report_sheet);
find_report_sheet_idx = find_report_sheet == 0;
get_sheet_name = sheet_info{find_report_sheet_idx};

[~,~,raw_data_temp] = xlsread(test_plan_excel,get_sheet_name);
raw_data = raw_data_temp(6 : end, :);
testcase_itr = 1;

% default values read
default_input_values_prev = struct;
default_output_values_prev = struct;
[default_input_values] = create_testvector_struct(raw_data_temp{5 ,in_col_number},'Default_values', raw_data_temp{5,param_col_number},default_input_values_prev);
default_input_values_prev = default_input_values;

[~, ~, raw_data_tv_temp] = xlsread(testvector_excel);
[~,sheet_info_tv] = xlsfinfo(testvector_excel);
for i1 = 1 : size(raw_data,1)
    print_logdata(strcat('Updating the Test Vector for the latest Test Plan TC ID : ', num2str(i1)))
    read_row_data = raw_data(i1,:);
    
    TestID = read_row_data{1,1};
    TestID = strrep(TestID,' ' ,'');
    
    extract_inp_data = read_row_data{1,in_col_number};
    extract_out_data = read_row_data{1,out_col_number};
    extract_parameter_data = read_row_data{1,param_col_number};
    
    if ~strcmp(extract_inp_data, 'NA')
        [TestCase_inp1] = create_testvector_struct(extract_inp_data, TestID, extract_parameter_data,default_input_values_prev);
        fieldnames_info = fieldnames(TestCase_inp1);
        filedname_info_default = fieldnames(default_input_values);
        
        for main_x = 1 : length(TestCase_inp1)
            default_input_values_tc(main_x) = default_input_values;
            for x=3:length(fieldnames_info) - 1
                pos_field = find(strcmp(filedname_info_default,fieldnames_info(x)));
                if(pos_field)
                    default_input_values_tc(main_x).(filedname_info_default{pos_field}) = char(TestCase_inp1(main_x).(cell2mat(fieldnames_info(x))));
                else
                    error('singal mentioned in the test case is different than default');
                end
            end
        end
        %         if(i1 == 1)
        for x=1:length(filedname_info_default)
            tv_signal_to_plot.(TestID).(cell2mat(filedname_info_default(x))) = 0;
        end
        %         end
        
        for x=3:length(fieldnames_info) - 1
            pos_field = find(strcmp(filedname_info_default,fieldnames_info(x)));
            if(pos_field)
                tv_signal_to_plot.(TestID).(filedname_info_default{pos_field}) = 1;
            else
                error('singal mentioned in the test case is different than default');
            end
        end
        %      tv_signal_to_plot_main(i1) = tv_signal_to_plot;
        
        if ~strcmp(extract_out_data, 'NA')
            [TestCase_out1] = create_testvector_struct(extract_out_data, TestID, extract_parameter_data,default_output_values_prev);
            add_test_vector_sheet(testvector_excel,raw_data_tv_temp,TestCase_out1,strcat(sheet_info_tv(1,1),'_',num2str(i1))); % need to chech sheet_info_tv(1,1)
        end
        
        for testcase_i = 1 : length(TestCase_inp1)
            [~, ~, raw_data_tv_tmp] = xlsread(testvector_excel,cell2mat(strcat(sheet_info_tv(1,1),'_',num2str(i1)))); % need to chech sheet_info_tv(1,1)
            [raw_data_tv_tmp{5:end,:}] = deal('');
            raw_data_tv_tmp = update_raw_data(raw_data_tv_tmp,default_input_values,'Default');
            raw_data_tv_tmp = update_raw_data(raw_data_tv_tmp, default_input_values_tc,'TC_data');
            raw_data_tv_tmp = update_raw_data(raw_data_tv_tmp, TestCase_out1,'TC_data');
            raw_data_tv_tmp = update_resolution_units(raw_data_tv_tmp, raw_data_interface_temp);
            xlswrite(testvector_excel,raw_data_tv_tmp,cell2mat(strcat(sheet_info_tv(1,1),'_',num2str(i1)))); % need to chech sheet_info_tv(1,1)
            testcase_itr = testcase_itr + 1;
        end
    end
    
    clear default_input_values_tc;
    if strcmp(caller, 'GUI')
        waitbar(i1/size(raw_data,1),wait_bar_status);
    end
end

tv_signal_to_plot_base = tv_signal_to_plot;
assignin('base','tv_signal_to_plot_base',tv_signal_to_plot_base);


excel_format(testvector_excel)  % applying text format to all sheets.
fileattrib(testvector_excel, '-w');
if strcmp(caller, 'GUI')
    close(wait_bar_status);
    helpdlg('TectVector is updated sucessfully');
end
status = 1;
print_logdata('TectVector is updated sucessfully, Please exceute the test');

end

function add_test_vector_sheet(testvector_excel,raw_data_tv_temp,TestCase_out1, sheetname)

[row_nbr,col_nbr] = size(raw_data_tv_temp);

out_sig_names = fieldnames(TestCase_out1);

%out_sig_names = out_sig_names(3:end-1,:);


param_col = find(strcmp(raw_data_tv_temp(2,:),'Parameter'));
for i=3:length(out_sig_names)-1
    param_col = param_col+1;
    raw_data_tv_temp(2,param_col) = strcat('out_',out_sig_names(i),'_exp');
    param_col = param_col+1;
    raw_data_tv_temp(2,param_col) = strcat('out_',out_sig_names(i),'_mil_act');
    param_col = param_col+1;
    raw_data_tv_temp(2,param_col) = strcat(out_sig_names(i),'_mil_result');
    param_col = param_col+1;
    raw_data_tv_temp(2,param_col) = strcat('out_',out_sig_names(i),'_sil_act');
    param_col = param_col+1;
    raw_data_tv_temp(2,param_col) = strcat(out_sig_names(i),'_sil_result');
end

xlswrite(testvector_excel,raw_data_tv_temp, cell2mat(sheetname));
end

function raw_data = update_raw_data(raw_data_temp, TestCase_inp, type_of_data)

Test_ye = 'Testability';
header_row = 2;
if(strcmp(type_of_data,'Default'))
    Write_index = 5;
else
    Write_index = 6;
end
if ~isempty(TestCase_inp)
    fieldnames_info = fieldnames(TestCase_inp);
    find_testability = strcmp(Test_ye,raw_data_temp(header_row,:)) == 1;
    get_field_testcase = fieldnames_info(1);
    get_field_sim_time = fieldnames_info(2);
    get_field_tc_idx = find(strcmp(get_field_testcase,raw_data_temp(header_row,:)) == 1, 1);
    get_field_sim_time_idx = find(strcmp(get_field_sim_time,raw_data_temp(header_row,:)) == 1, 1);
    for field_i = 1 : length(TestCase_inp)
        raw_data_temp{Write_index, find_testability}  = 'YES';
        Extract_data_info = TestCase_inp(field_i);
        
        raw_data_temp{Write_index, get_field_tc_idx} = char(Extract_data_info.(cell2mat(fieldnames_info(1))));
        raw_data_temp{Write_index, get_field_sim_time_idx} = char(Extract_data_info.(cell2mat(fieldnames_info(2))));
        
        for extr_data_itr = 3 : length(fieldnames_info)
            get_field = fieldnames_info{extr_data_itr};
            if any(strcmp(strcat('in_',get_field),raw_data_temp(header_row,:)))
                get_field_idx = strcmp(strcat('in_',get_field),raw_data_temp(header_row,:)) == 1;
                raw_data_temp{Write_index, get_field_idx} = char(Extract_data_info.(cell2mat(fieldnames_info(extr_data_itr))));
            elseif any(strcmp(strcat('out_',get_field,'_exp'),raw_data_temp(header_row,:)))
                get_field_idx =  strcmp(strcat('out_',get_field,'_exp'),raw_data_temp(header_row,:)) == 1;
                raw_data_temp{Write_index, get_field_idx} = char(Extract_data_info.(cell2mat(fieldnames_info(extr_data_itr))));
            elseif any(strcmp(get_field,raw_data_temp(header_row,:)))
                get_field_idx =  strcmp(get_field,raw_data_temp(header_row,:)) == 1;
                raw_data_temp{Write_index, get_field_idx} = char(Extract_data_info.(cell2mat(fieldnames_info(extr_data_itr))));
            end
        end
        Write_index  = Write_index + 1;
    end
    raw_data = raw_data_temp;
else
    raw_data = raw_data_temp;
end
end

function raw_data_update = update_resolution_units(raw_data_tv_tmp, raw_data_interface_temp)

rawdata_header_row = 2;
rawdata_units_row = 3;
rawdata_resolution_row = 4;

interface_resolution_column = 5;
interface_units_column = 6;

in_pat = 'in_';
out_pat = 'out_';
out_exp = '_exp';
out_act = '_act';
Result = '_result';

for m = 1 : length(raw_data_tv_tmp(rawdata_header_row,:))
    header_name = raw_data_tv_tmp{rawdata_header_row, m};
    %     if_mat_data_col = ~isempty((regexp(header_name,in_pat, 'start'))) ||  ...
    (~isempty(regexp(header_name,out_pat, 'start')) && ~isempty(regexp(header_name,out_exp, 'end'))) ||...
        (strcmp(header_name,'Parameter'));
    %             if if_mat_data_col
    if strcmp(header_name, 'Parameter')
        raw_data_tv_tmp{rawdata_units_row, m} = 'NA';
        raw_data_tv_tmp{rawdata_resolution_row, m} = 'NA';
    else
        for n = 1 : length(raw_data_interface_temp(:,1))
            interface_haeder = raw_data_interface_temp{n, 1};
            if strcmp(header_name, strcat(in_pat, interface_haeder))
                raw_data_tv_tmp{rawdata_units_row, m} = raw_data_interface_temp{n, interface_units_column};
                raw_data_tv_tmp{rawdata_resolution_row, m} = raw_data_interface_temp{n, interface_resolution_column};
            elseif strcmp(header_name, strcat(out_pat, interface_haeder, out_exp))
                raw_data_tv_tmp{rawdata_units_row, m} = raw_data_interface_temp{n, interface_units_column};
                raw_data_tv_tmp{rawdata_resolution_row, m} = raw_data_interface_temp{n, interface_resolution_column};
            elseif strcmp(header_name, strcat(out_pat, interface_haeder, '_mil', out_act)) || strcmp(header_name, strcat(out_pat, interface_haeder, '_sil', out_act))
                raw_data_tv_tmp{rawdata_units_row, m} = raw_data_interface_temp{n, interface_units_column};
                raw_data_tv_tmp{rawdata_resolution_row, m} = raw_data_interface_temp{n, interface_resolution_column};
            elseif strcmp(header_name, strcat(interface_haeder, '_mil', Result)) || strcmp(header_name, strcat(interface_haeder, '_sil', Result))
                raw_data_tv_tmp{rawdata_units_row, m} = 'P/F';
                raw_data_tv_tmp{rawdata_resolution_row, m} = 'NA';
            end
            
        end
    end
    %             end
end

raw_data_update = raw_data_tv_tmp;
end
