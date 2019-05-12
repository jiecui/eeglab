function varargout = gui_mefimport(varargin)
% GUI_MEFIMPORT Graphic UI for importing MEF datafile
% 
% Syntax:
%   [filepath, filename, start_end, unit] = gui_mefimport()
% 
% Input(s):
% 
% Output(s):
%   filepath        - [str] full file path
%   filename        - [str/cell str] the name(s) of the data files in the
%                     directory of 'filepath'. One file name can be in
%                     string or cell string.  More than one, the names are
%                     in cell string.
%   start_end       - [1 x 2 array] (optional) [start time/index, end time/index] of 
%                     the signal to be extracted fromt he file (default:
%                     the entire signal)
%   unit            - [str] (optional) unit of start_end: 'Index' (default), 'uUTC',
%                     'Second', 'Minute', 'Hour', and 'Day'
% 
% Note:
%   gui_mefimport does not import MEF by itself, but instead gets the
%   necessary information about the data and then relys on gui_mefimport.m to
%   import MEF data into EEGLab.
% 
% See also pop_mefimport, gui_mefimport.

% Copyright 2019 Richard J. Cui. Created: Sun 04/28/2019  9:51:01.691 PM
% $Revision: 0.2 $  $Date: Thu 05/09/2019 10:31:59.845 AM $
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

handles.old_unit = 'Index';

handles.output = hObject;
guidata(hObject, handles);

uiwait();

function varargout = gui_mefimport_OutputFcn(hObject, eventdata, handles)
if isempty(handles)
    varargout{1} = '';
    varargout{2} = '';
    varargout{3} = [];
    varargout{4} = '';
else
    varargout{1} = handles.filepath;
    varargout{2} = handles.filename;
    varargout{3} = handles.start_end;
    varargout{4} = handles.unit;
end % if
guimef = findobj('Tag', 'gui_mefimport');
delete(guimef)

function [start_end, unit] = gerStartend(list_mef, handles)
% get start and end point

filepath = list_mef.folder;
filename = list_mef.name;

unit_list = get(handles.popupmenu_unit, 'String');
choice = get(handles.popupmenu_unit, 'Value');
unit = unit_list{choice};

mef = MultiscaleElectrophysiologyFile(filepath, filename);
uutc_start = mef.Header.recording_start_time;
uutc_end = mef.Header.recording_end_time;
start_end_index = mef.SampleTime2Index([uutc_start, uutc_end]);
switch lower(unit)
    case 'index'
        start_end = start_end_index;
    otherwise
        start_end = mef.SampleTime2Index([uutc_start, uutc_end], unit);
end % switch

function pushbutton_folder_Callback(hObject, eventdata, handles)
% get data folder and obtain corresponding data information

% get data folder
% ---------------
filepath= uigetdir;
if filepath == 0
    return
else
    set(handles.edit_path, 'String', filepath);
end

% get data info
% -------------
list_mef = dir(fullfile(filepath, '*.mef'));
if isempty(list_mef)
    return
end % if

% get start and end points of imported signal
start_end = gerStartend(list_mef(1), handles);
set(handles.edit_start, 'String', num2str(start_end(1)))
set(handles.edit_end, 'String', num2str(start_end(2)))

% get channel information
num_mef = numel(list_mef); % number of mef/channels in the folder
colname = get(handles.uitable_channel, 'ColumnName');
num_colname = numel(colname);
Table = cell(num_mef, num_colname);
rownames = cell(num_mef, 1);
for k = 1:num_mef
    fp_k = list_mef(k).folder;
    fn_k = list_mef(k).name;
    mef = MultiscaleElectrophysiologyFile(fp_k, fn_k);
    Table{k, 1} = mef.Header.channel_name;
    Table{k, 2} = mef.Header.sampling_frequency;
    Table{k, 3} = mef.Header.number_of_samples;
    Table{k, 4} = mef.Header.number_of_index_entries;
    Table{k, 5} = mef.Header.number_of_discontinuity_entries;
    Table{k, 6} = true;
    
    rownames{k} = num2str(k);
end % for

handles.list_mef = list_mef;
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

% filepath
handles.filepath = get(handles.edit_path, 'String');

% filename
Table = get(handles.uitable_channel, 'Data');
list_mef = handles.list_mef;
fname = {list_mef.name};
choice = cell2mat(Table(:, end));
handles.filename = fname(choice);

% start_end
start_pt = str2double(get(handles.edit_start, 'String'));
end_pt = str2double(get(handles.edit_end, 'String'));
handles.start_end = [start_pt, end_pt];

% unit
unit_list = get(handles.popupmenu_unit, 'String');
choice = get(handles.popupmenu_unit, 'Value');
handles.unit = unit_list{choice};

guidata(hObject, handles);

% close the GUI
uiresume();
guimef= findobj('Tag', 'gui_mefimport');
close(guimef)


function pushbutton_cancel_Callback(hObject, eventdata, handles)

handles.filepath = '';
handles.filename = '';
handles.start_end = [];
handles.unit = '';
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

if ~isfield(handles, 'filepath')
    handles.filepath = '';
end % if

if ~isfield(handles, 'filename')
    handles.filename = '';
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

% mef
list_mef = handles.list_mef;
mef = MultiscaleElectrophysiologyFile(list_mef(1).folder, list_mef(1).name);

% change value according to the unit chosen
old_start = str2double(get(handles.edit_start, 'String'));
old_end = str2double(get(handles.edit_end, 'String'));
if strcmpi(old_unit, 'index') == true % convert to index
    new_se_ind = [old_start, old_end];
else
    new_se_ind = mef.SampleTime2Index([old_start, old_end], old_unit);
end % if
if strcmpi(unit, 'index') == true
    new_se = new_se_ind;
else
    new_se = mef.SampleIndex2Time(new_se_ind, unit);
end % if

set(handles.edit_start, 'String', num2str(new_se(1), 32));
set(handles.edit_end, 'String', num2str(new_se(2), 32));
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

% [EOF]
