function [EEG, com] = pop_mefimport(EEG, varargin)
% POP_MEFIMPORT Import MEF data into EEGLab with GUI
%
% Syntax:
%   [EEG, com] = pop_mefimport(EEG)
%   [EEG, com] = pop_mefimport(EEG, filepath)
%   [EEG, com] = pop_mefimport(EEG, filepath, filename)
%   [EEG, com] = pop_mefimport(EEG, filepath, filename, start_end)
%   [EEG, com] = pop_mefimport(EEG, filepath, filename, start_end, unit)
%
% Input(s):
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
% Outputs:
%   EEG             - [struct] EEGLab dataset structure. See Note for
%                     addtional information about the details of the
%                     structure.
% 
% Note:
%   All MEF files in one directory are assumed to be data files for
%   different channels during recording.
% 
%   Details of EEG dataset structure in EEGLab can be found at:
%   https://sccn.ucsd.edu/wiki/A05:_Data_Structures, or see the help
%   information of eeg_checkset.m.
%
%   The command output is a hidden output that does not have to
% be described in the header
% 
% See also EEGLAB, mefimport.

% Copyright 2019 Richard J. Cui. Created: Tue 05/07/2019 10:33:48.169 PM
% $Revision: 0.6 $  $Date:Tue 05/28/2019  9:56:47.412 PM$
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% =========================================================================
% parse inputs
% =========================================================================
% display help if not enough arguments
% ------------------------------------
if nargin == 0
    com = '';
	help mfilename
	return
end % if	

q = parseInputs(EEG, varargin{:});
EEG = q.EEG;
filepath = q.filepath;
filename = q.filename;
start_end = q.start_end;
unit = q.unit;

% =========================================================================
% main
% =========================================================================
% import signal
% --------------
if isempty(filename)
    % use GUI to get the necessary information
    [filepath, filename, start_end, unit, password, mef1] = gui_mefimport;
    % if GUI is cancelled
    if isempty(filepath) && isempty(filename)
        EEG = [];
        return
    end % if
end % if
EEG = mefimport(EEG, filepath, filename, start_end, unit, password, mef1);
EEG = eeg_checkset(EEG); % from eeglab functions

% process discontinuity events
% ----------------------------
if height(mef1.Continuity) > 1
    discont_event = findDiscontEvent(mef1, start_end, unit);
    EEG.event = discont_event;
    EEG.urevent = rmfield(discont_event, 'urevent');
end % if

% keep some data in eeglab space
% ------------------------------
mef_data.mef1 = mef1;
mef_data.start_end = start_end;
mef_data.unit = unit;
EEG.etc.mef_data = mef_data;

% return the string command
% -------------------------
com = sprintf('%s(EEG, [filename, [pathname, [start_end, [unit, [password]]]]] )', mfilename);

end % funciton

% =========================================================================
% subroutines
% =========================================================================
function dc_event = findDiscontEvent(mef, start_end, unit)

% converte start_end to index if not
if strcmpi(unit, 'index')
    se_ind = start_end;
else
    se_ind = mef.SampleTime2Index(start_end, unit);
end % if

% find the continuity blocks
seg_cont = mef.Continuity;
cont_ind = se_ind(1) <= seg_cont.SampleIndexEnd...
    & se_ind(2) >= seg_cont.SampleIndexStart;
dc_start = seg_cont.SampleIndexStart(cont_ind); % discont start in index

% find the relative index of start of discontinuity
rel_dc = dc_start - se_ind(1);
rel_dc(rel_dc < 0) = []; % get rid of index < 0

% construct the event of EEGLAB
num_event = numel(rel_dc);
t = table('Size', [num_event, 3], 'VariableTypes', {'string', 'double', 'double'},...
    'VariableNames', {'type', 'latency', 'urevent'});
t.type = repmat('Discont', num_event, 1);
t.latency = rel_dc(:);
t.urevent = (1:num_event)';

% output
dc_event = table2struct(t);

end % function

function q = parseInputs(varargin)

% defaults
defaultFP = '';
defaultFN = '';
defaultSE = [];
defaultUnit = 'index';
expectedUnit = {'index', 'uutc', 'second', 'minute', 'hour', 'day'};

% parse rules
p = inputParser;
p.addRequired('EEG', @(x) isempty(x) || isstruct(x));
p.addOptional('filepath', defaultFP, @ischar);
p.addOptional('filename', defaultFN, @(x) ischar(x) || iscellstr(x) || isstring(x));
p.addOptional('start_end', defaultSE,...
    @(x) isnumeric(x) & numel(x) == 2 & x(1) <= x(2));
p.addOptional('unit', defaultUnit,...
    @(x) any(validatestring(x, expectedUnit)));

% parse and return the results
p.parse(varargin{:});
q.EEG = p.Results.EEG;
q.filepath = p.Results.filepath;
q.filename = p.Results.filename;
q.start_end = p.Results.start_end;
q.unit = p.Results.unit;

end % function

% [EOF]

