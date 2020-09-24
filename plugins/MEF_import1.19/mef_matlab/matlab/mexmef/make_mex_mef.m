% Compile mex files required to process MEF files

% Copyright 2019-2020 Richard J. Cui. Created: Wed 05/29/2019  9:49:29.694 PM
% $Revision: 1.1 $  $Date: Thu 09/24/2020  3:54:43.769 PM $
%
% Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% =========================================================================
% find the directory of make_mex_mef file
% =========================================================================
cur_dir = pwd; % current directory
% go to mex_mef folder
mex_mef = fileparts(mfilename('fullpath')); % directory of file make_mex_mef.m

% =========================================================================
% processing mex for MEF 2.0 file
% =========================================================================

% =========================================================================
% processing mex for MEF 2.1 file
% =========================================================================
% get the directory of mef_2p1
libmef2p1 = fullfile(fileparts(fileparts(mex_mef)),'libmef','mef_2p1'); % library
mexmef2p1 = fullfile(mex_mef,'mef_2p1'); % mex

fprintf('===== Compiling c-mex for MEF 2.1 data =====\n')
fprintf('Building read_mef_header_2p1.mex*\n')
% mex -output read_mef_header_2p1 ...
%     read_mef_header_mex_2p1.c ...
%     mef_lib_2p1.c
mex('-output','read_mef_header_2p1',['-I' libmef2p1],...
    fullfile(mexmef2p1,'read_mef_header_mex_2p1.c'),...
    fullfile(libmef2p1,'mef_lib_2p1.c'))
movefile('read_mef_header_2p1.mex*',mex_mef)

fprintf('\n')
fprintf('Building decompress_mef_2p1.mex*\n')
mex('-output','decompress_mef_2p1',['-I' libmef2p1],...
    fullfile(mexmef2p1,'decompress_mef_mex_2p1.c'),...
    fullfile(libmef2p1,'mef_lib_2p1.c'))
movefile('decompress_mef_2p1.mex*',mex_mef)

cd(cur_dir)

% =========================================================================
% processing mex for MEF 3.0 file
% =========================================================================
% fprintf('\n')
% fprintf('===== Compiling c-mex for MEF 3.0 data =====\n')
% 
% cd([mex_mef, filesep, 'mef_3p0', filesep, 'matmef', filesep]) % assume 'mef_3p0' is the subdirectory
% fprintf('\n')
% fprintf('Building read_mef_session_metadata.mex*\n')
% mex -output read_mef_session_metadata ...
%     read_mef_session_metadata.c ...
%     matmef_mapping.c ...
%     mex_datahelper.c
% movefile('read_mef_session_metadata.mex*',mex_mef)
% 
% fprintf('\n')
% fprintf('Building read_mef_ts_data.mex*\n')
% mex -output read_mef_ts_data ...
%     read_mef_ts_data.c ...
%     matmef_data.c
% movefile('read_mef_ts_data.mex*',mex_mef)
% 
% cd(cur_dir)

% [EOF]