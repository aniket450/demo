function varargout = MIL_Framework_GUI(varargin)
% MIL_FRAMEWORK_GUI MATLAB code for MIL_Framework_GUI.fig
%      MIL_FRAMEWORK_GUI, by itself, creates a new MIL_FRAMEWORK_GUI or raises the existing
%      singleton*.
%
%      H = MIL_FRAMEWORK_GUI returns the handle to a new MIL_FRAMEWORK_GUI or the handle to
%      the existing singleton*.
%
%      MIL_FRAMEWORK_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIL_FRAMEWORK_GUI.M with the given input arguments.
%
%      MIL_FRAMEWORK_GUI('Property','Value',...) creates a new MIL_FRAMEWORK_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MIL_Framework_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MIL_Framework_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MIL_Framework_GUI

% Last Modified by GUIDE v2.5 21-Aug-2019 15:37:16

% Begin initialization code - DO NOT EDIT
clc;
check_scriptdir = dir('**/*perform_test.m');

if ~isempty(check_scriptdir)
    check_scriptdir_path = check_scriptdir.folder;
    addpath(check_scriptdir_path);
    addpath(strcat(check_scriptdir_path, '\grafics'));
    try
        addpath(strcat(check_scriptdir_path, '\Library'));
        addpath(strcat(check_scriptdir_path, '\Library\code'));
    catch
        pass
    end
    addpath(cd);
end
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MIL_Framework_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @MIL_Framework_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MIL_Framework_GUI is made visible.
function MIL_Framework_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MIL_Framework_GUI (see VARARGIN)

% Choose default command line output for MIL_Framework_GUI
handles.output = hObject;


ltts_icon = imread('ltts.jpg');
axes(handles.axes1);
imshow(ltts_icon);

mdl_icon = imread('opensimulink.png');
axes(handles.axes3);
imshow(mdl_icon);

xl_icon = imread('excel_icon.png');
axes(handles.axes4);
imshow(xl_icon);

axes(handles.axes5);
imshow(xl_icon);

assignin('base','log_data_gui', handles);
set(handles.model_name,'String', '');
% set(handles.inputmodel, 'String', '');
set(handles.modelin_name1,'String', '');
% set(handles.tolre_value, 'Enable', 'off');
% set(handles.tolre_value, 'String', '');
set(handles.TestPlan_edit,'String', '');
print_logdata( 'Default Testing method:---> "Model In Loop"');
print_logdata('Please select the testable software Model');
set(handles.Testvector_edit,'String', '');
set(handles.Execute_btn,'Enable','off');
set(handles.test_plan_open,'Enable', 'off');
set(handles.test_vector_open,'Enable', 'off');
set(handles.Model_btn, 'Enable', 'off');
set(handles.create_test_harness, 'Enable', 'off');
% pop_cell = {'1'};
% set(handles.testing_ids,'String', pop_cell);
% button group mil type testing
set(handles.cumulative_execu,'Enable', 'off');
set(handles.requirement_execu,'Enable', 'off');
set(handles.test_case_execu,'Enable', 'off');
set(handles.testing_ids,'Enable','off');
set(handles.test_id,'Enable','off');
set(handles.testcase_id,'Enable','off');
set(handles.testcase_ids,'Enable','off');
set(handles.plot_execu,'Enable','off');
set(handles.coverage_check, 'Enable', 'off');
set(handles.update_data, 'Enable', 'off');
set(handles.Test_model, 'Enable', 'on');
set(handles.Testplan, 'Enable', 'on');
set(handles.Testvector, 'Enable', 'on');
set(handles.sil_action, 'Enable', 'off');
set(handles.Test_model, 'Enable', 'off');
set(handles.Testplan, 'Enable', 'off');
set(handles.Testvector, 'Enable', 'off');

VV_toolbox = ver;
handles.index_vv = find(strcmp({VV_toolbox.Name}, 'Simulink Verification and Validation')==1);

handles.current_testmethod = 'MIL';
current_test = 'Cumulative';
handles.current_test = current_test;
handles.coverage_check_val = 0;  %initial coverage check value is 0
handles.mil_cumulative = 0;
handles.testplan_changetime = 'None';

guidata(hObject, handles);

% UIWAIT makes MIL_Framework_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MIL_Framework_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_testtype.
function listbox_testtype_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_testtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_testtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_testtype

