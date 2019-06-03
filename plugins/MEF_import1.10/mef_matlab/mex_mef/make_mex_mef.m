% Compile mex files required to read MEF files

% Copyright 2019 Richard J. Cui. Created: Wed 05/29/2019  9:49:29.694 PM
% $Revision: 0.1 $  $Date: Wed 05/29/2019  9:49:29.694 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

fprintf('Building read_mef_header.mex*\n')
mex -output read_mef_header read_mef_header_mex.c mef_lib.c

fprintf('\n')

fprintf('Building decompress_mef.mex*\n')
mex -output decompress_mef decompress_mef_mex.c mef_lib.c

% [EOF]