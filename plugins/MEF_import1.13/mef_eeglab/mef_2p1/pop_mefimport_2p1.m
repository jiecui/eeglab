function [EEG, com] = pop_mefimport_2p1(EEG, varargin)
% POP_MEFIMPORT_2P1 Import MEF 2.1 data into EEGLab with/out GUI
%
% Syntax:
%   [EEG, com] = pop_mefimport_2p1(EEG)
%   [EEG, com] = pop_mefimport_2p1(__, sess_path)
%   [EEG, com] = pop_mefimport_2p1(__, sess_path, sel_chan)
%   [EEG, com] = pop_mefimport_2p1(__, sess_path, sel_chan, start_end)
%   [EEG, com] = pop_mefimport_2p1(__, sess_path, sel_chan, start_end, unit)
%   [EEG, com] = pop_mefimport_2p1(__, pw)
%
% Input(s):
%   EEG             - [strcut] EEGLab dataset structure. See Note for
%                     addtional information about the details of the
%                     structure.
%   sess_path       - [str] path of the session
%   sel_chan        - [string array] the name(s) of the data files in the
%                     directory of sess_path.
%   start_end       - [1 x 2 array] (optional) [start time/index, end time/index] of 
%                     the signal to be extracted from the file (default:
%                     the entire signal)
%   unit            - [str] (optional) unit of start_end: 'uUTC' (default), 'Index',
%                     'Second', 'Minute', 'Hour', and 'Day'
%   pw              - [strct] (opt) password
% 
% Outputs:
%   EEG             - [struct] EEGLab dataset structure. See Note for
%                     addtional information about the details of the
%                     structure.
%   com             - [str] the command output
% 
% Note:
%   All MEF files in one directory are assumed to be data files for
%   different channels during recording.
% 
%   Details of EEG dataset structure in EEGLab can be found at:
%   https://sccn.ucsd.edu/wiki/A05:_Data_Structures, or see the help
%   information of eeg_checkset.m.
%
%   The command output is a hidden output that does not have to be
%   described in the header.
% 
% See also EEGLAB, mefimport.

% Copyright 2019-2020 Richard J. Cui. Created: Tue 05/07/2019 10:33:48.169 PM
% $Revision: 1.2 $  $Date: Wed 01/15/2020 12:05:20.430 PM $
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
sess_path = q.sess_path;
sel_chan = q.sel_chan;
start_end = q.start_end;
unit = q.unit;
pw = q.pw;

% =========================================================================
% main
% =========================================================================
% import signal
% --------------
if isempty(sess_path)
    % use GUI to get the necessary information
    this = gui_mefimport; % this - MEFEEGLab_2p1 object
    if isempty(this)
        EEG = [];
        return
    else
        sess_path = this.SessionPath;
        sel_chan = this.SelectedChannel;
        % if GUI is cancelled
        if isempty(sess_path) && isempty(sel_chan)
            EEG = [];
            return
        end % if
    end % if
else
    this = MEFEEGLab_2p1(sess_path, pw);
    this.SelectedChannel = sel_chan;
    this.StartEnd = start_end;
    this.SEUnit = unit;
end % if
EEG = this.mefimport(EEG);
EEG = eeg_checkset(EEG); % from eeglab functions

% process discontinuity events
% ----------------------------
if height(this.Continuity) > 1
    discont_event = this.findDiscontEvent;
    EEG.event = discont_event;
    EEG.urevent = rmfield(discont_event, 'urevent');
end % if

% keep some data in eeglab space
% ------------------------------
mef_data.this = this; % an instance of MEFEEGLab object
mef_data.start_end = this.StartEnd;
mef_data.unit = this.SEUnit;
EEG.etc.mef_data = mef_data;

% return the string command
% -------------------------
com = sprintf('%s(EEG, [sess_path, [sel_chan, [start_end, [unit, [password]]]]] )', mfilename);

end % funciton

% =========================================================================
% subroutines
% =========================================================================
function q = parseInputs(EEG, varargin)

% defaults
defaultFP = '';
defaultFN = '';
defaultSE = [];
defaultUnit = 'uutc';
expectedUnit = {'index', 'uutc', 'second', 'minute', 'hour', 'day'};
default_pw = struct([]);

valid_se = @(x) (isnumeric(x) && numel(x) == 2 && x(1) <= x(2));

% parse rules
p = inputParser;
p.addRequired('EEG', @(x) isempty(x) || isstruct(x));
p.addOptional('sess_path', defaultFP, @ischar);
p.addOptional('sel_chan', defaultFN, @(x) ischar(x) || iscellstr(x) || isstring(x));
p.addOptional('start_end', defaultSE, valid_se);
p.addOptional('unit', defaultUnit,...
    @(x) any(validatestring(x, expectedUnit)));
p.addOptional('pw', default_pw, @isstruct);

% parse and return the results
p.parse(EEG, varargin{:});
q = p.Results;

end % function

% [EOF]

