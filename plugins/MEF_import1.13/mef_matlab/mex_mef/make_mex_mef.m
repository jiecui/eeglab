% Compile mex files required to process MEF files

% Copyright 2019-2020 Richard J. Cui. Created: Wed 05/29/2019  9:49:29.694 PM
% $Revision: 0.2 $  $Date: Thu 01/09/2020  3:39:04.874 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% MEF 2.0
% -------

% MEF 2.1
% -------
cd mef_2p1/ % assume 'mef_2p1' is the subdirectory

fprintf('===== Processing MEF 2.1 format =====\n')
fprintf('Building read_mef_header_2p1.mex*\n')
mex -output read_mef_header_2p1 read_mef_header_mex_2p1.c mef_lib_2p1.c

fprintf('\n')
fprintf('Building decompress_mef_2p1.mex*\n')
mex -output decompress_mef_2p1 decompress_mef_mex_2p1.c mef_lib_2p1.c

cd ..

% MEF 3.0
% -------

% [EOF]