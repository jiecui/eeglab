classdef MEFEEGLab_2p1 < MEFSession_2p1
    % MEFEEGLAB_2P1 process MEF 2.1 in EEGLab
    %
    % Syntax:
    %   this = MEFEEGLab_2p1(sesspath)
    %   this = MEFEEGLab_2p1(__, password)
    %
    % Input(s):
    %   sesspath        - [str] session path
    %   password        - [struct] (opt) password (default: empty)
    %
    % Output(s):
    %
    % Note:
    %
    % See also .
    
    % Copyright 2019-2020 Richard J. Cui. Created: Mon 12/30/2019 10:52:49.006 PM
    % $Revision: 0.6 $  $Date: Fri 01/10/2020  5:42:05.951 PM $
    %
    % 1026 Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================    
    properties
        SelectedChannel     % channels selected
        StartEnd            % start and end points to import the session
        SEUnit              % unit of StartEnd
    end % properties
    
    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    % ----------------
    methods
        function this = MEFEEGLab_2p1(varargin)
            % parse inputs
            % ------------
            % default
            default_pw = struct('Session', '', 'Subject', '', 'Data', '');
            
            % parse rules
            p = inputParser;
            p.addRequired('sesspath', @isstr);
            p.addOptional('password', default_pw, @isstruct);
            
            % parse the return the results
            p.parse(varargin{:});
            q = p.Results;
            
            % operations during construction
            % ------------------------------
            sesspath = q.sesspath;
            password = q.password;
            
            if isempty(sesspath)
                error('MEFEEGLab_2p1:MEFEEGLab_2p1',...
                    'Session path must be specified')
            else
                this.SessionPath = sesspath;
            end % if
            this.Password = password;
            this.get_sessinfo; % check session information
        end % function
    end % methods
    
    % other metheds
    methods
        OUTEEG = mefimport(this, INEEG, varargin) % import session to EEGLab
        dc_event = findDiscontEvent(this, start_end, unit) % process discontinuity events
    end % methods
end

% [EOF]