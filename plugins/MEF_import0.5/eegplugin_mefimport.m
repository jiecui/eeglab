function vers = eegplugin_mefimport(fig, try_strings, catch_strings)
% EEGPLUGIN_MEFIMPORT EEGLAB plugin for importing MSEL-UP .MEF file
% 
% Syntax:
%   vers = eegplugin_mefimport(fig, try_strings, catch_strings)
%
% Input(s):
%   fig            - [num]  handle to EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks. 
%
% Output(s):
%
% Example:
%
% Note:
%   With this menu it is possible to import Multiscale Electrophysiology
%   Format (.MEF) files into EEGLAB.
%
% References:
%   https://github.com/benbrinkmann/mef_lib_2_1
% 
% See also .

% Copyright 2019 Richard J. Cui. Created: Sun 04/28/2019  9:51:01.691 PM
% $Revision: 0.4 $  $Date: Tue 05/21/2019 10:40:22.466 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% version info
% ------------
vers='mefimport0.5';

% parse inputs
% ------------
q = parseInputs(fig, try_strings, catch_strings);
fig = q.fig;
try_strings = q.try_strings;
catch_strings = q.catch_strings;

% Setup menus of importing MEF files into EEGLAB
% ----------------------------------------------
% find import data menu
importmenu = findobj(fig, 'tag', 'import data');

% menu callback
mef_imp = [try_strings.no_check, 'EEG = pop_mefimport(EEG);',...
    catch_strings.new_and_hist];

% create menus in EEGLab
uimenu(importmenu, 'label', 'From UP-MSEL .mef file', 'callback',...
    mef_imp, 'separator', 'on');

end % function
 
% =========================================================================
% subroutines
% =========================================================================
function q = parseInputs(fig, try_strings, catch_strings)

p = inputParser;
p.addRequired('fig', @isobject);
p.addRequired('try_strings', @isstruct);
p.addRequired('catch_strings', @isstruct);

p.parse(fig, try_strings, catch_strings);
q.fig = p.Results.fig;
q.try_strings = p.Results.try_strings;
q.catch_strings = p.Results.catch_strings;

end % function

% [EOF]