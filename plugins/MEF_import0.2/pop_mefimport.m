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
% $Revision: 0.2 $  $Date: Sat 05/11/2019 12:27:39.358 AM $
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
if isempty(filename)
    % use GUI to get the necessary information
    [filepath, filename, start_end, unit] = gui_mefimport;
    % if GUI is cancelled
    if isempty(filepath) && isempty(filename)
        EEG = [];
        return
    end % if
end % if
EEG = mefimport(EEG, filepath, filename, start_end, unit);
EEG = eeg_checkset(EEG); % from eeglab functions

% return the string command
% -------------------------
com = sprintf('%s(EEG, [filename, [pathname, [start_end, [unit]]]] )', mfilename);

end % funciton

% =========================================================================
% subroutines
% =========================================================================
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

