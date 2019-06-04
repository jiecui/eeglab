function OUTEEG = mefimport(INEEG, filepath, filename, varargin)
% MEFIMPORT Import MEF data into EEG structure
%
% Usage:
%   OUTEEG = mefimport(INEEG, filepath, filename)
%   OUTEEG = mefimport(INEEG, filepath, filename, start_end)
%   OUTEEG = mefimport(INEEG, filepath, filename, start_end, unit)
%   OUTEEG = mefimport(INEEG, filepath, filename, start_end, unit, password)
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
%   password        - [str] (optional) passwords of MEF file
%                     .subject      : subject password (default - '')
%                     .session
%                     .data
%   mef1            - [obj] (optional) MultiscaleElectrophysiologyFile object of
%                     channel 1 (default- [])
% 
% Outputs:
%   OUTEEG           - [struct] EEGLab dataset structure. See Note for
%                     addtional information about the details of the
%                     structure.
% 
% Note:
%   Current version assumes continuous signal.
% 
%   All MEF files in one directory are assumed to be data files for
%   different channels during recording.
% 
%   Details of EEG dataset structure in EEGLab can be found at:
%   https://sccn.ucsd.edu/wiki/A05:_Data_Structures, or see the help
%   information of eeg_checkset.m.
%
% See also eeglab, eeg_checkset, pop_mefimport. 

% Copyright 2019 Richard J. Cui. Created: Wed 05/08/2019  3:19:29.986 PM
% $Revision: 0.9 $  $Date: Tue 06/04/2019  4:26:55.371 PM $
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
pw = q.password;
mef1 = q.mef1;

if ischar(filename)
    fname = {filename};
else
    fname = filename;
end % if
if isempty(mef1)
    mef1 = MultiscaleElectrophysiologyFile(filepath, fname{1},...
        'SubjectPassword', pw.subject);
end % if
mef1.setSubjectPassword(pw.subject);
mef1.setSessionPassword(pw.session);
mef1.setDataPassword(pw.data);

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
OUTEEG.setname = sprintf('Data from %s', mef1.Header.institution);

% subject
% -------
OUTEEG.subject = mef1.Header.subject_id;

% trials
% ------
OUTEEG.trials = 1; % assume continuous recording, not epoched

% nbchan
% ------
% MEF records each channel in different file
OUTEEG.nbchan = numel(fname);

% srate
% -----
OUTEEG.srate = mef1.Header.sampling_frequency; % in Hz

% xmin, xmax (in second)
% ----------------------
% continuous data, according to the segment to be imported
if isempty(start_end)
    num_samples = mef1.Header.number_of_samples;
    OUTEEG.xmin = mef1.SampleIndex2Time(1, 'second');
    OUTEEG.xmax = mef1.SampleIndex2Time(num_samples, 'second');
else
    switch lower(unit)
        case 'index'
            num_samples = diff(start_end)+1;
            OUTEEG.xmin = mef1.SampleIndex2Time(start_end(1), 'second');
            OUTEEG.xmax = mef1.SampleIndex2Time(start_end(2), 'second');
        case 'second'
            OUTEEG.xmin = start_end(1);
            OUTEEG.xmax = start_end(2);
            se_index = mef1.SampleTime2Index(start_end, unit);
            num_samples = diff(se_index)+1;
        otherwise
            se_index = mef1.SampleTime2Index(start_end, unit);
            num_samples = diff(se_index)+1;
            OUTEEG.xmin = mef1.SampleIndex2Time(se_index(1), 'second');
            OUTEEG.xmax = mef1.SampleIndex2Time(se_index(2), 'second');
    end % switch
end % if

% times (in second)
% ------------------------------------------------------------
OUTEEG.times = linspace(OUTEEG.xmin, OUTEEG.xmax, num_samples); 

% pnts
% ----
OUTEEG.pnts = num_samples;

% comments
% --------
OUTEEG.comments = sprintf('Acauisition system - %s\ncompression algorithm - %s',...
    mef1.Header.acquisition_system, mef1.Header.compression_algorithm);

% saved
% -----
OUTEEG.saved = 'no'; % not saved yet

% data and chanlocs
% -----------------
data = zeros(OUTEEG.nbchan, length(OUTEEG.times));
chanlocs = struct([]);
for k = 1:OUTEEG.nbchan
    ch_k = fname{k};
    fprintf('Importing MEF data %s [%d/%d]...\n', ch_k, k, OUTEEG.nbchan)
    
    mef_k = MultiscaleElectrophysiologyFile(filepath, ch_k,...
        'SubjectPassword', pw.subject);
    mef_k.setSessionPassword(pw.session);
    mef_k.setDataPassword(pw.data);
    mef_k.setContinuity(mef1.Continuity); % assume all channels are the same
    
    if isempty(start_end)
        data(k, :) = mef_k.importSignal;
    else
        data(k, :) = mef_k.importSignal(start_end, unit);
    end % if
    
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
default_pw = struct('subject', '', 'session', '', 'data', '');
defaultMef1 = [];

% parse rules
p = inputParser;
p.addRequired('INEEG', @(x) isempty(x) || isstruct(x));
p.addRequired('filepath', @ischar);
p.addRequired('filename', @(x) ischar(x) || iscellstr(x) || isstring(x));
p.addOptional('start_end', defaultSE,...
    @(x) isnumeric(x) & numel(x) == 2 & x(1) <= x(2));
p.addOptional('unit', defaultUnit,...
    @(x) any(validatestring(x, expectedUnit)));
p.addOptional('password', default_pw, @isstruct);
p.addOptional('mef1', defaultMef1, @isobject);

% parse and return the results
p.parse(varargin{:});
q = p.Results;

end % function

% [EOF]
