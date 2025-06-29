% POP_PRECOMP - precompute measures (spectrum, ERP, ERSP) for a collection of data
%                 channels.  Calls STD_PRECOMP.
% Usage:    
%                >> [STUDY, ALLEEG] = pop_precomp(STUDY, ALLEEG); % pop up interactive window
% Inputs:
%   STUDY        - STUDY set structure containing (loaded) EEG dataset structures
%   ALLEEG       - ALLEEG vector of EEG structures, else a single EEG dataset.
%
% Outputs:
%   STUDY        - the input STUDY set with added pre-clustering data for use by POP_CLUST 
%   ALLEEG       - the input ALLEEG vector of EEG dataset structures modified by adding 
%                  pre-clustering data (pointers to .mat files that hold cluster measure information).
%
% Authors: Arnaud Delorme, CERCO, CNRS, 2006-
%
% See also: STD_PRECOMP

% Copyright (C) Arnaud Delorme, CERCO, CNRS, arno@salk.edu
%
% This file is part of EEGLAB, see http://www.eeglab.org
% for the documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

function [STUDY, ALLEEG, com] = pop_precomp(varargin)

com = '';

if ~ischar(varargin{1}) %initial settings
    if length(varargin) < 2
        error('pop_precomp(): needs both ALLEEG and STUDY structures');
    end
    STUDY  = varargin{1};
    ALLEEG = varargin{2};
    comps = false;
    if nargin > 2
        if strcmpi(varargin{3}, 'components')
            comps = true;
        end
    end
    
    if isempty(ALLEEG)
        error('STUDY contains no datasets');
    end
         
    % callbacks
    % ---------
    erspparams_str     = [ '''cycles'', [3 0.8], ''nfreqs'', 100, ''ntimesout'', 200' ];
    specparams_str     = '''specmode'', ''fft'', ''logtrials'', ''off''';
    erpimageparams_str = '''nlines'', 10,''smoothing'', 10';
    set_ersp       = ['pop_precomp(''setersp'',gcf);']; 
    test_ersp      = ['pop_precomp(''testersp'',gcf);']; 
    set_itc        = ['pop_precomp(''setitc'',gcf);']; 
    set_spec       = ['pop_precomp(''setspec'',gcf);']; 
    set_erp        = ['pop_precomp(''seterp'',gcf);']; 
    set_erpimage   = ['pop_precomp(''seterpimage'',gcf);']; 
    test_spec      = ['pop_precomp(''testspec'',gcf);']; 
    test_erpimage  = ['pop_precomp(''testerpimage'',gcf);']; 
    chanlist       = ['pop_precomp(''chanlist'',gcf);']; 
    chanlist       = 'warndlg2([ ''You need to compute measures on all data channels.'' 10 ''This functionality is under construction.'']);';
    chaneditbox    = ['pop_precomp(''chaneditbox'',gcf);']; 
    warninterp     = 'warndlg2(''Not interpolating channels may sometimes lead to unexpected errors when plotting results'');';
    cb_ica1        = ''; %[ 'if get(gcbo, ''value''), set(findobj(gcbf, ''tag'', ''rmica2_on''), ''value'', 0); end;' ];
    cb_ica2        = ''; %[ 'if get(gcbo, ''value''), set(findobj(gcbf, ''tag'', ''rmica1_on''), ''value'', 0); end;' ];
    
    geomline = [0.35 6];
    if comps == true
        str_name       = sprintf('Pre-compute component measures for STUDY ''%s''', STUDY.name);
        if length(str_name) > 80, str_name = [ str_name(1:80) '...' ]; end
        guiadd1 = { {'style' 'checkbox'   'string' '' 'tag' 'compallersp' 'value' 1 }  ...
                    {'style' 'text'       'string' 'Compute ERP/spectrum/ERSP only for components selected by RV (set) or for all components (unset)' } };
        guiadd2 = { {'style' 'checkbox'   'string' '' 'tag' 'scalp_on' 'value' 0 }  ...
                    {'style' 'text'       'string' 'Scalp maps' } };
        geomadd1     = { geomline };
        geomvertadd1 = [ 1 ];
        geomadd2     = { geomline };
    else
        str_name       = sprintf('Pre-compute channel measures for STUDY ''%s''', STUDY.name);
        if length(str_name) > 80, str_name = [ str_name(1:80) '...''' ]; end
        guiadd1  = { {'style' 'checkbox'   'string' '' 'tag' 'interpolate_on' 'value' 1 'callback' warninterp }  ...
            {'style' 'text'       'string' 'Spherical interpolation of missing channels (performed after optional ICA removal below)' } ...
            {'style' 'checkbox'   'string' ' ' 'tag' 'rmica1_on' 'value' 0 'callback' cb_ica1 }  ...
            {'style' 'text'       'string' 'Remove ICA artifactual components pre-tagged in each dataset' } ...
            {'style' 'checkbox'   'string' [ ' ' 10 ' ' ] 'tag' 'rmica2_on' 'value' 0 'callback' cb_ica2 }  ...
            {'style' 'text'       'string' [ 'Remove artifactual ICA cluster or clusters (hold shift key)' 10 ' ' ] } ...
            {'style' 'listbox'    'string' { STUDY.cluster.name } 'value' 1 'max' 2  'tag' 'rmica2_val'} };
        guiadd2 = {};
        geomadd1 = { geomline geomline [0.35 4 2] }; 
        geomvertadd1 = [ 1 1 2 ];
        geomadd2 = { };
    end

    cb_erp   = 'pop_precomp(''editerp'', gcbf);';
    cb_spec  = 'pop_precomp(''editspec'', gcbf);';
    cb_erpim = 'pop_precomp(''editerpim'', gcbf);';
    cb_ersp  = 'pop_precomp(''editersp'', gcbf);';
            
    gui_spec = { ...
    {'style' 'text'       'string' str_name 'FontWeight' 'Bold' 'horizontalalignment' 'left'}, {},...
    guiadd1{:}, ...
    {} {'style' 'text'    'string' 'List of measures to precompute' 'FontWeight' 'Bold' 'horizontalalignment' 'left'} {} ...
    {'style' 'text'    'string' 'Measure parameters' 'FontWeight' 'Bold' 'horizontalalignment' 'left'}  ...
    {} {} {} {}, ...
    {'style' 'checkbox'   'string' '' 'tag' 'erp_on' 'value' 0 'Callback' set_erp } , ...
	{'style' 'text'       'string' 'ERPs' }, {}, ...
    {'style' 'edit'       'string' '' 'tag' 'erp_params'    'enable' 'off' }, ...
    {'style' 'pushbutton' 'string' '...'  'tag' 'erp_but' 'enable' 'off' 'callback' cb_erp }, { },...
    ...
    {'style' 'checkbox'   'string' '' 'tag' 'spectra_on' 'value' 0 'Callback' set_spec }, ...
	{'style' 'text'       'string' 'Power spectrum' }, {}, ...
    {'style' 'edit'       'string' specparams_str 'tag' 'spec_params' 'enable' 'off' }, ...
    {'style' 'pushbutton' 'string' '...'  'tag' 'spec_but'  'enable' 'off' 'callback' cb_spec }...
    {'style' 'pushbutton' 'string' 'Test' 'tag' 'spec_test' 'enable' 'off' 'callback' test_spec}...
    ...
    {'style' 'checkbox'   'string' '' 'tag' 'erpimage_on' 'value' 0 'Callback' set_erpimage }, ...
	{'style' 'text'       'string' 'ERP-image' }, {}, ...
    {'style' 'edit'       'string' erpimageparams_str 'tag' 'erpimage_params' 'enable' 'off' }, ...
    {'style' 'pushbutton' 'string' '...'  'tag' 'erpimage_but' 'enable' 'off' 'callback' cb_erpim }...
    { } ...
    {'style' 'checkbox'   'string' '' 'tag' 'ersp_on' 'value' 0 'Callback' set_ersp } , ...
	{'style' 'text'       'string' 'ERSPs' 'horizontalalignment' 'center' }, {}, ...
    {'vertshift' 'style'  'edit'       'string' erspparams_str 'tag' 'ersp_params' 'enable' 'off'}...
    {'vertshift' 'style'  'pushbutton' 'string' '...'  'tag' 'ersp_test' 'enable' 'off' 'callback' cb_ersp }...
    {'vertshift' 'style'  'pushbutton' 'string' 'Test' 'tag' 'ersp_test' 'enable' 'off' 'callback' test_ersp }...
    {'style' 'checkbox'   'string' '' 'tag' 'itc_on' 'value' 0 'Callback' set_itc }, ...
	{'style' 'text'       'string' 'ITCs' 'horizontalalignment' 'center' }, {'link2lines' 'style'  'text'   'string' '' } {} {} {}, ...
    guiadd2{:}, ...
    {}, ...
    {'style' 'checkbox'   'string' 'Overwrite files on disk' 'tag' 'recomp_on' 'value' 1 } {}, ...
    };
%      {'style' 'pushbutton' 'string' 'Test' 'tag' 'erpimage_test' 'enable' 'off' 'callback' test_erpimage}...

	%{'style' 'checkbox'   'string' '' 'tag' 'precomp_PCA'  'Callback' precomp_PCA 'value' 0} ...
	%{'style' 'text'       'string' 'Do not prepare dataset for clustering at this time.' 'FontWeight' 'Bold'  } {} ...

    % find the list of all channels
    % -----------------------------
    allchans  = { };
    keepindex = 0;
    for index = 1:length(ALLEEG)
        tmpchanlocs = ALLEEG(index).chanlocs;
        tmpchans = { tmpchanlocs.labels };
        allchans = unique_bc({ allchans{:} tmpchanlocs.labels });
        if length(allchans) == length(tmpchans), keepindex = index; end
    end
    if keepindex, tmpchanlocs = ALLEEG(keepindex).chanlocs; allchans = { tmpchanlocs.labels }; end
    
    chanlist = {};
    firsttimeersp = 1;
    fig_arg = { ALLEEG STUDY allchans chanlist firsttimeersp };
    geomline0 = [2.8  0.5 2.4   0.4 0.4 0.65 0.65 ];
    geomline1 = [0.40 1.3 0.1 2.4 0.65 0.65 ];
    geomline2 = [0.40 0.9 0.5 2.4 0.65 0.65 ];
    geometry = { [1] [1] geomadd1{:}  [1] geomline0 geomline1 geomline1 geomline1 geomline2 geomline2 geomadd2{:} 1 [1 0.1] };
    geomvert = [ 1 0.5 geomvertadd1 0.5 1 1 1 1 1 1 1 fastif(length(geomadd2) == 1,1,[]) 1];
	[precomp_param, userdat2, strhalt, os] = inputgui( 'geometry', geometry, 'uilist', gui_spec, 'geomvert', geomvert, ...
                                                      'helpcom', ' pophelp(''std_precomp'')', ...
                                                      'title', 'Select and compute component measures for later clustering -- pop_precomp()', ...
                                                      'userdata', fig_arg);	
	if isempty(precomp_param), return; end
    
    if comps == 1
        options = { STUDY ALLEEG 'components' };
    else
        options = { STUDY ALLEEG userdat2{4} };
    end
    options = { options{:} 'savetrials' 'on' }; % always save single trials
    if ~isfield(os, 'interpolate_on'), os.interpolate_on = 0; end
    if ~isfield(os, 'scalp_on'),    os.scalp_on = 0; end
    if ~isfield(os, 'compallersp'), os.compallersp = 1; end
    warnflag = 0;
    
    % rm_ica option is on
    % -------------------
    if isfield(os, 'rmica1_on')
        if os.rmica1_on == 1 
            options = { options{:} 'rmicacomps' 'on' };
        end
    end
    
    % remove ICA cluster
    % ------------------
    if isfield(os, 'rmica2_on')
        if os.rmica2_on == 1 
            options = { options{:} 'rmclust' os.rmica2_val };
        end
    end
    
    % interpolate option is on
    % ------------------------
    if os.interpolate_on == 1 
        options = { options{:} 'interp' 'on' };
    end

    % compallersp option is on
    % ------------------------
    if os.compallersp == 0 
        options = { options{:} 'allcomps' 'on' };
    end    
    
    % recompute option is on
    % ----------------------
    if os.recomp_on == 1 
        options = { options{:} 'recompute' 'on' };
    end
    
    % ERP option is on
    % ----------------
    if os.erp_on == 1 
        options = { options{:} 'erp' 'on' };
        if ~isempty(os.erp_params)
            options = { options{:} 'erpparams' eval([ '{' os.erp_params '}' ]) };
        end
        warnflag = checkFilePresent(STUDY, 'erp', comps, warnflag, os.recomp_on);
    end
    
    % SCALP option is on
    % ----------------
    if os.scalp_on == 1 
        options = { options{:} 'scalp' 'on' };
    end
    
    % Spectrum option is on
    % --------------------
    if os.spectra_on== 1 
        tmpparams = eval( [ '{' os.spec_params '}' ] );
        options = { options{:} 'spec' 'on' 'specparams' tmpparams };
        warnflag = checkFilePresent(STUDY, 'spec', comps, warnflag, os.recomp_on);
    end
    
    % ERPimage option is on
    % --------------------
    if os.erpimage_on== 1 
        tmpparams = eval( [ '{' os.erpimage_params '}' ] );
        options = { options{:} 'erpim' 'on' 'erpimparams' tmpparams };
        warnflag = checkFilePresent(STUDY, 'erpim', comps, warnflag, os.recomp_on);
    end
    
    % ERSP option is on
    % -----------------
    if os.ersp_on  == 1 
        tmpparams = eval( [ '{' os.ersp_params '}' ] );
        options = { options{:} 'ersp' 'on' 'erspparams' tmpparams };
        warnflag = checkFilePresent(STUDY, 'ersp', comps, warnflag, os.recomp_on);
    end
    
    % ITC option is on 
    % ----------------
    if os.itc_on  == 1 
        tmpparams = eval( [ '{' os.ersp_params '}' ] );
        options = { options{:} 'itc' 'on' };
        if os.ersp_on  == 0, options = { options{:} 'erspparams' tmpparams }; end
        warnflag = checkFilePresent(STUDY, 'itc', comps, warnflag, os.recomp_on);
    end       
        
    % evaluate command
    % ----------------
    if length(options) == 4
        warndlg2('No measure selected: aborting.'); 
        return; 
    end
    [STUDY, ALLEEG] = std_precomp(options{:});
    com = sprintf('[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, %s);', vararg2str(options(3:end)));
    
else
    hdl = varargin{2}; %figure handle
    userdat = get(varargin{2}, 'userdata');    
    ALLEEG  = userdat{1};
    STUDY   = userdat{2};
    allchans = userdat{3};
    chansel  = userdat{4};
    firsttimeersp = userdat{5};

    switch  varargin{1}
               
        case 'chanlist'
            [tmp tmp2 tmp3] = pop_chansel(allchans, 'select', chansel);
            if ~isempty(tmp)
                set(findobj('parent', hdl, 'tag', 'chans'), 'string', tmp2);
                userdat{4} = tmp3;
            end
            set(hdl, 'userdata',userdat); 
     
        case 'chaneditbox'
            userdat{4} = parsetxt(get(findobj('parent', hdl, 'tag', 'chans'), 'string'));
            set(hdl, 'userdata',userdat); 
            
        case { 'setitc' 'setersp' }
            set_itc  = get(findobj('parent', hdl, 'tag', 'itc_on'), 'value'); 
            set_ersp = get(findobj('parent', hdl, 'tag', 'ersp_on'), 'value'); 
            if  (~set_ersp && ~set_itc )
                set(findobj('parent', hdl,'tag', 'ersp_push'),   'enable', 'off');
                set(findobj('parent', hdl,'tag', 'ersp_params'), 'enable', 'off');
                set(findobj('parent', hdl,'tag', 'ersp_test'),   'enable', 'off');
            else
                if any([ ALLEEG.trials ] == 1)
                    warndlg2('Some datasets have only one trial, cannot compute ERPimages');
                    set(findobj('parent', hdl,'tag', 'itc_on'), 'value', 0);
                    set(findobj('parent', hdl,'tag', 'ersp_on'), 'value', 0);
                else
                    set(findobj('parent', hdl,'tag', 'ersp_push'),   'enable', 'on');
                    set(findobj('parent', hdl,'tag', 'ersp_params'), 'enable', 'on');                
                    set(findobj('parent', hdl,'tag', 'ersp_test'),   'enable', 'on');      
                end
            end
            userdat{5} = 0;
            set(hdl, 'userdata',userdat); 
            if firsttimeersp
                warndlg2(strvcat('Checking both ''ERSP'' and ''ITC'' does not require further', ...
                                 'computing time. However it requires disk space'));
            end
            
        case 'setspec'
            set_spec = get(findobj('parent', hdl, 'tag', 'spectra_on'), 'value'); 
            if set_spec
                set(findobj('parent', hdl,'tag', 'spec_params'), 'enable', 'on');
                set(findobj('parent', hdl,'tag', 'spec_but'),    'enable', 'on');
                set(findobj('parent', hdl,'tag', 'spec_test'),   'enable', 'on');
            else 
                set(findobj('parent', hdl,'tag', 'spec_params'), 'enable', 'off');
                set(findobj('parent', hdl,'tag', 'spec_but'),    'enable', 'off');
                set(findobj('parent', hdl,'tag', 'spec_test'),   'enable', 'off');
            end
            
        case 'seterpimage'
            set_ermim = get(findobj('parent', hdl, 'tag', 'erpimage_on'), 'value'); 
            if set_ermim
                if any([ ALLEEG.trials ] == 1)
                    warndlg2('Some datasets have only one trial, cannot compute ERPimages');
                    set(findobj('parent', hdl,'tag', 'erpimage_on'), 'value', 0);
                else
                     set(findobj('parent', hdl,'tag', 'erpimage_params'), 'enable', 'on');
                     set(findobj('parent', hdl,'tag', 'erpimage_but'),   'enable', 'on');
                end
            else
                 set(findobj('parent', hdl,'tag', 'erpimage_params'), 'enable', 'off');
                 set(findobj('parent', hdl,'tag', 'erpimage_but'),   'enable', 'off');
            end

        case 'seterp'
            set_erp = get(findobj('parent', hdl, 'tag', 'erp_on'), 'value'); 
            if set_erp
                if any([ ALLEEG.trials ] == 1)
                    warndlg2('Some datasets have only one trial, cannot compute ERPs');
                    set(findobj('parent', hdl,'tag', 'erp_on'), 'value', 0);
                else
                     set(findobj('parent', hdl,'tag', 'erp_params'), 'enable', 'on');
                     set(findobj('parent', hdl,'tag', 'erp_but'), 'enable', 'on');
                end
            else 
                set(findobj('parent', hdl,'tag', 'erp_params'), 'enable', 'off');
                set(findobj('parent', hdl,'tag', 'erp_but'), 'enable', 'off');
            end

        % case 'editerp'     
        %     str = get(findobj('parent', hdl,'tag', 'erp_params'), 'string');
        %     try
        %         str = eval( [ 'struct(' str ')' ]);
        %         texttop = 'Select parameters for ERP';
        %         color   = [0 0 0];
        %     catch
        %         str = [];
        %         texttop = 'Textbox params ignored (can''t parse)';
        %         color   = [1 0 0];
        %     end
        %     if ~isfield(str, 'rmbase')
        %         str.rmbase = '';
        %     end
        %     str.rmbase = num2str(str.rmbase);
        %     cb_eval = [ 'set(findobj(gcf, ''tag'', ''editstr''), ''ForegroundColor'', [' num2str(color) ']);' ];
        %     [~,~,~,res] = inputgui('geometry', { 1 [1 0.35] }, 'uilist', ...
        %                   { { 'style' 'text' 'string' texttop 'tag' 'editstr' 'fontweight' 'bold' } ...
        %                     { 'style' 'text' 'string' 'End of baseline (default is 0 ms)' } ...
        %                     { 'style' 'edit' 'string' str.rmbase 'tag' 'rmbase' } }, 'eval', cb_eval);
        %     if isempty(res), return; end
        %     res.rmbase = str2num(res.rmbase);
        %     if isempty(res.rmbase)
        %         tmpstr = '';
        %     else
        %         tmpstr = vararg2str(res);
        %         tmpstr = tmpstr(8:end-1);
        %     end
        %     set(findobj('parent', hdl,'tag', 'erp_params'), 'string', tmpstr);
        case 'editerp'     
            str = get(findobj('parent', hdl,'tag', 'erp_params'), 'string');
            tmpstr = cb_choices(str, 'ERP', 'std_erp', { 'rmbase' {'Baseline (min max)' []}});
            set(findobj('parent', hdl, 'tag', 'erp_params'), 'string', tmpstr);    

        case 'editspec'     
            str = get(findobj('parent', hdl, 'tag', 'spec_params'), 'string');
            tmpstr = cb_choices(str, 'spectral decomposition', 'std_spec', { ...
                'specmode'  {'Spectral method' {'fft' 'spectopo' 'pburg' 'pmtm' 'ft_freqanalysis'}} ...
                'logtrials' {'Trial log power for ''fft'' and ''psd''' {'off' 'on'}} ...
                'ft_output' {'Output for ft_freqanalysis' {'pow','fractal','fooof','fooof_aperiodic','fooof_peaks','fooof_aperiodic-pow', 'fooof_aperiodic/pow'} }} );
%                'ft_method' {'Method for ft_freqanalysis' {'mtmfft', 'wavelet', 'mvar', 'superlet', 'irasa', 'hilbert'} } ...
            set(findobj('parent', hdl, 'tag', 'spec_params'), 'string', tmpstr);

        case 'editerpim'     
            str = get(findobj('parent', hdl,'tag', 'erpimage_params'), 'string');
            tmpstr = cb_choices(str, 'ERPIMAGE', 'std_erpimage', { 'nlines' {'Number of output rows' 10 } 'smoothing' { 'Smoothing (number of rows)' 10 }});
            set(findobj('parent', hdl, 'tag', 'erpimage_params'), 'string', tmpstr);    

        case 'editersp'     
            str = get(findobj('parent', hdl,'tag', 'ersp_params'), 'string');
            tmpstr = cb_choices(str, 'ERSP/ITC', 'std_ersp', { 'cycles' {'Wavelet cycles & factor (0 is FFT)' [3 0.8] } ...
                                         'nfreqs' { 'Number of frequencies' 100 } 'ntimesout' { 'Number of time points' 200 } });
            set(findobj('parent', hdl, 'tag', 'ersp_params'), 'string', tmpstr);    

        case 'testspec'
            %try,
                spec_params = eval([ '{' get(findobj('parent', hdl, 'tag', 'spec_params'), 'string') '}' ]); 

                TMPEEG = eeg_checkset(ALLEEG(1), 'loaddata');
                [ X f ] = std_spec(TMPEEG, 'channels', { TMPEEG.chanlocs(1).labels }, 'trialindices', { [1:min(20,TMPEEG.trials)] }, 'recompute', 'on', 'savefile', 'off', 'trialinfo', struct('condition', ''), spec_params{:});
                if ndims(X) > 2, X = mean(X,3); end
                X = 10*log10(X);
                figure; plot(f, X); 
                xlabel('Frequencies (Hz)');
                ylabel('Power');
                xlim([min(f) max(f)]);
                tmplim = ylim;
                text( TMPEEG.srate/4, mean(tmplim)+(max(tmplim)-min(tmplim))/3, ...
                                                 strvcat('This is a test plot performed on', ...
                                                         'the first 20 trials of the first', ...
                                                         'dataset (1 line per channel).', ...
                                                         'Frequency range may be adjusted', ...
                                                         'after computation'));
                icadefs;
                set(gcf, 'color', BACKCOLOR);
            %catch, warndlg2('Error while calling function, check parameters'); end

        case 'testersp'
            if ALLEEG(1).trials == 1
                warndlg2('Cannot calculate ERSP/ITC on continuous data');
            else
                try,
                    ersp_params = eval([ '{' get(findobj('parent', hdl, 'tag', 'ersp_params'), 'string') '}' ]); 
                    tmpstruct = struct(ersp_params{:});
                    [ tmpX, tmpt, tmpf, ersp_params ] = std_ersp(ALLEEG(1), 'channels', 1, 'trialindices', { [1:min(20,ALLEEG(1).trials)] }, 'type', 'ersp', 'parallel', 'off', 'recompute', 'on', 'savefile', 'off', ersp_params{:});
                    std_plottf(tmpt, tmpf, { tmpX });
                catch, warndlg2('Error while calling function, check syntax'); end
            end
            
        case 'testerpimage'
            % THIS CODE IS NOT FUNCTIONAL ANY MORE
            try,
                erpimage_params = eval([ '{' get(findobj('parent', hdl, 'tag', 'erpimage_params'), 'string') '}' ]); 
                tmpstruct = struct(erpimage_params{:});
                erpimstruct = std_erpimage(ALLEEG(1), 'channels', 1, 'recompute', 'on', 'savefile', 'off', erpimage_params{:});
                figure; pos = get(gcf, 'position'); pos(3)=pos(3)*2; set(gcf, 'position', pos);
                subplot(1,2,1); 
                tftopo(erpimstruct.chan1, erpimstruct.times, 1:size(erpimstruct.chan1,1), 'ylabel', 'Trials'); % erpimstruct.chan1 contains a string not data
                subplot(1,2,2); 
                text( 0.2, 0.8, strvcat( 'This is a test plot performed on', ...
                                         'the first channel of the first', ...
                                         'dataset.', ...
                                         ' ', ...
                                         'Time and trial range may be', ...
                                         'adjusted after computation.'), 'fontsize', 18);
                axis off;  
                icadefs;
                set(gcf, 'color', BACKCOLOR);
            catch, warndlg2('Error while calling function, check parameters'); end
                
    end
end
STUDY.saved = 'no';

% check if file is present
% ------------------------
function warnflag = checkFilePresent(STUDY, datatype, comps, warnflag, recompute);
    
    if ~recompute, return; end
    if warnflag, return; end % warning has already been issued
    
    oneSubject = STUDY.design(STUDY.currentdesign).cases.value{1};
    if comps
         dataFilename = [ oneSubject '.ica' datatype ];
    else dataFilename = [ oneSubject '.dat' datatype ];
    end
    allSubjects = { STUDY.datasetinfo.subject };
    inds = strmatch( oneSubject, allSubjects, 'exact');
    if isempty(inds)
        error('Your study design is corrupted and contains subjects not present in the study')
    end
    filepath = STUDY.datasetinfo(inds(1)).filepath;
    
    if exist(fullfile(filepath, dataFilename))
        textmsg = [ 'WARNING: SOME DATAFILES ALREADY EXIST, OVERWRITE THEM?' 10 ...
                    '(if you have another STUDY using the same datasets, it might overwrite its' 10 ...
                    'precomputed data files. Instead, use a single STUDY and create multiple designs).' ];
        res = questdlg2(textmsg, 'Precomputed datafiles already present on disk', 'No', 'Yes', 'Yes');
        if strcmpi(res, 'No')
            error('User aborted precomputing measures');
        end
    end
    warnflag = 1;
    
% gui pop up to choose options
% ----------------------------
function tmpstr = cb_choices(str, titl, func, choices)

tmpstr = str;
options = struct(choices{:});
fieldOptions = fieldnames(options);
try
    str = eval( [ 'struct(' str ')' ]);
    texttop = [ 'Select parameters for ' titl ];
    color   = [0 0 0];
catch
    str = [];
    texttop = 'Textbox params ignored (can''t parse)';
    color   = [1 0 0];
end

% check fields
uiList = { { 'style' 'text' 'string' texttop 'tag' 'editstr' 'fontweight' 'bold' } };
geom   = { 1 };
for iField = 1:length(fieldOptions)
    if ~isfield(str, fieldOptions{iField})
        if iscell(options(2).(fieldOptions{iField}))
            str.(fieldOptions{iField}) = options(2).(fieldOptions{iField}){1};
        else
            str.(fieldOptions{iField}) = options(2).(fieldOptions{iField});
        end
    end
    if isnumeric(options(2).(fieldOptions{iField}))
        geom = [ geom { [1 0.35]  } ];
        if length(str.(fieldOptions{iField})) == 1
            str.(fieldOptions{iField}) = num2str(str.(fieldOptions{iField}));
        else
            str.(fieldOptions{iField}) = vararg2str(str.(fieldOptions{iField}));
        end
        uiList = { uiList{:} { 'style' 'text' 'string' [ options(1).(fieldOptions{iField}) ' ("' fieldOptions{iField} '")' ] } ...
                  { 'style' 'edit' 'string' str.(fieldOptions{iField}) 'tag' fieldOptions{iField} } };
    else
        geom = [ geom { [1 0.5]  } ];
        valInd = strmatch(str.(fieldOptions{iField}), options(2).(fieldOptions{iField}), 'exact');
        if isempty(valInd), valInd = 1; end
        cb_tmp = '';
        enable = 'on';
        if isequal(func, 'std_spec') 
            if iField == 1
                cb_tmp = [ 'set(findobj(gcbf, ''tag'', ''logtrials''), ''enable'', fastif(any(get(gcbo, ''value'') == [1 2]), ''on'', ''off''));' ... 
                           'set(findobj(gcbf, ''tag'', ''ft_output''), ''enable'', fastif(any(get(gcbo, ''value'') == 5    ), ''on'', ''off''));' ...
                           'set(findobj(gcbf, ''tag'', ''ft_method''), ''enable'', fastif(any(get(gcbo, ''value'') == 5    ), ''on'', ''off''));' ];
                valIndMethod = valInd;
            else
                if any(valIndMethod == [1 2]) && strcmpi(fieldOptions{iField}, 'ft_output'), enable = 'off'; end
                if any(valIndMethod == [1 2]) && strcmpi(fieldOptions{iField}, 'ft_method'), enable = 'off'; end
                if any(valIndMethod == [  5]) && strcmpi(fieldOptions{iField}, 'logtrials'), enable = 'off'; end
            end
        end
        uiList = { uiList{:} { 'style' 'text' 'string' [ options(1).(fieldOptions{iField}) ' ("' fieldOptions{iField} '")' ] } ...
                  { 'style' 'popupmenu' 'string' options(2).(fieldOptions{iField}) 'tag' fieldOptions{iField} 'value' valInd 'callback' cb_tmp 'enable' enable } };
    end
end

cb_eval = [ 'set(findobj(gcf, ''tag'', ''editstr''), ''ForegroundColor'', [' num2str(color) ']);' ];
[~,~,~,res] = inputgui('geometry', geom, 'uilist', uiList, 'eval', cb_eval, 'helpcom', [ 'pophelp(''' func ''');' ]);
if isempty(res), return; end

for iField = 1:length(fieldOptions)
    if isnumeric(options(2).(fieldOptions{iField}))
        res.(fieldOptions{iField}) = str2num(res.(fieldOptions{iField}));
    else
        res.(fieldOptions{iField}) = options(2).(fieldOptions{iField}){res.(fieldOptions{iField})};
    end
end
tmpstr = vararg2str(res);
tmpstr = tmpstr(8:end-1);


