function varargout = gui_mefimport(varargin)
% GUI_MEFIMPORT Graphic UI for importing MEF 2.1 datafile
% 
% Syntax:
%   this = gui_mefimport()
% 
% Input(s):
% 
% Output(s):
%   this            - [obj] MEFEEGLab_2p1 object
% 
% Note:
%   gui_mefimport does not import MEF by itself, but instead gets the
%   necessary information about the data and then relys on gui_mefimport.m to
%   import MEF data into EEGLab.
% 
% See also pop_mefimport, gui_mefimport.

% Copyright 2019-2020 Richard J. Cui. Created: Sun 04/28/2019  9:51:01.691 PM
% $Revision: 1.0 $  $Date: Sun 01/12/2020  2:35:48.393 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_mefimport_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_mefimport_OutputFcn, ...
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

function gui_mefimport_OpeningFcn(hObject, eventdata, handles, varargin)
% initialization
% --------------
set(handles.checkbox_segment, 'Value', 0)
set(handles.pushbutton_deselall, 'Enable', 'off')
set(handles.uitable_channel,'Data', [], 'Enable', 'off')
set(handles.popupmenu_unit, 'String', {'Index', 'uUTC', 'mSec', 'Second',...
    'Hour'}, 'Enable', 'Off')
set(handles.edit_start, 'Enable', 'Off')
set(handles.edit_end, 'Enable', 'Off')
set(handles.uitable_channel, 'Enable' , 'Off')
set(handles.checkbox_segment, 'Enable', 'Off')

handles.old_unit = 'uUTC';

handles.subject_pw = '';
handles.session_pw = '';
handles.data_pw = '';

handles.output = hObject;
guidata(hObject, handles);

uiwait();

function varargout = gui_mefimport_OutputFcn(hObject, eventdata, handles)
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.this;
end % if
guimef = findobj('Tag', 'gui_mefimport');
delete(guimef)

function [start_end, unit] = getStartend(this, handles)
% get start and end point

unit_list = get(handles.popupmenu_unit, 'String');
choice = get(handles.popupmenu_unit, 'Value');
unit = unit_list{choice};

uutc_start = this.BeginStop(1);
uutc_end = this.BeginStop(2);
start_end_index = this.SampleTime2Index([uutc_start, uutc_end]);
switch lower(unit)
    case 'index'
        start_end = start_end_index;
    otherwise
        start_end = this.SampleTime2Index([uutc_start, uutc_end], unit);
end % switch


function pushbutton_folder_Callback(hObject, eventdata, handles)
% get data folder and obtain corresponding data information

% get data folder
% ---------------
sess_path= uigetdir;
if sess_path == 0
    return
else
    set(handles.edit_path, 'String', sess_path);
end

% get data info
% -------------
% get password
subj_pw = handles.subject_pw;
sess_pw = handles.session_pw;
data_pw = handles.data_pw;
pw = struct('Subject', subj_pw, 'Session', sess_pw, 'Data', data_pw);
this = MEFEEGLab_2p1(sess_path, pw);

% get start and end points of imported signal in sample index
[start_end, unit] = getStartend(this, handles);
this.StartEnd = start_end;
this.SEUnit = unit;
if strcmpi(unit, 'index') % get recoridng start time in unit
    record_start = 0;
else
    record_start = this.SampleIndex2Time(1, unit);
end % if
set(handles.edit_start, 'String', num2str(start_end(1)-record_start))
set(handles.edit_end, 'String', num2str(start_end(2)-record_start))
handles.start_end = start_end;
handles.old_unit = unit;
handles.unit = unit;

% get channel information
Table = table2cell(this.SessionInformation(:, {'ChannelName',...
    'SamplingFreq', 'Samples', 'IndexEntry', 'DiscountinuityEntry'}));
