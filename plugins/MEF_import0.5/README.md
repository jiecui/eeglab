Import MEF data into EEGLAB (Version 0.5)
=========================================

**MEF_import** is a EEGLAB plugin that imports data compressed in Multiscale Electrophysiology Format (or MEF Ver2.1, see below) into [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php).

**MEF_import** is protected by the GPL v3 Open Source License.

The code repository for **MEF_import** is hosted on GitHub at https://github.com/jiecui/MEF_import.

Installation
------------
1. Download, decompress and copy the directory into the directory of plugins of EEGLAB
1. Rename the directory of the plugin to 'MEF_import0.5'
1. Launch EEGLAB in MATLAB, e.g. >>eeglab
1. From EEGLAB GUI, select File > Import Data > Using EEGLAB functions and plugins > From UP-MSEL .mef file
1. Follow the instructions on the screen
1. A data sample 'sample_mef' folder is provided in the package (data passwords: 'erlichda' for Subject password; 'sieve' for Session password; no password required for Data password)

MEF format
----------
Multiscale Electrophysiology Format (MEF) is a novel electrophysiology file format designed for large-scale storage of electrophysiological recordings.
MEF can achieve significant data size reduction when compared to existing techniques with stat-of-the-art lossless data compression.
It satisfies the Health Insurance Portability and Accountability Act (HIPAA) to encrypt any patient protected health information transmitted over a public network.
The details of MEF file can be found at https://www.mayo.edu/research/labs/epilepsy-neurophysiology/mef-example-source-code from [Mayo Systems Electrophysiology Lab](http://msel.mayo.edu/) and on [International Epilepsy Portal](https://main.ieeg.org): https://main.ieeg.org/?q=node/28. 
