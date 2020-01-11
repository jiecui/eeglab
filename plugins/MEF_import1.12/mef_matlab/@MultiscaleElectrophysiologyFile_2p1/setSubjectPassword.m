function this = setSubjectPassword(this, password)
% MULTISCALEELECTROPHYSIOLOGYFILE_2P1.SETSUBJECTPASSWORD set Subject Password of MEF 2.1 file
% 
% Syntax:
%   this = setSubjectPassword(this, password)
% 
% Input(s):
%   this        - [obj] MultiscaleElectrophysiologyFile_2p1 object
%   password    - [str] Subject password
% 
% Output(s):
%   this        - output MultiscaleElectrophysiologyFile_2p1

% Copyright 2019 Richard J. Cui. Created: Mon 05/20/2019  6:35:28.870 PM
% $Revision: 0.2 $  $Date: Sun 12/29/2019  4:22:18.705 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% =========================================================================
% parse inputs
% =========================================================================
q = parseInputs(this, password);

this.SubjectPassword = q.password;

end

% =========================================================================
% subroutines
% =========================================================================
function q = parseInputs(varargin)

% defaults

% parse rules
p = inputParser;
p.addRequired('this', @isobject);
p.addRequired('password', @ischar);


% parse and return the results
p.parse(varargin{:});
q.password = p.Results.password;

end % function

% [EOF]
