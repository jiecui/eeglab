function OUTEEG = mefimport(INEEG, filepath, filename, varargin)
% MEFIMPORT Import MEF data into EEG structure
%
% Usage:
%   OUTEEG = mefimport(INEEG, filepath, filename)
%   OUTEEG = mefimport(INEEG, filepath, filename, start_end)
%   OUTEEG = mefimport(INEEG, filepath, filename, start_end, unit)
%
% Input(s):
%   INEEG           - [struct] EEGLab dataset structure. See Note for
%                     addtional information about the details of the
%                     structure.
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
%   OUTEEG           - [struct] EEGLab dataset structure. See Note for
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
% See also eeglab, eeg_checkset, pop_mefimport. 

% Copyright 2019 Richard J. Cui. Created: Wed 05/08/2019  3:19:29.986 PM
% $Revision: 0.4 $  $Date: Sun 05/12/2019  3:27:29.780 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% =========================================================================
% parse inputs
% =========================================================================
q = parseInputs(INEEG, filepath, filename, varargin{:});
INEEG = q.INEEG;
filepath = q.filepath;
filename = q.filename;
start_end = q.start_end;
unit = q.unit;

if ischar(filename)
    fname = {filename};
else
    fname = filename;
end % if
mef = MultiscaleElectrophysiologyFile(filepath, fname{1});

% set EEG structure
% -----------------
if isempty(INEEG)
    % if EEGLAB is included in pathway, this can be done with eeg_emptyset.m
    OUTEEG = struct('setname', '',...
                 'filename', '',...
                 'filepath', '',...
                 'subject','',...
                 'group', '',...
                 'condition', '',...
                 'session', [],...
                 'comments', '',...
                 'nbchan', 0,...
                 'trials',0,...
                 'pnts', 0,...
                 'srate', 1,...
                 'xmin', 0,...
                 'xmax', 0,...
                 'times', [],...
                 'data', [],...
                 'icaact', [],...
                 'icawinv', [],...
                 'icasphere', [],...
                 'icaweights', [],...
                 'icachansind', [],...
                 'chanlocs', [],...
                 'urchanlocs',[],...
                 'chaninfo', [],...
                 'ref', [],...
                 'event', [],...
                 'urevent', [],...
                 'eventdescription', {},...
                 'epoch', [],...
                 'epochdescription', {},...
                 'reject', [],...
                 'stats', [],...
                 'specdata', [],...
                 'specicaact', [],...
                 'splinefile', '',...
                 'icasplinefile', '',...
                 'dipfit', [],...
                 'history', '',...
                 'saved', 'no',...
                 'etc', []);
else
    OUTEEG = INEEG; % careful, if don't clear working space
end % if

% =========================================================================
% convert to EEG structure
% =========================================================================
% setname
% -------
OUTEEG.setname = sprintf('Data from %s', mef.Header.institution);

% subject
% -------
OUTEEG.subject = mef.Header.subject_id;

% trials
% ------
OUTEEG.trials = 1; % assume continuous recording, not epoched

% nbchan
% ------
% MEF records each channel in different file
OUTEEG.nbchan = numel(fname);

% srate
% -----
OUTEEG.srate = mef.Header.sampling_frequency; % in Hz

% xmin, xmax (in second)
% ----------------------
% continuous data, according to the segment to be imported
switch lower(unit)
    case 'index'
        OUTEEG.xmin = mef.SampleIndex2Time(start_end(1), 'second');
        OUTEEG.xmax = mef.SampleIndex2Time(start_end(2), 'second');
    case 'second'
        OUTEEG.xmin = start_end(1);
        OUTEEG.xmax = start_end(2);
    otherwise
        se_index = mef.SampleTime2Index(start_end, unit);
        OUTEEG.xmin = mef.SampleIndex2Time(se_index(1), 'second');
        OUTEEG.xmax = mef.SampleIndex2Time(se_index(2), 'second');        
end % switch

% times (in second)
% -----
if isempty(start_end)
    [~, t] = mef.importSignal;
else
    [~, t] = mef.importSignal(start_end, unit); % t in sample index
end % if
OUTEEG.times = (t-1)/mef.Header.sampling_frequency; 

% pnts
% ----
OUTEEG.pnts = numel(t);

% comments
% --------
OUTEEG.comments = sprintf('Acauisition system - %s\ncompression algorithm - %s',...
    mef.Header.acquisition_system, mef.Header.compression_algorithm);

% saved
% -----
OUTEEG.saved = 'no'; % nost saved yet

% data and chanlocs
% -----------------
data = zeros(OUTEEG.nbchan, length(OUTEEG.times));
chanlocs = struct([]);
for k = 1:OUTEEG.nbchan
    ch_k = fname{k};
    fprintf('Importing MEF data %s [%d/%d]...\n', ch_k, k, OUTEEG.nbchan)
    
    mef_k = MultiscaleElectrophysiologyFile(fullfile(filepath, ch_k));
    if isempty(start_end)
        data(k, :) = mef_k.importSignal;
    else
        data(k, :) = mef_k.importSignal(start_end, unit);
    end % if
    % remove process mean
    % data(k, :) = data(k, :) - mean(data(k, :));
    
    chanlocs(k).labels = mef_k.Header.channel_name;
end % for
OUTEEG.data = data;
OUTEEG.chanlocs = chanlocs;

end % function

% =========================================================================
% subroutines
% =========================================================================
function q = parseInputs(varargin)

% defaults
defaultSE = [];
defaultUnit = 'index';
expectedUnit = {'index', 'uutc', 'second', 'minute', 'hour', 'day'};

% parse rules
p = inputParser;
p.addRequired('INEEG', @(x) isempty(x) || isstruct(x));
p.addRequired('filepath', @ischar);
p.addRequired('filename', @(x) ischar(x) || iscellstr(x) || isstring(x));
p.addOptional('start_end', defaultSE,...
    @(x) isnumeric(x) & numel(x) == 2 & x(1) <= x(2));
p.addOptional('unit', defaultUnit,...
    @(x) any(validatestring(x, expectedUnit)));

% parse and return the results
p.parse(varargin{:});
q.INEEG = p.Results.INEEG;
q.filepath = p.Results.filepath;
q.filename = p.Results.filename;
q.start_end = p.Results.start_end;
q.unit = p.Results.unit;

end % function

% [EOF]
