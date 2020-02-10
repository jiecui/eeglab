classdef MEFEEGLab < handle
    % MEFEEGLab process MEF in EEGLab
    %  
    % Syntax:
    %
    % Input(s):
    %
    % Output(s):
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

    end % properties
    
    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    % ----------------
    methods

    end % methods
    
    % other methods
    % -------------
    methods
        OUTEEG = mefimport(this, INEEG, varargin) % import session to EEGLab
        dc_event = findDiscontEvent(this, start_end, unit) % process discontinuity events
    end % methods
end % classdef

% [EOF]