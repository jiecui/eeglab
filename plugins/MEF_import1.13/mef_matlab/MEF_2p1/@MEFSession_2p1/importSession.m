function [X, t] = importSession(this, varargin)
% MEFSESSION_2P1.importSession import MEF session data
% 
% Syntax:
%   [X, t] = importSession(this)
%   [X, t] = importSession(__, begin_stop)
%   [X, t] = importSession(__, begin_stop, bs_unit)
%   [X, t] = importSession(__, begin_stop, bs_unit, sess_path)
%   [X, t] = importSession(__, 'SelectedChannel', sel_chan, 'Password', pw)
% 
% Imput(s):
%   this            - [obj] MEFSession_2p1 object
%   begin_stop      - [num] (opt) 1 x 2 array of begin and stop points of
%                     importing the session (default: the entire session)
%   bs_unit         - [str] (opt) unit of begin_stop: 'uUTC' (default),
%                     'Index', 'Second', 'Minute', 'Hour', and 'Day'.
%   sess_path       - [str] (opt) session path (default: this.SessionPath)
%   sel_chan        - [str array] (para) the names of the selected channels
%                     (default: all channels)
%   pw              - [struct] (para) password structure
%                     .Session      : session password
%                     .Subject      : subject password
%                     .Data         : data password
% 
% Output(s):
%   X               - [num array] M x N array, where M is the number of
%                     channels and N is the number of signals extracted
%   t               - [num] 1 x N array, time indeces of the signals
% 
% Note:
%   Import data from different channels of the session.
% 
% See also importSignal.

% Copyright 2020 Richard J. Cui. Created: Wed 01/08/2020 11:16:21.943 PM
% $Revision: 0.1 $  $Date: Wed 01/08/2020 11:16:21.943 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% =========================================================================
% parse inputs
% =========================================================================
q = parseInputs(this, varargin{:});
begin_stop = q.begin_stop;
bs_unit = q.bs_unit;
sess_path = q.sess_path;
sel_chan = q.SelectedChannel;
pw = q.Password;

if isempty(begin_stop)
    begin_stop = this.BeginStop;
end % if

if isempty(sess_path)
    sess_path = this.SessionPath;
    if isempty(sess_path)
        warning('MEFSession_2p1:importSession',...
            'No session is selected')
        X = [];
        t = [];
        return
    end % if
end

if isempty(sel_chan)
    sel_chan = this.ChannelName;
    if isempty(sel_chan)
        warning('MEFSession_2p1:importSession',...
            'Either the session is empty or no channel has been selected')
        X = [];
        t = [];
        return
    end % if
end % if

if isempty(pw)
    pw = this.Password;
end % if

% =========================================================================
% input session
% =========================================================================
num_chan = numel(sel_chan); % number of selected channels
X = [];
for k = 1:num_chan
    fn_k = convertStringsToChars(sel_chan(k) + ".mef"); % filename of channel k
    [x_k, t] = this.importSignal(begin_stop, bs_unit, sess_path, fn_k,...
        'SubjectPassword', pw.Subject, 'SessionPassword', pw.Session,...
        'DataPassword', pw.Data);
    x_k = x_k(:).'; % make sure it is a horizontal vector
    
    X = cat(1, X, x_k);
end % for

end % function

% =========================================================================
% subroutines
% =========================================================================
function q = parseInputs(this, varargin)

% defaults
default_bs = []; % begin_stop
default_ut = 'uutc'; % unit
expected_ut = {'index', 'uutc', 'second', 'minute', 'hour', 'day'};
default_sp = ''; % session path
default_sc = []; % selected channel
default_pw = struct([]); % password

% parse rules
p = inputParser;
p.addRequired('this', @isobject);
p.addOptional('begin_stop', default_bs,...
    @(x) isnumeric(x) & numel(x) == 2 & x(1) <= x(2));
p.addOptional('bs_unit', default_ut, @(x) any(validatestring(x, expected_ut)));
p.addOptional('sess_path', default_sp, @isstr);
p.addParameter('SelectedChannel', default_sc, @isstring) % must be string array
p.addParameter('Password', default_pw, @isstruct);

% parse and return the results
p.parse(this, varargin{:});
q = p.Results;

end % function

% [EOF]