contents = cellstr(get(hObject,'String'));
contents_value = get(hObject,'Value');
g = contents{contents_value};
if(ne(g,0))
    set(handles.Logdata_edit,'String', 'Select the model');
end
switch contents_value
    case 2
        execute_mil_test = g;
        
        % perform_mil_test;
    case 3
        execute_mil_test = g;
        
        
    case 4
        execute_mil_test = g;
        
end
handles.execute_mil_test = execute_mil_test;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox_testtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_testtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TestPlan_edit_Callback(hObject, eventdata, handles)
% hObject    handle to TestPlan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TestPlan_edit as text
%        str2double(get(hObject,'String')) returns contents of TestPlan_edit as a double


% --- Executes during object creation, after setting all properties.
function TestPlan_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TestPlan_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Testvector_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Testvector_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Testvector_edit as text
%        str2double(get(hObject,'String')) returns contents of Testvector_edit as a double


% --- Executes during object creation, after setting all properties.
function Testvector_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Testvector_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% function Resolution_edit_Callback(hObject, eventdata, handles)
% % hObject    handle to Resolution_edit (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of Resolution_edit as text
% %        str2double(get(hObject,'String')) returns contents of Resolution_edit as a double
% 
% tolre_value = str2double(get(hObject,'String'));
% 
% handles.tolre_value = tolre_value;
% 
% guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Resolution_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Resolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Execute_btn.
function Execute_btn_Callback(hObject, eventdata, handles)

% hObject    handle to Execute_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% addpath('MIL_Scripts');
test_plan_excel = handles.test_plan_excel;

testplan_details = dir(test_plan_excel);

if ~strcmp(testplan_details.date, handles.testplan_changetime)
    set(handles.sil_action, 'Enable', 'off');
    
    set(handles.test_case_execu,'Enable', 'off');
    set(handles.requirement_execu,'Enable', 'off');
    set(handles.cumulative_execu,'Enable', 'off');
    set(handles.testing_ids,'Enable','off');
    set(handles.test_id,'Enable','off');
    set(handles.testcase_ids,'Enable','off');
    set(handles.testcase_id,'Enable','off');
    set(handles.Execute_btn,'Enable','off');
    if strcmp(handles.current_testmethod, 'MIL')
        set(handles.update_data,'Enable','on');
        print_logdata('Test Plan seems modified. Please update Test Vector before test execution');
    elseif strcmp(handles.current_testmethod, 'SIL')
        print_logdata('Test Plan seems modified. Please select "MIL" test and update Test Vector before test execution');
    end
else
    
    pathName = handles.pathName;
    current_test = handles.current_test;
    current_gui_dir = handles.current_gui_dir;
    
    cd(pathName);
%     close all;
    if strcmp(current_test, 'Requirement')
        tofind = 'SW.';
        req_testcase_id_check = replace(handles.req_ids_initial,tofind,'');
        if strcmp(handles.current_testmethod, 'MIL')
            generate_coverage_report(0);
            test_requirement_id(str2double(req_testcase_id_check), 'mil');
        elseif strcmp(handles.current_testmethod, 'SIL')
            test_requirement_id(str2double(req_testcase_id_check), 'sil');
        end
    elseif strcmp(current_test, 'Test Case')
        tofind = 'TC_';
        req_testcase_id_check = replace(handles.tc_ids_initial,tofind,'');
        if strcmp(handles.current_testmethod, 'MIL')
            generate_coverage_report(0);
            test_testcase_id(str2double(req_testcase_id_check), 'mil');
        elseif strcmp(handles.current_testmethod, 'SIL')
            test_testcase_id(str2double(req_testcase_id_check), 'sil');
        end
    elseif strcmp(current_test, 'Cumulative')
        if strcmp(handles.current_testmethod, 'MIL')
            generate_coverage_report(handles.coverage_check_val);
            perform_test('mil', 'GUI');
            set(handles.sil_action, 'Enable', 'on');
            handles.mil_cumulative = 1;
        elseif strcmp(handles.current_testmethod, 'SIL')
            perform_test('sil', 'GUI');
        end
    end
    cd(current_gui_dir);
end
guidata(hObject,handles);

function Logdata_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Logdata_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Logdata_edit as text
%        str2double(get(hObject,'String')) returns contents of Logdata_edit as a double


% --- Executes during object creation, after setting all properties.
function Logdata_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Logdata_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    disp('logdata');
end



% --- Executes on button press in Model_btn.
function Model_btn_Callback(hObject, eventdata, handles)
% hObject    handle to Model_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% initial setting

open_system(handles.testmodel_slx);

guidata(hObject,handles);



function model_name_Callback(hObject, eventdata, handles)
% hObject    handle to model_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of model_name as text
%        str2double(get(hObject,'String')) returns contents of model_name as a double


% --- Executes during object creation, after setting all properties.
function model_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in test_plan_open.
function test_plan_open_Callback(hObject, eventdata, handles)
% hObject    handle to test_plan_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

test_plan_excel = handles.test_plan_excel;
testplan_details = dir(test_plan_excel);

handles.testplan_changetime = testplan_details.date;

winopen(test_plan_excel);

guidata(hObject,handles);

function help_btn_Callback(hObject, eventdata, handles)
% hObject    handle to test_plan_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

work_flow = dir('**/*MIL tesing Framework.pdf');


winopen(strcat(work_flow.folder, '\', work_flow.name));

guidata(hObject,handles);

% --- Executes on button press in test_vector_open.
function test_vector_open_Callback(hObject, eventdata, handles)
% hObject    handle to test_vector_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

testvector_excel = handles.testvector_excel;

winopen(testvector_excel);

guidata(hObject,handles);


% --- Executes on button press in plot_execu.
function plot_execu_Callback(hObject, eventdata, handles)
% hObject    handle to plot_execu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_execu
plot_option = get(hObject,'Value');

handles.plot_option = plot_option;
guidata(hObject,handles);


% --- Executes on button press in Coverage_check.
function coverage_check_Callback(hObject, eventdata, handles)
% hObject    handle to coverage_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plot_execu
cov = get(hObject,'Value');

handles.coverage_check_val = cov;
guidata(hObject,handles);

function testmethod_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in execution_group
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.current_testmethod = eventdata.NewValue.String;
if strcmp(handles.current_testmethod, 'MIL')
    print_logdata( 'Selected Testing method:---> "Model In Loop"');
else
    print_logdata( 'Selected Testing method:---> "Software In Loop"');
end
    
try
    [handles] = process_data_files(hObject, eventdata, handles);
catch
    %nothing
end



guidata(hObject,handles);

% --- Executes when selected object is changed in execution_group.
function execution_group_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in execution_group
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

test_plan_excel = handles.test_plan_excel;
current_test = eventdata.NewValue.String;


%default set all to 'off'
set(handles.coverage_check, 'Enable', 'off');
set(handles.testing_ids,'Enable','off');
set(handles.testcase_ids,'Enable','off');
set(handles.plot_execu,'Enable','off');
set(handles.test_id,'Enable','off');
set(handles.testcase_id,'Enable','off');
handles.current_test = current_test;

testplan_details = dir(test_plan_excel);




if(strcmp(current_test, 'Cumulative'))
    print_logdata('Selected Testing Type :-->  "Cumulative Testing"');
    VV_toolbox = ver;
    index_vv = find(strcmp({VV_toolbox.Name}, 'Simulink Verification and Validation')==1);
    if(~isempty(index_vv))
        set(handles.coverage_check, 'Enable', 'on');    
        
    end
elseif(strcmp(current_test,'Requirement') || strcmp(current_test,'Test Case'))
    
%     set(handles.testing_ids,'String', '');
    
    [~, ~, test_plan_raw] = xlsread(test_plan_excel,'Traceability');
    
    %ToDo: remove hard coded
    req_nbrs = test_plan_raw(2,2:end);
    test_case_id = test_plan_raw(3:end-2,1);
    
    %remove all NaN from cell array list
    req_nbrs(cellfun(@(test_case_req) any(isnan(test_case_req)),req_nbrs)) = [];
    test_case_id(cellfun(@(test_case_id) any(isnan(test_case_id)),test_case_id)) = [];
    
    %gather req ids with prefix
    soft_req = 'SW.';
    req_id_nbrs_only = split(req_nbrs,'.');
    req_id_nbrs_only = req_id_nbrs_only(:,:,end);
    req_ids_with_prefix = strcat(soft_req,req_id_nbrs_only);
    %gather test case ids ids with prefix
    test_case = 'TC_';
    test_case_nbr_only = split(test_case_id,test_case);
    tc_ids_with_prefix = strcat(test_case,test_case_nbr_only(:,2));
    
    if(strcmp(current_test,'Requirement') && (length(req_ids_with_prefix)>1))
        set(handles.testing_ids,'String', req_ids_with_prefix);
        set(handles.testing_ids,'Enable','on');
        set(handles.test_id,'Enable','on');
        print_logdata('Selected Testing Type :-->  "Requirement Based"');

        handles.req_ids_initial = req_ids_with_prefix(handles.testing_ids.Value);
    elseif(strcmp(current_test,'Test Case') && (length(tc_ids_with_prefix)>1))
        set(handles.testcase_ids,'String', tc_ids_with_prefix);
        set(handles.testcase_ids,'Enable','on');
        set(handles.testcase_id,'Enable','on');
        print_logdata('Selected Testing Type :-->  "Test Case Based"');
%         set(handles.plot_execu,'Enable','on');
        handles.tc_ids_initial = tc_ids_with_prefix(handles.testing_ids.Value);
    
    end
    
    handles.test_plan_raw = test_plan_raw;
end

if ~strcmp(testplan_details.date, handles.testplan_changetime)
    set(handles.sil_action, 'Enable', 'off');
    set(handles.test_case_execu,'Enable', 'off');
    set(handles.requirement_execu,'Enable', 'off');
    set(handles.cumulative_execu,'Enable', 'off');
    set(handles.testing_ids,'Enable','off');
    set(handles.test_id,'Enable','off');
    set(handles.testcase_ids,'Enable','off');
    set(handles.testcase_id,'Enable','off');
    set(handles.Execute_btn,'Enable','off');
    if strcmp(handles.current_testmethod, 'MIL')
        set(handles.update_data,'Enable','on');
        print_logdata('Test Plan seems modified. Please update Test Vector before test execution');
    elseif strcmp(handles.current_testmethod, 'SIL')
        print_logdata('Test Plan seems modified. Please select "MIL" test and update Test Vector before test execution');
    end
end

guidata(hObject,handles);

% --- Executes on selection change in testing_ids.
function testing_ids_Callback(hObject, eventdata, handles)
% hObject    handle to testing_ids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns testing_ids contents as cell array
%        contents{get(hObject,'Value')} returns selected item from testing_ids

current_test = handles.current_test;
contents = cellstr(get(hObject,'String'));
req_testcase_id = get(hObject,'Value');


    req_id_check = contents{req_testcase_id};
    handles.req_ids_initial = req_id_check;


handles.req_id = req_testcase_id;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function testing_ids_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testing_ids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function testcase_ids_Callback(hObject, eventdata, handles)
% hObject    handle to testing_ids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns testing_ids contents as cell array
%        contents{get(hObject,'Value')} returns selected item from testing_ids

current_test = handles.current_test;
contents = cellstr(get(hObject,'String'));
req_testcase_id = get(hObject,'Value');

    req_testcase_id_check = contents{req_testcase_id};
    handles.tc_ids_initial = req_testcase_id_check;


handles.req_testcase_id = req_testcase_id;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function testcase_ids_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testing_ids (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function modelin_name1_Callback(hObject, eventdata, handles)
% hObject    handle to modelin_name1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modelin_name1 as text
%        str2double(get(hObject,'String')) returns contents of modelin_name1 as a double


% --- Executes during object creation, after setting all properties.
function modelin_name1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modelin_name1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in in_model_btn.
function in_model_btn_Callback(hObject, eventdata, handles)

[model_file_name,model_path] = uigetfile('*.slx');

% check if model is seleceted from the window
if (isequal(model_file_name,0) && isequal(model_path,0))
    set(handles.Logdata_edit,'String','Please select the model');
else
    [~, model_name_only, ~] = fileparts(model_file_name);
    print_logdata(strcat('Model selected -> ',model_name_only),'clear_log');
    if strcmp(handles.current_testmethod, 'MIL')
        print_logdata( 'Selected Testing method:---> "Model In Loop"');
    else
        print_logdata( 'Selected Testing method:---> "Software In Loop"');
    end
    if(strcmp(handles.current_test, 'Cumulative'))
        print_logdata('Selected Testing Type :-->  "Cumulative Testing"');
    elseif(strcmp(handles.current_test, 'Requirement'))
        print_logdata('Selected Testing Type :-->  "Requirement based Testing"');
    elseif(strcmp(handles.current_test, 'Test Case'))
        print_logdata('Selected Testing Type :-->  "Test Case based Testing"');
    end
    set(handles.modelin_name1,'String', model_name_only);
    
    current_gui_dir = pwd;
    handles.current_gui_dir = current_gui_dir;
    handles.pathName = model_path;
    handles.caller_fcn = 1;
    [handles]= process_data_files(hObject, eventdata, handles);
end
guidata(hObject,handles);

% --- Executes on button press in create_test_harness.
function create_test_harness_Callback(hObject, eventdata, handles)
% hObject    handle to create_test_harness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%ToDo: make this global
default_tollereance = '0.0000001';

print_logdata('Test Environment is creating, Please wait...... ');
waitbar_status  = waitbar(0, 'Please wait Test Environment is creating');
test_harness_present = 0;
try
    while(~test_harness_present)
        cd (handles.pathName)
        if strcmp(handles.current_testmethod, 'MIL')
            [model_name, in_port_names, out_port_names] = generate_test_harness();
            create_testvector(model_name, in_port_names, out_port_names, handles.current_gui_dir, handles.pathName);
            create_testplan(model_name, handles.current_gui_dir, handles.pathName)
            test_harness_present = 1;
            
        elseif strcmp(handles.current_testmethod, 'SIL')
            sil_setup();
            test_harness_present = 1;
        end
        cd (handles.current_gui_dir)
    end
    if(test_harness_present)
        [handles] = process_data_files(hObject, eventdata, handles);
        test_vector_file = dir(fullfile(handles.pathName,'*_TestVector.xlsm'));
        test_plan_file = dir(fullfile(handles.pathName,'*_TestPlan.xls'));
        if strcmp(handles.current_testmethod, 'MIL')
            test_harness_file = dir(fullfile(handles.pathName,'*_MIL_Test.slx'));
        else
            test_harness_file = dir(fullfile(handles.pathName,'*_SIL_Test.slx'));
        end
%         testplan_details = dir(test_plan_file);
        try
            handles.testplan_changetime = test_plan_file.date;
        catch
            %             doNothing
        end
        
        set(handles.model_name,'String', test_harness_file.name);
        set(handles.TestPlan_edit,'String', test_plan_file.name);
        set(handles.Testvector_edit,'String', test_vector_file.name);
%         set(handles.tolre_value, 'String', default_tollereance);
        set(handles.Model_btn, 'Enable', 'on');
        set(handles.test_plan_open, 'Enable', 'on');
        set(handles.test_vector_open, 'Enable', 'on');
        
        set(handles.create_test_harness, 'Enable', 'off');
        set(handles.update_data, 'Enable', 'on');
        
        handles.test_plan_excel = strcat(test_plan_file.folder, '\', test_plan_file.name);
        handles.testvector_excel = test_vector_file.name;
        handles.testmodel_slx = test_harness_file.name;
    end
    waitbar(1/test_harness_present, waitbar_status)
    close(waitbar_status);
    helpdlg('Test Environment created sucessfully');
catch
    print_logdata('Test Environment creation failed');
    close(waitbar_status);
    errordlg('Test Environment creation failed');
end


% print_logdata('Test environment Created');
guidata(hObject,handles);


function update_data_Callback(hObject, eventdata, handles)
% hObject    handle to create_test_harness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%ToDo: make this global
% print_logdata('Updated the Test Vec');
handles.caller_fcn = 2;
[handles] = process_data_files(hObject, eventdata, handles);
status = 0;
% Updated_write_testvector(handles.test_plan_excel, handles.testvector_excel);
try
    if (~status)
        
        cd (handles.pathName)
        
        update_testvector('GUI');
        status = 1;
        
        cd (handles.current_gui_dir)
        if status
            test_plan_excel = handles.test_plan_excel;
            testplan_details = dir(test_plan_excel);
            handles.testplan_changetime = testplan_details.date;
            set(handles.update_data,'Enable','off');
            set(handles.test_case_execu,'Enable', 'on');
            set(handles.requirement_execu,'Enable', 'on');
            set(handles.cumulative_execu,'Enable', 'on');
            set(handles.Execute_btn,'Enable','on');
        end
    end
catch
    cd (handles.current_gui_dir)
    test_plan_excel = handles.test_plan_excel;
    testplan_details = dir(test_plan_excel);
    handles.testplan_changetime = testplan_details.date;
    set(handles.update_data,'Enable','on');
    set(handles.test_case_execu,'Enable', 'off');
    set(handles.requirement_execu,'Enable', 'off');
    set(handles.cumulative_execu,'Enable', 'off');
    set(handles.Execute_btn,'Enable','off');
    print_logdata('TectVector updation is failed');
end



guidata(hObject,handles);



function [handles] = process_data_files(hObject, eventdata, handles)

Resolution_row_nbr = 4;
first_tc_row_nbr = 5;
ts_col_nbr = 2;
test_case_id_col_nbr =1;
header_row_nbr = 2;
testability_column_start = 3;
tab_space2 = '        ';
resolution_str = 'Resolution';
default_tollereance = '0.0000001';

%local control variable
resolution_row = 0;

%default set all to 'off'
%**************************************************************%
set(handles.coverage_check, 'Enable', 'off');
set(handles.testing_ids,'Enable','off');
set(handles.plot_execu,'Enable','off');
set(handles.Execute_btn,'Enable','off');
set(handles.test_case_execu,'Enable', 'off');
set(handles.requirement_execu,'Enable', 'off');
set(handles.cumulative_execu,'Enable', 'off');
set(handles.create_test_harness, 'Enable', 'off');

% all string to null and push button off
set(handles.Model_btn, 'Enable', 'off');
set(handles.test_plan_open, 'Enable', 'off');
set(handles.test_vector_open, 'Enable', 'off');

set(handles.model_name,'Enable','off');
set(handles.TestPlan_edit,'Enable','off');
set(handles.Testvector_edit,'Enable','off');
set(handles.model_name,'String', '');
set(handles.TestPlan_edit,'String', '');
set(handles.Testvector_edit,'String', '');
% set(handles.tolre_value, 'String', default_tollereance);
%**************************************************************%

% find test vector
test_vector_file = dir(fullfile(handles.pathName,'*_TestVector.xlsx'));
if(isempty(test_vector_file))
    test_vector_file = dir(fullfile(handles.pathName,'*_TestVector.xlsm'));
end
[row_tv,~] = size(test_vector_file);
if(row_tv > 1)
    print_logdata('Multiple test vector files found');
    error('Multiple test vector files found');
else
    testvector_excel = strcat(handles.pathName,test_vector_file.name);
end


% find test plan
test_plan_file = dir(fullfile(handles.pathName,'*_TestPlan.xlsx'));
if(isempty(test_plan_file))
    test_plan_file = dir(fullfile(handles.pathName,'*_TestPlan.xls'));
end
% handles.test_plan_excel = test_plan_file;
% testplan_details = dir(test_plan_file);
% try
%     handles.testplan_changetime = test_plan_file.date;
% catch
% %     do nothing
% end

[row_tp,~] = size(test_plan_file);
if(row_tp > 1)
    print_logdata('Multiple test plan files found');
    error('Multiple test plan files found');
else
    test_plan_excel = strcat(handles.pathName,test_plan_file.name);
end


%find test harness file
% test_harness_file = dir(fullfile(handles.pathName,'*_MIL_Test.slx'));
if strcmp(handles.current_testmethod, 'MIL')
    test_harness_file = dir(fullfile(handles.pathName,'*_MIL_Test.slx'));
else
    test_harness_file = dir(fullfile(handles.pathName,'*_SIL_Test.slx'));
end
[row_th,~] = size(test_harness_file);
if(row_th > 1)
    print_logdata('Multiple test harness model files found');
    error('Multiple test harness model files found');
end

test_vector_file_found = ~isempty(test_vector_file);
test_plan_file_found = ~isempty(test_plan_file);
test_harness_file_found = ~isempty(test_harness_file);

% check if minimum nuber of files present at location
if ((test_vector_file_found + test_plan_file_found + test_harness_file_found) >= 1)
    
    %disable test harness creation option
    set(handles.create_test_harness, 'Enable', 'off');
    
    % if all files for test execution, then enable else disable all
    if(test_vector_file_found && test_plan_file_found && test_harness_file_found)
        
        [~, ~, test_plan_raw] = xlsread(test_plan_excel,'Traceability');
        %ToDo: remove hard coded
        req_nbrs_i = test_plan_raw(2,2:end);
        test_case_id_i = test_plan_raw(3:end-2,1);
        
        is_template = check_if_template(req_nbrs_i,test_case_id_i);
        
        if strcmp(handles.current_testmethod, 'SIL')
            testplan_details = dir(handles.test_plan_excel);
            if ~strcmp(testplan_details.date, handles.testplan_changetime)
                set(handles.update_data,'Enable','off');
                set(handles.test_case_execu,'Enable', 'off');
                set(handles.requirement_execu,'Enable', 'off');
                set(handles.cumulative_execu,'Enable', 'off');
                set(handles.testing_ids,'Enable','off');
                set(handles.test_id,'Enable','off');
                set(handles.testcase_ids,'Enable','off');
                set(handles.testcase_id,'Enable','off');
                set(handles.Execute_btn,'Enable','off');
                set(handles.sil_action, 'Enable', 'off');
                print_logdata('Test Plan seems modified or selected the different Test model. Please select "MIL" test and update Test Vector before test execution');
            else
                set(handles.update_data,'Enable','off');
                set(handles.test_case_execu,'Enable', 'on');
                set(handles.requirement_execu,'Enable', 'on');
                set(handles.cumulative_execu,'Enable', 'on');
                if strcmp(handles.current_test,'Requirement')
                    set(handles.testing_ids,'Enable','on');
                    set(handles.test_id,'Enable','on');
                    set(handles.testcase_ids,'Enable','off');
                    set(handles.testcase_id,'Enable','off');
                    set(handles.coverage_check, 'Enable', 'off');
                elseif strcmp(handles.current_test,'Test Case')
                    set(handles.testing_ids,'Enable','off');
                    set(handles.test_id,'Enable','off');
                    set(handles.testcase_ids,'Enable','on');
                    set(handles.testcase_id,'Enable','on');
                    set(handles.coverage_check, 'Enable', 'off');
                elseif strcmp(handles.current_test,'Cumulative')
                    set(handles.testing_ids,'Enable','off');
                    set(handles.test_id,'Enable','off');
                    set(handles.testcase_ids,'Enable','off');
                    set(handles.testcase_id,'Enable','off');
                    VV_toolbox = ver;
                    index_vv = find(strcmp({VV_toolbox.Name}, 'Simulink Verification and Validation')==1);
                    if(~isempty(index_vv))
                        set(handles.coverage_check, 'Enable', 'on');
                    end
                end
                set(handles.Execute_btn,'Enable','on');
            end
        elseif strcmp(handles.current_testmethod, 'MIL')
            if(~is_template)
%                 testplan_details = dir(handles.test_plan_excel);
                if ~strcmp(test_plan_file.date, handles.testplan_changetime)
                    set(handles.sil_action, 'Enable', 'off');
                    handles.testplan_changetime = test_plan_file.date;
                    if handles.caller_fcn == 1
                        print_logdata('Test Environment already exists. Using the existing test environment');
%                         print_logdata('Selected Testing Type :-->  "Cumulative test"   ');
                        print_logdata('Update the Test Vector befor Test Execution');
                    else
                        %doNothing
                    end
                    
                    set(handles.test_case_execu,'Enable', 'off');
                    set(handles.requirement_execu,'Enable', 'off');
                    set(handles.cumulative_execu,'Enable', 'off');
                    
                    set(handles.Execute_btn,'Enable','off');
                    set(handles.update_data, 'Enable', 'on');
                    
                    set(handles.Test_model, 'Enable', 'on');
                    set(handles.Testplan, 'Enable', 'on');
                    set(handles.Testvector, 'Enable', 'on');
                    
                    VV_toolbox = ver;
                    index_vv = find(strcmp({VV_toolbox.Name}, 'Simulink Verification and Validation')==1);
                    if index_vv ~= 0
                        if handles.current_test == 'Cumulative'
                            set(handles.coverage_check, 'Enable', 'on');
                        end
                    end
                else
                    set(handles.update_data,'Enable','off');
                    set(handles.test_case_execu,'Enable', 'on');
                    set(handles.requirement_execu,'Enable', 'on');
                    set(handles.cumulative_execu,'Enable', 'on');
                    if strcmp(handles.current_test,'Requirement')
                        set(handles.testing_ids,'Enable','on');
                        set(handles.test_id,'Enable','on');
                        set(handles.testcase_ids,'Enable','off');
                        set(handles.testcase_id,'Enable','off');
                        set(handles.coverage_check, 'Enable', 'off');
                    elseif strcmp(handles.current_test,'Test Case')
                        set(handles.testing_ids,'Enable','off');
                        set(handles.test_id,'Enable','off');
                        set(handles.testcase_ids,'Enable','on');
                        set(handles.testcase_id,'Enable','on');
                        set(handles.coverage_check, 'Enable', 'off');
                    elseif strcmp(handles.current_test,'Cumulative')
                        set(handles.testing_ids,'Enable','off');
                        set(handles.test_id,'Enable','off');
                        set(handles.testcase_ids,'Enable','off');
                        set(handles.testcase_id,'Enable','off');
                        VV_toolbox = ver;
                        index_vv = find(strcmp({VV_toolbox.Name}, 'Simulink Verification and Validation')==1);
                        if(~isempty(index_vv))
                            set(handles.coverage_check, 'Enable', 'on');
                        end
                    end
                    set(handles.Execute_btn,'Enable','on');
                end
            else
                print_logdata('Test environment Created. Test Plan file Suspect to be TEMPLATE ONLY. Please update Test Plan and click on "Update Test vector"');
                
            end
        end
    else
        print_logdata('One or more supporting file missing');
        set(handles.create_test_harness, 'Enable', 'on');
        set(handles.Execute_btn,'Enable','off');
        set(handles.update_data, 'Enable', 'off');
    end
    
    %check if test harness found
    if(test_harness_file_found)
        set(handles.model_name,'String', test_harness_file.name);
        set(handles.Model_btn, 'Enable', 'on');
        handles.testmodel_slx = test_harness_file.name;
    else
        set(handles.model_name,'String', 'TEST HARNESS FILE MISSING','ForegroundColor','r');
        set(handles.Model_btn, 'Enable', 'off');
    end
    
    %check if test plan found
    if(test_plan_file_found)
        set(handles.TestPlan_edit,'String', test_plan_file.name);
        set(handles.test_plan_open,'Enable', 'on');
        handles.test_plan_excel = test_plan_excel;
    else
        set(handles.TestPlan_edit,'String', 'TEST PLAN FILE MISSING','ForegroundColor','r');
        set(handles.test_plan_open,'Enable', 'off');
    end
    
    %check if test vector found
    if(test_vector_file_found)
        set(handles.Testvector_edit,'String', test_vector_file.name);
        set(handles.test_vector_open,'Enable', 'on');
        [~,~,raw_data_temp] = xlsread(testvector_excel);
        resolution_row = strcmp(raw_data_temp(Resolution_row_nbr, 1),resolution_str);
        handles.testvector_excel = testvector_excel;
    else
        set(handles.Testvector_edit,'String', 'TEST VECTOR FILE MISSING','ForegroundColor','r');
        set(handles.test_vector_open,'Enable', 'off');
    end
    
    % if no resolution data found in test vector
%     if ~resolution_row
%         set(handles.tolre_value, 'String', default_tollereance);
%         set(handles.tolre_value, 'Enable', 'on');
% %         set(handles.tolre_value, 'String', 'Use resolution value from Test vector');
% %         set(handles.tolre_value, 'Enable', 'off');
%     end
    
    addpath(handles.pathName);
else
    print_logdata('Test Environment not exists, Please create test environment')
    set(handles.create_test_harness, 'Enable', 'on');
    set(handles.test_case_execu,'Enable', 'off');
    set(handles.requirement_execu,'Enable', 'off');
    set(handles.cumulative_execu,'Enable', 'off');
    set(handles.Execute_btn,'Enable','off');
    set(handles.update_data, 'Enable', 'off');
end
guidata(hObject,handles);