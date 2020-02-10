function [x, t] = importSignal(this, varargin)
% MULTISCALEELECTROPHYSIOLOGYFILE_3P0.IMPORTMEF Import MEF 3.0 channel into MATLAB
% 
% Syntax:
%   [x, t] = importSignal(this)
%   [x, t] = importSignal(__, start_end)
%   [x, t] = importSignal(__, start_end, st_unit)
%   [x, t] = importSignal(__, start_end, st_unit, filepath) 
%   [x, t] = importSignal(__, start_end, st_unit, filepath, filename)
%   [x, t] = importSignal(__, 'Level1Password', level_1_pw)
%   [x, t] = importSignal(__, 'Level2Password', level_2_pw)
%   [x, t] = importSignal(__, 'AccessLevel', access_level)
% 
% Imput(s):
%   this            - [obj] MultiscaleElectrophysiologyFile object
%   start_end       - [1 x 2 array] (opt) [start time/index, end time/index] of 
%                     the signal to be extracted fromt the file (default:
%                     the entire signal)
%   st_unit         - [str] (opt) unit of start_end: 'Index' (default), 'uUTC',
%                     'Second', 'Minute', 'Hour', and 'Day'
%   filepath        - [str] (opt) directory of the session
%   filename        = [str] (opt) filename of the channel
%   level_1_pw      - [str] (para) password of level 1 (default = '')
%   level_2_pw      - [str] (para) password of level 2 (default = '')
%   access_level    - [str] (para) data decode level to be used
%                     (default = 1)
% 
% Output(s):
%   x               - [num array] extracted signal
%   t               - [num array] time indices of the signal in the file
% 
% Note:
%   Import data from one channel of MEF 3.0 file into MatLab.
% 
% See also .

% Copyright 2020 Richard J. Cui. Created: Wed 02/05/2020 10:24:56.722 PM
% $Revision: 0.1 $  $Date: Wed 02/05/2020 10:24:56.722 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% =========================================================================
% parse inputs
% =========================================================================
q = parseInputs(this, varargin{:});
start_end = q.start_end;
st_unit = q.st_unit;
switch lower(st_unit)
    case 'index'
        se_index = start_end;
    otherwise
        se_index = this.SampleTime2Index(start_end, st_unit);
end % switch
filepath = q.filepath;
if isempty(filepath)
    filepath = this.FilePath;
else
    this.FilePath = filepath;
end % if
filename = q.filename;
if isempty(filename)
    filename = this.FileName;
else
    this.FileName = filename;
end % if

% verbose
num_samples = diff(start_end)+1;
if num_samples > 2^20
    verbo = true; 
else
    verbo = false;
end % if

wholename = fullfile(filepath, filename);

% password
l1_pw = q.Level1Password;
if isempty(l1_pw)
    l1_pw = this.Level1Password;
else
    this.Level1Password = l1_pw;
end % if

l2_pw = q.Level2Password;
if isempty(l2_pw)
    l2_pw = this.Level2Password;
else
    this.Level2Password = l2_pw;
end % if

al = q.AccessLevel;
if isempty(al)
    al = this.AccessLevel;
else
    this.AccessLevel = al;
end % if

% check
if se_index(1) < 1
    se_index(1) = 1; 
    warning('MultiscaleElectrophysiologyFile_3p0:ImportSignal:discardSample',...
        'Reqested data samples before the recording are discarded')
end % if
if se_index(2) > this.Channel.metadata.section_2.number_of_samples
    se_index(2) = this.Channel.metadata.section_2.number_of_samples; 
    warning('MultiscaleElectrophysiologyFile_3p0:ImportSignal:discardSample',...
        'Reqested data samples after the recording are discarded')
end % if

% =========================================================================
% load the data
% =========================================================================
pw = this.processPassword('Level1Password', l1_pw,...
                          'Level2Password', l2_pw,...
                          'AccessLevel', al);
if verbo, fprintf('-->Loading...'), end % if
x = this.read_mef_ts_data_3p0(wholename, pw, 'samples', se_index(1), se_index(2));
x = double(x(:)).'; % change to row vector
% find the indices corresponding to physically collected data
if nargout == 2
    t = se_index(1):se_index(2);
end % if
if verbo, fprintf('Done!\n'), end % if

end

% =========================================================================
% subroutines
% =========================================================================
function q = parseInputs(this, varargin)

% defaults
start_ind = this.SampleTime2Index(this.Channel.earliest_start_time);
end_ind = this.SampleTime2Index(this.Channel.latest_end_time);
defaultSE = [start_ind, end_ind];
defaultSTUnit = 'index';
expectedSTUnit = {'index', 'uutc', 'second', 'minute', 'hour', 'day'};
default_fp = '';
default_fn = '';
default_l1pw = '';
default_l2pw = '';
default_al = []; % access level

% parse rules
p = inputParser;
p.addRequired('this', @isobject);
p.addOptional('start_end', defaultSE,...
    @(x) isnumeric(x) & numel(x) == 2 & x(1) <= x(2));
p.addOptional('st_unit', defaultSTUnit,...
    @(x) any(validatestring(x, expectedSTUnit)));
p.addOptional('filepath', default_fp, @isstr);
p.addOptional('filename', default_fn, @isstr);
p.addParameter('Level1Password', default_l1pw, @isstr);
p.addParameter('Level2Password', default_l2pw, @isstr);
p.addParameter('AccessLevel', default_al, @isnumeric);

% parse and return the results
p.parse(this, varargin{:});
q = p.Results;

end % function

% [EOF]