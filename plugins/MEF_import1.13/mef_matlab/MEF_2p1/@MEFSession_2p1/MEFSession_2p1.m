classdef MEFSession_2p1 < MultiscaleElectrophysiologyFile_2p1
	% Class MEFSESSION_2P1 processes MEF 2.1 session
    % 
    % Syntax:
    %   this = MEFSession_2p1
    %   this = MEFSession_2p1(sesspath)
    %   this = MEFSession_2p1(sesspath, password)
    %
    % Input(s):
    %   sesspath    - [str] (opt) MEF 2.1 session path
    %   password    - [struct] (opt) structure of MEF 2.1 passowrd
    %                 .subject (default = '')
    %                 .session (default = '')
    %                 .data (default = '')
    % 
    % Output(s):
    %   this        - [obj] MEFSession_2p1 object
    %
    % See also get_sessinfo.

	% Copyright 2019-2020 Richard J. Cui. Created: Mon 12/30/2019 10:52:49.006 PM
	% $Revision: 0.8 $  $Date: Tue 01/21/2020  9:10:34.920 PM $
	%
	% 1026 Rocky Creek Dr NE
	% Rochester, MN 55906, USA
	%
	% Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================
    % properties of importing session
    % -------------------------------
    properties
        SelectedChannel     % channels selected
        StartEnd            % start and end points to import the session
        SEUnit              % unit of StartEnd
    end % properties

    % properties of session information
    % ---------------------------------
    properties 
        SessionPath         % session directory
        Password            % password structure of the session
        ChannelName         % channel names
        SamplingFrequency   % in Hz
        Samples             % number of samples
        DataBlocks          % number of data blocks
        TimeGaps            % number of discountinuity time gaps
        BeginStop           % Begin and stop indexes of entire signal
        Unit                % unit of BeginStop
        Institution         % name of the institute
        SubjectID           % identification of the subject
        AcquisitionSystem   % name of the system to record the session
        CompressionAlgorithm % name of compression algorithm
        SessionInformation  % table of session information (see get_sessinfo.m)
    end % properties
 
    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    % ----------------
    methods 
        function this = MEFSession_2p1(varargin)
            % parse inputs
            % ------------
            % defaults
            default_sp = ''; % default session path
            default_pw = struct('Subject', '', 'Session', '', 'Data', '');
            % parse rules
            p = inputParser;
            p.addOptional('sesspath', default_sp, @isstr);
            p.addOptional('password', default_pw, @isstruct)
            
            % parse and retrun the results
            p.parse(varargin{:});
            q = p.Results;
            
            % operations during construction
            % ------------------------------
            this.SessionPath = q.sesspath; % set session path directory
            this.Password = q.password; % set password
        end
    end % methods
    
    % static methods
    % -------------
    methods (Static)
        
    end % methods

    % other methods
    % -------------
    methods
        varargout = get_sessinfo(this) % get sess info from data
        valid_yn = checkSessValid(this, varargin) % check validity of session info
        [X, t] = importSession(this, varargin) % import a session
        record_offset = getRecordOffset(this, unit) % get offset time of recording in specified unit
        rel_time = abs2relativeTimePoint(this, abs_time, unit) % absolute to relative time points
        abs_time = relative2absTimePoint(this, rel_time, unit) % relative to absolute time points
        out_time = SessionUnitConvert(this, in_time, varargin) % convert units of relative time points
    end % methods
    
end % classdef

% [EOF]
