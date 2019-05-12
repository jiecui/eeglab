classdef MultiscaleElectrophysiologyFile < handle
    % Class MULTISCALEELECTROPHYSIOLOGYFILE processes MEF data format
    %
    % Syntax:
    %   this = MultiscaleElectrophysiologyFile;
    %   this = MultiscaleElectrophysiologyFile(wholename);
    %   this = MultiscaleElectrophysiologyFile(filepath, filename);
    %   this = MultiscaleElectrophysiologyFile(__, 'Password', password);
    %
    % Input(s):
    %   wholename       - [str] fullpath and name of MEF file
    %   filepath        - [str] fullpath of MEF
    %   filename        - [str] name of MEF file, including ext
    %   password        - [str] (para) password (default is empty string)
    %
    % Output(s):
    %   this            - [object] MultiscaleElectrophysiologyFile object
    %
    % Note:
    %
    % See also this.readHeader.
    
    % Copyright 2019 Richard J. Cui. Created: Mon 04/29/2019  8:11:02.485 PM
    % $Revision: 0.1 $  $Date: Mon 04/29/2019  8:11:02.485 PM $
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
        Password        % [str] password of MEF file
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
            p.addParameter('Password', default_pw, @isstr);
            
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
                q.password = p.Results.Password;
            end % if
            
            % operations during construction
            % ------------------------------
            if ~isempty(q)
                this.FilePath = q.filepath;
                this.FileName = q.filename;
                this.Password = q.password;
                
                % read in header
                this.Header = this.readHeader(fullfile(this.FilePath,...
                    this.FileName), this.Password);
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
    end % methods
end % classdef

% [EOF]
