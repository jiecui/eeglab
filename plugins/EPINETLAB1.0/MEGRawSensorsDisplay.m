function varargout = MEGRawSensorsDisplay(varargin)
% MEGRAWSENSORSDISPLAY MATLAB code for MEGRawSensorsDisplay.fig
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MEGRawSensorsDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @MEGRawSensorsDisplay_OutputFcn, ...
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


% --- Executes just before MEGRawSensorsDisplay is made visible.
function MEGRawSensorsDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MEGRawSensorsDisplay (see VARARGIN)

% Choose default command line output for MEGRawSensorsDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MEGRawSensorsDisplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MEGRawSensorsDisplay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
