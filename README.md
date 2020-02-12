MEF 2.1 And 3.0 EEGLAB Plugin MEF_import (Ver 1.14)
===================================================

**MEF_import** is an EEGLAB plugin that imports data compressed in Multiscale Electrophysiology Format (or Mayo EEG File, MEF, see below) and Multiscale Annotation File (MAF) data into [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php).
Current version can import [MEF/MAF Version 2.1](https://github.com/benbrinkmann/mef_lib_2_1) and [MEF 3.0](https://msel.mayo.edu/codes.html) files.
Moreover, the functions provided in the folder "mef_matlab" can be used as a general tool to import MEF data into MATLAB.

The code repository for **MEF_import** is hosted on GitHub at https://github.com/jiecui/MEF_import.

Installation
------------
1. Download, decompress and copy the directory into the directory of plugins of EEGLAB (/root/directory/of/eeglab/plugins)
1. Rename the directory of the plugin to MEF_import1.14
1. Launch EEGLAB in MATLAB, for example,

        >> eeglab
1. Follow the instructions on the screen

Mex file
--------
Several mex files are required to read MEF data.
After launch EEGLAB, run 'make_mex_mef.m' to build the mex files for different operating systems.
The binary files for Mac-64bits are provided with the release, compiled by using Xcode with Clang.
 
Data samples
------------
1. Put all the MEF files for different channels/electrodes of a single recording session into a single directory. 
1. A data sample, 'sample_mef' folder, is included in the package (/root/directory/of/eeglab/plugins/MEF_import1.14/sample_mef).
Two data samples are included as subdirectories: 'mef_2p1' and 'mef_3p0'.
1. The directory 'mef_2p1' includes the session of MEF 2.1 signal (passwords: 'erlichda' for Subject password; 'sieve' for Session password; no password required for Data password).
1. The directory 'mef_3p0' includes the session of MEF 3.0 signal (level 1 password: password1; level 2 passowrd: password2; access level: 2).

Input MEF data
--------------
*Input signal using GUI*

1. From EEGLAB GUI, select File > Import Data > Using EEGLAB functions and plugins > From Mayo Clinic .mef. 
Then choose 'MEF 2.1' to import MEF 2.1 format data, or choose 'MEF 3.0' to import MEF 3.0 data.
1. If passwords are required, click "Set Passwords" to input the passwords.
1. Select the folder of the dataset.  A list of available channel is shown in the table below.
1. Choose part of the signal to import if needed.
1. Discontinuity of recording is marked as event 'Discont'.

*Input signal using MATLAB commandline*

The following code is an example to import a segment of MEF 3.0 signal into MATLAB/EEGLAB and plot it (after launch EEGLab):

```matlab
% set MEF version
mef_ver = 3.0; 

% set the session path
% please replace the root directory of eeglab with the directory on your system
sess_path = '/root/directory/of/eeglab/plugins/MEF_import1.14/sample_mef/mef_3p0';

% select channels
% the type of the variable of the selected channels is string array
sel_chan = ["left_central-ref", "Left_Occipital-Ref", "Left-Right_Central", "left-right_occipital"]; 

% set the start and end time point of signal segment
% this is a relative time point. the time of signal starts at 0 and the 1st sample index is 1.
start_end = [0, 10]; 

% set the unit of time point 
% in this example, we will import the signal from 0 second to 10 second
unit = 'second'; 

% set the password structure for MEF 3.0 sample data
password = struct('Level1Password', 'password1', 'Level2Password', 'password2', 'AccessLevel', 2); 

% import the signal into EEGLAB
% the variable 'EEG' is set by EEGLAB
% or you may create an empty one by using command 'EEG = eeg_empty();'
EEG = pop_mefimport(EEG, mef_ver, sess_path, sel_chan, start_end, unit, password); 

% plot the signal
pop_eegplot_w(EEG, 1, 0, 1); 
```

Input MAF data
--------------
From EEGLAB GUI, select File > Import event info > From Mayo Clinic .maf > MEF 2.1

Currently, the importer can only recognize events of seizure onset and seizure offset.

Credit
------
Multiscale Electrophysiology Format (MEF) is a novel electrophysiology file format designed for large-scale storage of electrophysiological recordings.
MEF can achieve significant data size reduction when compared to existing techniques with stat-of-the-art lossless data compression.
It satisfies the Health Insurance Portability and Accountability Act (HIPAA) to encrypt any patient protected health information transmitted over a public network.
The details of MEF file can be found at https://www.mayo.edu/research/labs/epilepsy-neurophysiology/mef-example-source-code from [Mayo Systems Electrophysiology Lab](http://msel.mayo.edu/) and on [International Epilepsy Portal](https://main.ieeg.org): https://main.ieeg.org/?q=node/28. 

The c-mex code to read MEF 2.1 data is mainly developed from the work done by Ben Brinkmann, Matt Stead, and Dan Crepeau from [Mayo Systems Electrophysiology Lab](https://msel.mayo.edu/codes.html),  Mayo Clinic, Rochester MN (https://github.com/benbrinkmann/mef_lib_2_1).
The c-mex code for MEF 3.0 is mainly adapted from the work by Max van den Boom and Dora Hermes Miller at Multimodal Neuroimaging Lab, Mayo Clinic, Rochester MN (https://github.com/MaxvandenBoom/matmef).

License
-------
**MEF_import** is protected by the GPL v3 Open Source License.
