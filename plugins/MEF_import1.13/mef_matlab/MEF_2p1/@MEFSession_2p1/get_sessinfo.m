function varargout = get_sessinfo(this)
% MEFSESSION_2P1.get_SESSINFO Get session information from MEF 2.1 data
%
% Syntax:
%   [channame, start_end, unit, sess_info] = get_sessinfo(this)
% 
% Input(s):
%   this            - [obj] MEFSession_2p1 object
% 
% Output(s):
%   channame        - [str/cell str] the name(s) of the data channel in the
%                     directory of session. One file name can be in string
%                     or cell string.  If more than one, the names are in
%                     cell string.
%   begin_stop      - [1 x 2 array] [begin time/index, stop time/index] of 
%                     the entire signal
%   unit            - [str] unit of begin_stop: 'Index' (default), 'uUTC',
%                     'Second', 'Minute', 'Hour', and 'Day'
%   sess_info       - [table] N x 13 tabel: 'ChannelName', 'SamplingFreq',
%                     'Begin', 'Stop', 'Samples' 'IndexEntry',
%                     'DiscountinuityEntry', 'SubjectEncryption',
%                     'SessionEncryption', 'DataEncryption', 'Version',
%                     'Institution', 'SubjectID', 'AcquistitionSystem',
%                     'CompressionAlgorithm', where N is the number of
%                     channels.
% 
% Example:
%
% Note:
%   This function obtains information about the session from the data
%   directly.  Other information, such as session directory and password,
%   should be provided via MEFSession_2p1 object.
%
% References:
%
% See also MEFSession_2p1.

% Copyright 2020 Richard J. Cui. Created: Fri 01/03/2020  4:19:10.683 PM
% $ Revision: 0.3 $  $ Date: Thu 01/16/2020 10:50:40.905 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% =========================================================================
% Main process
% =========================================================================
% table of channel info
% ---------------------
[sess_info, unit] = get_info(this);

if isempty(sess_info)
    channame = '';
    fs = NaN;
    samples = NaN;
    num_data_block = [];
    num_time_gap = [];
    begin_stop = [];
    unit = '';
    institution = '';
    subj_id = '';
    acq_sys = '';
    comp_alg = '';
    warning('MEFSession_2p1:get_sessinfo',...
        'The session is likely empty.')
else
    this.SessionInformation = sess_info;
    if this.checkSessValid == true
        channame = sess_info.ChannelName';
        fs = unique(sess_info.SamplingFreq);
        samples = unique(sess_info.Samples);
        num_data_block = unique(sess_info.IndexEntry);
        num_time_gap = unique(sess_info.DiscountinuityEntry)-1;
        begin_stop = [unique(sess_info.Begin), unique(sess_info.Stop)];
        institution = unique(sess_info.Institution);
        subj_id = unique(sess_info.SubjectID);
        acq_sys = unique(sess_info.AcquisitionSystem);
        comp_alg = unique(sess_info.CompressionAlgorithm);
    else
        warning('MEFSession_2p1:get_sessinfo',...
            'The session is either empty or the data are not consistent. Please check messages')
        sess_info = table;
        channame = '';
        fs = NaN;
        samples = NaN;
        num_data_block = [];
        num_time_gap = [];
        begin_stop = [];
        unit = '';
        institution = '';
        subj_id = '';
        acq_sys = '';
        comp_alg = '';
    end % if
end % if

% update paras of MEFSession_2p1
% ------------------------------
this.ChannelName = channame;
this.SamplingFrequency = fs;
this.Samples = samples;
this.DataBlocks = num_data_block;
this.TimeGaps = num_time_gap;
this.BeginStop = begin_stop;
this.Unit = unit;
this.Institution = institution;
this.SubjectID = subj_id;
this.AcquisitionSystem = acq_sys;
this.CompressionAlgorithm = comp_alg;
this.SessionInformation = sess_info;

% =========================================================================
% Output
% =========================================================================
if nargout > 1
    varargout{1} = channame;
end % if
if nargout > 2
    varargout{2} = begin_stop;
end % if
if nargout > 3
    varargout{3} = unit;
end % if
if nargout > 4
    varargout{4} = sess_info;
end % if

end % function MEF_sessinfo

% =========================================================================
% Subroutines
% =========================================================================
function [sessinfo, unit] = get_info(this)
% get session information from data

sess_path = this.SessionPath;
pw = this.Password;
var_names = {'ChannelName', 'SamplingFreq', 'Begin', 'Stop', 'Samples',...
    'IndexEntry', 'DiscountinuityEntry', 'SubjectEncryption',...
    'SessionEncryption', 'DataEncryption', 'Version', 'Institution',...
    'SubjectID', 'AcquisitionSystem', 'CompressionAlgorithm'};
var_types = {'string', 'double', 'double', 'double', 'double', 'double',...
    'double', 'logical', 'logical', 'logical', 'string', 'string', 'string',...
    'string', 'string'};

chan_list = dir(fullfile(sess_path, '*.mef')); % assume all channel data in one dir
if isempty(chan_list)
    sessinfo = table;
    unit = '';
else % if
    unit = 'uUTC';
    num_chan = numel(chan_list); % number of channels
    sz = [num_chan, numel(var_names)];
    sessinfo = table('size', sz, 'VariableTypes', var_types,...
        'VariableNames', var_names);
    for k = 1:num_chan
        fp_k = chan_list(k).folder;
        fn_k = chan_list(k).name;
        header_k = this.readHeader(fullfile(fp_k, fn_k), pw.Subject);
        mef_ver = sprintf('%d.%d', header_k.header_version_major,...
            header_k.header_version_minor);

        sessinfo.ChannelName(k)  = header_k.channel_name;
        sessinfo.SamplingFreq(k) = header_k.sampling_frequency;
        sessinfo.Begin(k)        = header_k.recording_start_time;
        sessinfo.Stop(k)         = header_k.recording_end_time;
        sessinfo.Samples(k)      = header_k.number_of_samples;
        sessinfo.IndexEntry(k)   = header_k.number_of_index_entries;
        sessinfo.DiscountinuityEntry(k) = header_k.number_of_discontinuity_entries;
        sessinfo.SubjectEncryption(k)   = header_k.subject_encryption_used;
        sessinfo.SessionEncryption(k)   = header_k.session_encryption_used;
        sessinfo.DataEncryption(k)      = header_k.data_encryption_used;
        sessinfo.Version(k)      = mef_ver;
        sessinfo.Institution(k)  = header_k.institution;
        sessinfo.SubjectID(k)    = header_k.subject_id;
        sessinfo.AcquisitionSystem(k) = header_k.acquisition_system;
        sessinfo.CompressionAlgorithm(k) = header_k.compression_algorithm;
    end % for
end % if

end % funciton

% [EOF]