num_chan = size(Table, 1);
Table(:, 1) = convertStringsToChars(this.SessionInformation.ChannelName);
Table(:, end+1) = num2cell(true(num_chan, 1));
rownames = num2cell(num2str((1:num_chan)'));

handles.list_chan = this.ChannelName;
this.SelectedChannel = handles.list_chan;
handles.this = this;
guidata(hObject, handles)

set(handles.uitable_channel, 'Data', Table, 'RowName', rownames, 'Enable' , 'On')
set(handles.pushbutton_deselall, 'Enable', 'On')
set(handles.checkbox_segment, 'Enable', 'On')
set(handles.popupmenu_unit, 'Enable', 'On')


function edit_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_path_Callback(hObject, eventdata, handles)


function checkbox_segment_Callback(hObject, eventdata, handles)

if get(handles.checkbox_segment, 'Value') == true
    set(handles.edit_start, 'Enable', 'On')
    set(handles.edit_end, 'Enable', 'On')
elseif get(handles.checkbox_segment, 'Value') == false
    set(handles.edit_start, 'Enable', 'Off')
    set(handles.edit_end, 'Enable', 'Off')
end % if

function SelectedCells= uitable_channel_CellSelectionCallback(hObject, eventdata, handles)
SelectedCells = eventdata.Indices;


function pushbutton_ok_Callback(hObject, eventdata, handles)
% get the data file information

if isfield(handles, 'edit_path') && isfield(handles, 'list_chan')...
        && ~isempty(handles.edit_path) && ~isempty(handles.list_chan)
    % get MEFEEGLab_2p1 object
    this = handles.this;
    
    % sess_path
    handles.sess_path = get(handles.edit_path, 'String');
    this.SessionPath = handles.sess_path;
    
    % sel_chan
    Table = get(handles.uitable_channel, 'Data');
    list_chan = handles.list_chan;
    choice = cell2mat(Table(:, end));
    handles.sel_chan = list_chan(choice);
    this.SelectedChannel = handles.sel_chan;
    
    % unit
    unit_list = get(handles.popupmenu_unit, 'String');
    choice = get(handles.popupmenu_unit, 'Value');
    handles.unit = unit_list{choice};
    this.SEUnit = handles.unit;
    
    % start_end
    this = handles.this;
    unit = handles.unit;
    if strcmpi(unit, 'index') % get recoridng start time in unit
        record_start = 0;
    else
        record_start = this.SampleIndex2Time(1, unit);
    end % if
    
    start_pt = str2double(get(handles.edit_start, 'String'))+record_start;
    end_pt = str2double(get(handles.edit_end, 'String'))+record_start;
    handles.start_end = [start_pt, end_pt];
    this.StartEnd = handles.start_end;
    
    handles.this = this;
    
    guidata(hObject, handles);
    
    % close the GUI
    uiresume();
    guimef= findobj('Tag', 'gui_mefimport');
    close(guimef)
else
    supergui( 'geomhoriz', { 1 1 1 }, 'uilist', { ...
        { 'style', 'text', 'string', 'No valid MEF file!',...
                'HorizontalAlignment', 'center' },...
        { }, ...
        { 'style', 'pushbutton' , 'string', 'OK', 'callback',...
                'close(gcbf);' } } );
end % if


function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.sess_path = '';
handles.sel_chan = '';
handles.start_end = [];
handles.unit = '';
handles.this = [];
guidata(hObject, handles)

uiresume();
guimef= findobj('Tag', 'gui_mefimport');
close(guimef)


function pushbutton_deselall_Callback(hObject, eventdata, handles)
Table = get(handles.uitable_channel, 'Data');
r = size(Table, 1);
for i = 1:r
    Table{i, end} = false;
end

set(handles.uitable_channel, 'Data', Table)
set(handles.uitable_channel, 'Enable' , 'On')

function gui_mefimport_CloseRequestFcn(hObject, eventdata, handles)

if ~isfield(handles, 'sess_path')
    handles.sess_path = '';
end % if

if ~isfield(handles, 'sel_chan')
    handles.sel_chan = '';
end % if

if ~isfield(handles, 'start_end')
    handles.start_end = [];
end % if

if ~isfield(handles, 'unit')
    handles.unit = '';
end % if
guidata(hObject, handles)

uiresume();


function edit_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_start as text
%        str2double(get(hObject,'String')) returns contents of edit_start as a double


% --- Executes during object creation, after setting all properties.
function edit_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_end_Callback(hObject, eventdata, handles)
% hObject    handle to edit_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_end as text
%        str2double(get(hObject,'String')) returns contents of edit_end as a double


% --- Executes during object creation, after setting all properties.
function edit_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_unit.
function popupmenu_unit_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_unit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_unit

% unit
unit_list = get(handles.popupmenu_unit, 'String');
choice = get(handles.popupmenu_unit, 'Value');
unit = unit_list{choice};
old_unit = handles.old_unit;

if strcmpi(unit, old_unit) == true
    return
end % if

% MEFEEGLab_2p1 object
this = handles.this;

% change value according to the unit chosen
if strcmpi(old_unit, 'index') % get recoridng start time in unit
    record_start_old = 0;
else
    record_start_old = this.SampleIndex2Time(1, old_unit);
end % if
if strcmpi(unit, 'index') % get recoridng start time in unit
    record_start = 0;
else
    record_start = this.SampleIndex2Time(1, unit);
end % if
old_start = str2double(get(handles.edit_start, 'String'))+record_start_old;
old_end = str2double(get(handles.edit_end, 'String'))+record_start_old;
if strcmpi(old_unit, 'index') == true % convert to index
    new_se_ind = [old_start, old_end];
else
    new_se_ind = this.SampleTime2Index([old_start, old_end], old_unit);
end % if
if strcmpi(unit, 'index') == true
    new_se = new_se_ind;
else
    new_se = this.SampleIndex2Time(new_se_ind, unit);
end % if

set(handles.edit_start, 'String', num2str(new_se(1)-record_start, 32));
set(handles.edit_end, 'String', num2str(new_se(2)-record_start, 32));
handles.start_end = new_se;
handles.old_unit = unit;
guidata(hObject, handles)



% --- Executes during object creation, after setting all properties.
function popupmenu_unit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_setpasswords.
function pushbutton_setpasswords_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_setpasswords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

geometry = {[0.5, 1.27], [0.5, 1.27], [0.5, 1.27]};
uilist = {...
    {'style', 'text', 'string', 'Subject', 'fontweight', 'bold'},...
    {'style', 'edit', 'string', '', 'horizontalalignment', 'left',...
        'tooltipstring', 'Input subject password'},...
    {'style', 'text', 'string', 'Session', 'fontweight', 'bold'},...
    {'style', 'edit', 'string', '', 'horizontalalignment', 'left',...
        'tooltipstring', 'Input Session password'},...
    {'style', 'text', 'string', 'Data', 'fontweight', 'bold'},...
    {'style', 'edit', 'string', '', 'horizontalalignment', 'left',...
        'tooltipstring', 'Input Data password'},...    
    };

res = inputgui(geometry, uilist, 'pophelp(''pop_mefimport'')', ...
    'Set MEF passwords -- gui_mefimport()');

if ~isempty(res)
    handles.subject_pw = res{1};
    handles.session_pw = res{2};
    handles.data_pw = res{3};
end % if
guidata(hObject, handles)

% [EOF]
