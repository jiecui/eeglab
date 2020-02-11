classdef MEFEEGLab_2p1 < MEFSession_2p1 & MEFEEGLab
    % MEFEEGLAB_2P1 process MEF 2.1 in EEGLab
    %
    % Syntax:
    %   this = MEFEEGLab_2p1(sesspath)
    %   this = MEFEEGLab_2p1(__, password)
    %
    % Input(s):
    %   sesspath        - [str] session path
    %   password        - [struct] (opt) password (default: empty)
    %                     .Subject
    %                     .Session
    %                     .Data
    %
    % Output(s):
    %
    % Note:
    %
    % See also .
    
    % Copyright 2019-2020 Richard J. Cui. Created: Mon 12/30/2019 10:52:49.006 PM
    % $Revision: 0.9 $  $Date: Tue 02/04/2020  8:36:19.731 PM $
    %
    % 1026 Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca

    % =====================================================================
    % properties
    % =====================================================================    
    properties

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
            default_pw = struct('Subject', '', 'Session', '', 'Data', '');
            
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
                error('MEFEEGLab_2p1:noSessionPath',...
                    'Session path must be specified')
            else
                this.SessionPath = sesspath;
            end % if
            this.Password = password;
            this.get_sessinfo; % check session information
            
            % set MEF version to serve
            if isempty(this.MEFVersion) == true
                this.MEFVersion = 2.1;
            elseif this.MEFVersion ~= 2.1
                error('MEFEEGLab_2p1:invalidMEFVer',...
                    'invalid MEF version; this function can serve only MEF 2.1')
            end % if            
        end % function
    end % methods
    
    % other metheds
    % -------------
    methods

    end % methods
end

% [EOF]