classdef MultiscaleElectrophysiologyFile < handle
    % Class MULTISCALEELECTROPHYSIOLOGYFILE processes MEF2.1 data format
    %
    % Syntax:
    %   this = MultiscaleElectrophysiologyFile;
    %   this = MultiscaleElectrophysiologyFile(wholename);
    %   this = MultiscaleElectrophysiologyFile(filepath, filename);
    %   this = MultiscaleElectrophysiologyFile(__, 'SubjectPassword', subj_pw);
    %   this = MultiscaleElectrophysiologyFile(__, 'SessionPassword', sess_pw);
    %   this = MultiscaleElectrophysiologyFile(__, 'DataPassword', data_pw);
    %
    % Input(s):
    %   wholename       - [str] fullpath and name of MEF file
    %   filepath        - [str] fullpath of MEF
    %   filename        - [str] name of MEF file, including ext
    %   subj_pw         - [str] (para) password of subject info (default is empty string)
    %   sess_pw         - [str] (para) password of session info
    %   data_pw         - [str] (para) password of data info
    %
    % Output(s):
    %   this            - [object] MultiscaleElectrophysiologyFile object
    %
    % Note:
    %   This class processes MEF ver2.1.
    %
    % See also this.readHeader.
    
    % Copyright 2019 Richard J. Cui. Created: Mon 04/29/2019  8:11:02.485 PM
    % $Revision: 0.2 $  $Date: Mon 05/20/2019  2:32:00.446 PM $
    %
    % 1026 Rocky Creek Dr NE
    % Rochester, MN 55906, USA
    %
    % Email: richard.cui@utoronto.ca
    
    % =====================================================================
    % properties
    % =====================================================================
    % signals
    % -------
    properties
        x               % imported signal
        t               % time index of the signal
    end % properties
    
    % MEF file info
    % -------------
    properties (SetAccess = protected)
        FilePath        % [str] filepath of MEF file
        FileName        % [str] filename of MEF file including ext (.mef)
        SubjectPassword % [str] subject password of MEF file
        SessionPassword % [str] session password of MEF file
        DataPassword    % [str] data password of MEF file
        Header          % [struct] header information of MEF file
        BlockIndexData  % [table] data of block indices
        Continuity      % [table] data segments of conituous sampling
    end % properties
    
    % =====================================================================
    % methods
    % =====================================================================
    % the constructor
    % ----------------
    methods
        function this = MultiscaleElectrophysiologyFile(varargin)
            % construct MultiscaleElectrophysiologyFile object
            % ------------------------------------------------
            % defaults
            default_pw = '';
            
            % parse rules
            p = inputParser;
            p.addOptional('file1st', '', @isstr);
            p.addOptional('file2nd', '', @isstr);
            p.addParameter('SubjectPassword', default_pw, @isstr);
            p.addParameter('SessionPassword', default_pw, @isstr);
            p.addParameter('DataPassword', default_pw, @isstr);
            
            % parse and return the results
            p.parse(varargin{:});
            if isempty(p.Results.file1st)
                q = [];
            else
                if isempty(p.Results.file2nd)
                    [fp, fn, ext] = fileparts(p.Results.file1st);
                    q.filepath = fp;
                    q.filename = [fn, ext];
                else
                    q.filepath = p.Results.file1st;
                    q.filename = p.Results.file2nd;
                end % if
                q.subjpw = p.Results.SubjectPassword;
                q.sesspw = p.Results.SessionPassword;
                q.datapw = p.Results.DataPassword;
                
            end % if
            
            % operations during construction
            % ------------------------------
            if ~isempty(q)
                this.FilePath = q.filepath;
                this.FileName = q.filename;
                this.SubjectPassword = q.subjpw;
                this.SessionPassword = q.sesspw;
                this.DataPassword = q.datapw;
                
                % read header
                this.Header = this.readHeader(fullfile(this.FilePath,...
                    this.FileName), this.SubjectPassword);
                
                % check version
                mef_ver = sprintf('%d.%d', this.Header.header_version_major,...
                    this.Header.header_version_minor);
                if strcmp(mef_ver, '2.1') == false
                    fprintf('Warning: The MEF file is compressed with MEF format version %s, rather than 2.1. The results may be unpredictable.\n',...
                        mef_ver)
                end % if
                
                % refresh session password from header
                this.SessionPassword = this.Header.session_password;
                
            end % if
        end % function
    end % methods
    
    % static methods
    methods (Static)
        
    end % methods
    
    % other metheds
    % -------------
    methods
        header = readHeader(this, varargin) % read head of MEF
        bid = readBlockIndexData(this, varargin) % read block indices
        blk_header = readBlockHeader(this, BlockIndex) % read block header
        seg_cont = analyzeContinuity(this, varargin) % analyze continuity of data sampling
        [sample_index, sample_yn] = SampleTime2Index(this, varargin) % time --> index
        [sample_time, sample_yn] = SampleIndex2Time(this, varargin) % index --> time
        [x, t] = importSignal(this, varargin) % import MEF signal into MATLAB
        this = setSubjectPassword(this, password) % set MEF subject password
        this = setSessionPassword(this, password) % set MEF session password
        this = setDataPassword(this, password) % set MEF data password
    end % methods
end % classdef

% [EOF]
