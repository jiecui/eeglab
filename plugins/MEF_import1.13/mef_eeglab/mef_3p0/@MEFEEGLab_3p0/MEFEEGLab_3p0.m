classdef MEFEEGLab_3p0 < MEFSession_3p0 & MEFEEGLab
    % MEFEEGLAB_3P0 process MEF 3.0 in EEGLab
    % 
    % Syntax:
    %   this = MEFSession_3p0(sesspath)
    %   this = __(__, password)
    %
    % Input(s):
    %   sesspath    - [str] session path
    %   password    - [struct] (opt) password (default: empty)
    %                 .Level1Password
    %                 .Level2Password
    %                 .AccessLevel
    %
    % Output(s):
    %   this        - [obj] MEFEEGLab_3p0 object
    %
    % Note:
    %
    % See also .
    
    % Copyright 2020 Richard J. Cui. Created: Sun 02/09/2020  3:45:09.696 PM
    % $Revision: 0.1 $  $Date: Sun 02/09/2020  3:45:09.696 PM $
    %
    % 1026 Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca
    
    % =====================================================================
    % properties
    % =====================================================================
    properties

    end
    
    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    % ----------------
    methods
        function this = MEFEEGLab_3p0(varargin)
            % parse inputs
            % ------------
            % default
            default_pw = struct('Level1Password', '',...
                'Level2Password', '', 'AccessLevel', 1);
            
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
                error('MEFEEGLab_3p0:noSessionPath',...
                    'Session path must be specified')
            else
                this.SessionPath = sesspath;
            end % if
            this.Password = password;
            this.get_sessinfo; % check session information
            
            % set MEF version to serve
            if isempty(this.MEFVersion) == true
                this.MEFVersion = 3.0;
            elseif this.MEFVersion ~= 3.0
                error('MEFEEGLab_3p0:invalidMEFVer',...
                    'invalid MEF version; this function can serve only MEF 3.0')
            end % if            
        end %function
    end % methods
    
    % other methods
    % -------------
    methods
        
    end % methods
end

% [EOF]