Import MEF data into EEGLAB (Version 1.05)
=========================================

**MEF_import** is an EEGLAB plugin that imports data compressed in Multiscale Electrophysiology Format (or Mayo EEG File, MEF, see below) and Multiscale Annotation File (MAF) data into [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php).
Current version can import [MEF/MAF Version 2.1](https://github.com/benbrinkmann/mef_lib_2_1) files.
Moreover, the functions provided in the folder "mef_matlab" can be used as a general tool to import MEF data into MATLAB.

The code repository for **MEF_import** is hosted on GitHub at https://github.com/jiecui/MEF_import.

Installation
------------
1. Download, decompress and copy the directory into the directory of plugins of EEGLAB
1. Rename the directory of the plugin to MEF_import1.05
1. Launch EEGLAB in MATLAB, e.g. >> eeglab
1. Follow the instructions on the screen

Mex file
--------
Two mex files are required to read MEF data. Run 'make_mex_mef.m' in the folder of 'mef_matlab/mex_mef' to build the mex files for different operating systems.
 
Data preparation
----------------
1. Put all the MEF files for different channels/electrodes of a single recording session into a single directory. 
1. A data sample, 'sample_mef' folder, is included in the package (passwords: 'erlichda' for Subject password; 'sieve' for Session password; no password required for Data password).

Input MEF data
--------------
1. From EEGLAB GUI, select File > Import Data > Using EEGLAB functions and plugins > From Mayo Clinic .mef file
1. If passwords are required, push "Set Passwords" to input the passwords.
1. Select the folder of the dataset.  A list of available channel is shown in the table below.
1. Choose part of the signal to import if needed.
1. Discontinuity of recording is marked as event 'Discont'.

Input MAF data
--------------
From EEGLAB GUI, select File > Import event info > From Mayo Clinic .maf file

Currently, the importer can only recognize events of seizure onset and seizure offset.

MEF format
----------
Multiscale Electrophysiology Format (MEF) is a novel electrophysiology file format designed for large-scale storage of electrophysiological recordings.
MEF can achieve significant data size reduction when compared to existing techniques with stat-of-the-art lossless data compression.
It satisfies the Health Insurance Portability and Accountability Act (HIPAA) to encrypt any patient protected health information transmitted over a public network.
The details of MEF file can be found at https://www.mayo.edu/research/labs/epilepsy-neurophysiology/mef-example-source-code from [Mayo Systems Electrophysiology Lab](http://msel.mayo.edu/) and on [International Epilepsy Portal](https://main.ieeg.org): https://main.ieeg.org/?q=node/28. 

License
-------
**MEF_import** is protected by the GPL v3 Open Source License.
