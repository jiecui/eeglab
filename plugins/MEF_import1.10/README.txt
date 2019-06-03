%% Installation Notes %%
Author: 
Jie (Richard) Cui (richard.cui@utoronto.ca)
University of Toronto 


To install the MEF_import plugin for EEGLAB:
1). Download, decompress and copy the directory into the directory of plugins of EEGLAB
2). Rename the directory of the plugin to MEF_import1.10
3). Launch EEGLAB in MATLAB, e.g. >> eeglab
4). Follow the instructions on the screen

To compile mex files:
Two mex files are required to read MEF data. Run 'make_mex_mef.m' in the folder of 'mef_matlab/mex_mef' to build the mex files for different operating systems.
 
To prepare data:
1). Put all the MEF files for different channels/electrodes of a single recording session under a single directory. 
2). A data sample, 'sample_mef' folder, is included in the package (passwords: 'erlichda' for Subject password; 'sieve' for Session password; no password required for Data password).

To input MEF data
1). From EEGLAB GUI, select File > Import Data > Using EEGLAB functions and plugins > From Mayo Clinic .mef file
2). If passwords are required, push "Set Passwords" to input the passwords.
3). Select the folder of the dataset.  A list of available channel is shown in the table below.
4). Choose part of the signal to import if needed.
5). Discontinuity of recording is marked as event 'Discont'.

To input MAF data
From EEGLAB GUI, select File > Import event info > From Mayo Clinic .maf file

Currently, the importer can only recognize events of seizure onset and seizure offset.

%% LICENSE INFORMATION %
MEF_import Copyright (C) 2019 Jie Cui

This program is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as published 
by the Free Software Foundation; either version 3 of the License, or 
(at your option) any later version.

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License 
along with this program; if not, write to the Free Software Foundation, 
Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
