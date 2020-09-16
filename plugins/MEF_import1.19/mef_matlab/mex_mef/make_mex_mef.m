% Compile mex files required to process MEF files

% Copyright 2019-2020 Richard J. Cui. Created: Wed 05/29/2019  9:49:29.694 PM
% $Revision: 0.9 $  $Date: Sat 06/27/2020 11:58:46.987 PM $
%
% Multimodel Neuroimaging Lab
% Mayo Clinic St. Mary Campus
% Rochester, MN 55905, USA
%
% Email: richard.cui@utoronto.ca (permanent), Cui.Jie@mayo.edu (official)

% =========================================================================
% find the directory of make_mex_mef file
% =========================================================================
cur_dir = pwd; % current directory
% go to mex_mef folder
mex_mef = fileparts(mfilename('fullpath')); % directory of make_mex_mef.m assumed in mex_mef

% =========================================================================
% processing mex for MEF 2.0 file
% =========================================================================

% =========================================================================
% processing mex for MEF 2.1 file
% =========================================================================
cd([mex_mef,filesep,'mef_2p1']) % assume 'mef_2p1' is the subdirectory

fprintf('===== Compiling c-mex for MEF 2.1 data =====\n')
fprintf('Building read_mef_header_2p1.mex*\n')
mex -output read_mef_header_2p1 ...
    read_mef_header_mex_2p1.c ...
    mef_lib_2p1.c
movefile('read_mef_header_2p1.mex*',mex_mef)

fprintf('\n')
fprintf('Building decompress_mef_2p1.mex*\n')
mex -output decompress_mef_2p1 ...
    decompress_mef_mex_2p1.c ...
    mef_lib_2p1.c
movefile('decompress_mef_2p1.mex*',mex_mef)

cd(cur_dir)

% =========================================================================
% processing mex for MEF 3.0 file
% =========================================================================
fprintf('\n')
fprintf('===== Compiling c-mex for MEF 3.0 data =====\n')

cd([mex_mef, filesep, 'mef_3p0', filesep, 'matmef', filesep]) % assume 'mef_3p0' is the subdirectory
fprintf('\n')
fprintf('Building read_mef_session_metadata.mex*\n')
mex -output read_mef_session_metadata ...
    read_mef_session_metadata.c ...
    matmef_mapping.c ...
    mex_datahelper.c
movefile('read_mef_session_metadata.mex*',mex_mef)

fprintf('\n')
fprintf('Building read_mef_ts_data.mex*\n')
mex -output read_mef_ts_data ...
    read_mef_ts_data.c ...
    matmef_data.c
movefile('read_mef_ts_data.mex*',mex_mef)

cd(cur_dir)

% [EOF]