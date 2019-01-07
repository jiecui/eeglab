% eegplot_w() - Scroll (horizontally and/or vertically) through multichannel data.
%             Allows vertical scrolling through channels and manual marking 
%             and unmarking of data stretches or epochs for rejection.
%    Almost identical to pop_eegplot(), but allow scroll with mouse wheel, 
%    to remove channels / components (with Shift+click), 
%    looks better in wide-screen monitor and draw EEG data faster.
%
% Usage: 
%           >> eegplot_w(data, 'key1', value1 ...); % use interface buttons, etc.
%      else
%           >> eegplot_w('noui', data, 'key1', value1 ...); % no user interface;
%                                                         % use for plotting
% Menu items:
%    "Figure > print" - [menu] Print figure in portrait or landscape.
%    "Figure > Edit figure" - [menu] Remove menus and buttons and call up the standard
%                  Matlab figure menu. Select "Tools > Edit" to format the figure
%                  for publication. Command line equivalent: 'noui' 
%    "Figure > Accept and Close" - [menu] Same as the bottom-right "Reject" button. 
%    "Figure > Cancel and Close" - [menu] Cancel all editing, same as the "Cancel" button. 
%    "Display > Marking color" > [Hide|Show] marks" - [menu] Show or hide patches of 
%                  background color behind the data. Mark stretches of *continuous* 
%                  data (e.g., for rejection) by dragging the mouse horizontally 
%                  over the activity. With *epoched* data, click on the selected epochs.
%                  Clicked on a marked region to unmark it. Called from the
%                  command line, marked data stretches or epochs are returned in 
%                  the TMPREJ variable in the global workspace *if/when* the "Reject" 
%                  button is pressed (see Outputs); called from pop_eegplot() or 
%                  eeglab(), the marked data portions are removed from the current
%                  dataset, and the dataset is automatically updated.
%     "Display > Marking color > Choose color" - [menu] Change the background marking 
%                  color. The marking color(s) of previously marked trials are preserved. 
%                  Called from command line, subsequent functions eegplot2event() or 
%                  eegplot2trials() allow processing trials marked with different colors 
%                  in the TMPREJ output variable. Command line equivalent: 'wincolor'.
%     "Display > Grid > ..." - [menu] Toggle (on or off) time and/or channel axis grids 
%                  in the activity plot. Submenus allow modifications to grid aspects.
%                  Command line equivalents: 'xgrid' / 'ygrid' 
%     "Display > Show scale" - [menu] Show (or hide if shown) the scale on the bottom 
%                  right corner of the activity window. Command line equivalent: 'scale' 
%     "Display > Title" - [menu] Change the title of the figure. Command line equivalent: 
%                  'title'
%     "Settings > Time range to display"  - [menu] For continuous EEG data, this item 
%                  pops up a query window for entering the number of seconds to display
%                  in the activity window. For epoched data, the query window asks
%                  for the number of epochs to display (this can be fractional). 
%                  Command line equivalent: 'winlength'
%     "Settings > Number of channels to display" - [menu] Number of channels to display
%                  in the activity window.  If not all channels are displayed, the 
%                  user may scroll through channels using the slider on the left 
%                  of the activity plot. Command line equivalent: 'dispchans'
%     "Settings > Channel labels > ..."  - [menu] Use numbers as channel labels or load
%                  a channel location file from disk. If called from the eeglab() menu or
%                  pop_eegplot(), the channel labels of the dataset will be used. 
%                  Command line equivalent: 'eloc_file'
%     "Settings > Zoom on/off" - [menu] Toggle Matlab figure zoom on or off for time and
%                  electrode axes. left-click to zoom (x2); right-click to reverse-zoom. 
%                  Else, draw a rectange in the activity window to zoom the display into 
%                  that region. NOTE: When zoom is on, data cannot be marked for rejection.
%     "Settings > Events" - [menu] Toggle event on or off (assuming events have been 
%                  given as input). Press "legend" to pop up a legend window for events.
%
% Display window interface:
%    "Activity plot" - [main window] This axis displays the channel activities.  For 
%                  continuous data, the time axis shows time in seconds. For epoched
%                  data, the axis label indicate time within each epoch.
%    "Cancel" - [button] Closes the window and cancels any data rejection marks.
%    "Event types" - [button] pop up a legend window for events.
%    "<<" - [button] Scroll backwards though time or epochs by one window length.
%    "<"  - [button] Scroll backwards though time or epochs by 0.2 window length.
%    "Navigation edit box" - [edit box] Enter a starting time or epoch to jump to.
%    ">"  - [button] Scroll forward though time or epochs by 0.2 window length.
%    ">>" - [button] Scroll forward though time or epochs by one window length.
%    "Chan/Time/Value" - [text] If the mouse is within the activity window, indicates
%                  which channel, time, and activity value the cursor is closest to.
%    "Scale edit box" - [edit box] Scales the displayed amplitude in activity units.
%                  Command line equivalent: 'spacing' 
%    "+ / -" - [buttons] Use these buttons to +/- the amplitude scale by 10%. 
%    "Reject" - [button] When pressed, save rejection marks and close the figure. 
%                  Optional input parameter 'command' is evaluated at that time. 
%                  NOTE: This button's label can be redefined from the command line
%                  (see 'butlabel' below). If no processing command is specified
%                  for the 'command' parameter (below), this button does not appear.
%    "Stack/Spread" - [button] "Stack" collapses all channels/activations onto the
%                  middle axis of the plot. "Spread" undoes the operation.
%    "Norm/Denorm" - [button] "Norm" normalizes each channel separately such that all
%                  channels have the same standard deviation without changing original 
%                  data/activations under EEG structure. "Denorm" undoes the operation.  
%                 
% Required command line input:
%    data        - Input data matrix, either continuous 2-D (channels,timepoints) or 
%                  epoched 3-D (channels,timepoints,epochs). If the data is preceded 
%                  by keyword 'noui', GUI control elements are omitted (useful for 
%                  plotting data for presentation). A set of power spectra at
%                  each channel may also be plotted (see 'freqlimits' below).
% Optional command line keywords:
%    'srate'      - Sampling rate in Hz {default|0: 256 Hz}
%    'spacing'    - Display range per channel (default|0: max(whole_data)-min(whole_data))
%    'eloc_file'  - Electrode filename (as in  >> topoplot example) to read
%                    ascii channel labels. Else,
%                   [vector of integers] -> Show specified channel numbers. Else,
%                   [] -> Do not show channel labels {default|0 -> Show [1:nchans]}
%    'limits'     - [start end] Time limits for data epochs in ms (for labeling 
%                   purposes only).
%    'freqs'      - Vector of frequencies (If data contain  spectral values).
%                   size(data, 2) must be equal to size(freqs,2).
%                   *** This option must be used ALWAYS with 'freqlimits' ***                           
%    'freqlimits' - [freq_start freq_end] If plotting epoch spectra instead of data, frequency 
%                   limits to display spectrum. (Data should contain spectral values).
%                   *** This option must be used ALWAYS with 'freqs' ***  
%    'winlength'  - [value] Seconds (or epochs) of data to display in window {default: 10}
%    'dispchans'  - [integer] Number of channels to display in the activity window 
%                   {default: from data}.  If < total number of channels, a vertical  
%                   slider on the left side of the figure allows vertical data scrolling. 
%    'title'      - Figure title {default: none}
%    'plottitle'  - Plot title {default: none}
%    'xgrid'      - ['on'|'off'] Toggle display of the x-axis grid {default: 'off'}
%    'ygrid'      - ['on'|'off'] Toggle display of the y-axis grid {default: 'off'}
%    'ploteventdur' - ['on'|'off'] Toggle display of event duration { default: 'off' }
%    'data2'      - [float array] identical size to the original data and
%                   plotted on top of it.
%
% Additional keywords:
%    'command'    - ['string'] Matlab command to evaluate when the 'REJECT' button is 
%                   clicked. The 'REJECT' button is visible only if this parameter is 
%                   not empty. As explained in the "Output" section below, the variable 
%                   'TMPREJ' contains the rejected windows (see the functions 
%                   eegplot2event() and eegplot2trial()).
%    'butlabel'   - Reject button label. {default: 'REJECT'}
%    'winrej'     - [start end R G B e1 e2 e3 ...] Matrix giving data periods to mark 
%                    for rejection, each row indicating a different period
%                      [start end] = period limits (in frames from beginning of data); 
%                      [R G B] = specifies the marking color; 
%                      [e1 e2 e3 ...] = a (1,nchans) logical [0|1] vector giving 
%                         channels (1) to mark and (0) not mark for rejection.
%    'color'      - ['on'|'off'|cell array] Plot channels with different colors.
%                   If an RGB cell array {'r' 'b' 'g'}, channels will be plotted 
%                   using the cell-array color elements in cyclic order {default:'off'}. 
%    'wincolor'   - [color] Color to use to mark data stretches or epochs {default: 
%                   [ 0.7 1 0.9] is the default marking color}
%    'events'     - [struct] EEGLAB event structure (EEG.event) to use to show events.
%    'submean'    - ['on'|'off'] Remove channel means in each window {default: 'on'}
%    'position'   - [lowleft_x lowleft_y width height] Position of the figure in pixels.
%    'tag'        - [string] Matlab object tag to identify this eegplot_w() window (allows 
%                    keeping track of several simultaneous eegplot_w() windows). 
%    'children'   - [integer] Figure handle of a *dependent* eegplot_w() window. Scrolling
%                    horizontally in the master window will produce the same scroll in 
%                    the dependent window. Allows comparison of two concurrent datasets,
%                    or of channel and component data from the same dataset.
%    'scale'      - ['on'|'off'] Display the amplitude scale {default: 'on'}.
%    'selectcommand' - [cell array] list of 3 commands (strings) to run when the mouse 
%                      button is down, when it is moving and when the mouse button is up.
%    'ctrlselectcommand' - [cell array] same as above in conjunction with pressing the 
%                      CTRL key.
% Outputs:
%    TMPREJ       -  Matrix (same format as 'winrej' above) placed as a variable in
%                    the global workspace (only) when the REJECT button is clicked. 
%                    The command specified in the 'command' keyword argument can use 
%                    this variable. (See eegplot2trial() and eegplot2event()). 
%
% Author: Arnaud Delorme & Colin Humphries, CNL/Salk Institute, SCCN/INC/UCSD, 1998-2001
%
% See also: eeg_multieegplot(), eegplot2event(), eegplot2trial(), eeglab()

% deprecated 
%    'colmodif'   - nested cell array of window colors that may be marked/unmarked. Default
%                   is current color only.

% Copyright (C) 2001 Arnaud Delorme & Colin Humphries, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% Note for programmers - Internal variable structure:
% All in g. except for Eposition and Eg.spacingwhich are inside the boxes
% gcf
%    1 - winlength
%    2 - srate 
%    3 - children
% 'backeeg' axis
%    1 - trialtag
%    2 - g.winrej
%    3 - nested call flag
% 'eegaxis'
%    1 - data
%    2 - colorlist
%    3 - submean    % on or off, subtract the mean
%    4 - maxfreq    % empty [] if no gfrequency content
% 'buttons hold other informations' Eposition for instance hold the current postition

function [outvar1] = eegplot_w(data, varargin); % p1,p2,p3,p4,p5,p6,p7,p8,p9)

% Defaults (can be re-defined):

DEFAULT_PLOT_COLOR = { [0 0 1], [0.7 0.7 0.7]};         % EEG line color
try
    icadefs;
	DEFAULT_FIG_COLOR = BACKCOLOR;
	BUTTON_COLOR = GUIBUTTONCOLOR;
catch
	DEFAULT_FIG_COLOR = [1 1 1];
	BUTTON_COLOR =[0.8 0.8 0.8];
end;
DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
%YAXIS_NEG = 'off';                % 'off' = positive up 
%DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
                                  %   0 - 1st color in AxesColorOrder
SPACING_EYE = 'on';               % g.spacingI on/off
%SPACING_UNITS_STRING = '';        % '\muV' for microvolt optional units for g.spacingI Ex. uV
%MAXEVENTSTRING = 10;
%DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
                                  % dimensions of main EEG axes
ORIGINAL_POSITION = [50 50 800 500];
                                  
if nargin < 1
   help eegplot_w
   return
end
				  
% %%%%%%%%%%%%%%%%%%%%%%%%
% Setup inputs
% %%%%%%%%%%%%%%%%%%%%%%%%

if ~ischar(data) % If NOT a 'noui' call or a callback from uicontrols

   try
       options = varargin;
       if ~isempty( varargin )
           for i = 1:2:numel(options)
               g.(options{i}) = options{i+1};
           end
       else g= [];
       end;
   catch
       disp('eegplot_w() error: calling convention {''key'', value, ... } error'); return;
   end;	
   
   % Selection of data range If spectrum plot  
   if isfield(g,'freqlimits') || isfield(g,'freqs')
%        % Check  consistency of freqlimits       
%        % Check  consistency of freqs

       % Selecting data and freqs
       [temp, fBeg] = min(abs(g.freqs-g.freqlimits(1)));
       [temp, fEnd] = min(abs(g.freqs-g.freqlimits(2)));
       data = data(:,fBeg:fEnd,:);
       g.freqs     = g.freqs(fBeg:fEnd);
       
       % Updating settings
       if ndims(data) == 2, g.winlength = g.freqs(end) - g.freqs(1); end 
       g.srate     = length(g.freqs)/(g.freqs(end)-g.freqs(1));
       g.isfreq    = 1;
   end

  % push button: create/remove window
  % ---------------------------------
  defdowncom   = 'eegplot_w(''defdowncom'',   gcbf);'; % push button: create/remove window
  defmotioncom = 'eegplot_w(''defmotioncom'', gcbf);'; % motion button: move windows or display current position
  defupcom     = 'eegplot_w(''defupcom'',     gcbf);';
  defctrldowncom = 'eegplot_w(''topoplot'',   gcbf);'; % CTRL press and motion -> do nothing by default
  defctrlmotioncom = ''; % CTRL press and motion -> do nothing by default
  defctrlupcom = ''; % CTRL press and up -> do nothing by default
		 
   try, g.srate; 		    catch, g.srate		= 256; 	end;
   try, g.spacing; 			catch, g.spacing	= 0; 	end;
   try, g.eloc_file; 		catch, g.eloc_file	= 0; 	end; % 0 mean numbered
   try, g.winlength; 		catch, g.winlength	= 10; 	end; % Number of seconds of EEG displayed
   try, g.fullscreen; 	    catch, g.fullscreen = 'on';	end;
   try, g.position; 	    catch, g.position	= ORIGINAL_POSITION; g.fullscreen = 'on';	end;
   try, g.title; 		    catch, g.title		= ['Scroll activity -- eegplot_w()']; 	end;
   try, g.plottitle; 		catch, g.plottitle	= ''; 	end;
   try, g.trialstag; 		catch, g.trialstag	= -1; 	end;
   try, g.winrej; 			catch, g.winrej		= []; 	end;
   try, g.command; 			catch, g.command	= ''; 	end;
   try, g.tag; 				catch, g.tag		= 'eegplot_w'; end;
   try, g.xgrid;		    catch, g.xgrid		= 'off'; end;
   try, g.ygrid;		    catch, g.ygrid		= 'off'; end;
   try, g.color;		    catch, g.color		= 'off'; end;
   try, g.submean;			catch, g.submean	= 'on'; end;
   try, g.children;			catch, g.children	= 0; end;
   try, g.limits;		    catch, g.limits	    = [0 1000*(size(data,2)-1)/g.srate]; end;
   try, g.freqs;            catch, g.freqs	    = []; end;  % Ramon
   try, g.freqlimits;	    catch, g.freqlimits	= []; end;
   try, g.dispchans; 		catch, g.dispchans  = size(data,1); end;
   try, g.wincolor; 		catch, g.wincolor   = [ 0.7 1 0.9]; end;
   try, g.butlabel; 		catch, g.butlabel   = 'REJECT'; end;
   try, g.colmodif; 		catch, g.colmodif   = { g.wincolor }; end;
   try, g.scale; 		    catch, g.scale      = 'on'; end;
   try, g.events; 		    catch, g.events      = []; end;
   try, g.ploteventdur;     catch, g.ploteventdur = 'off'; end;
   try, g.data2;            catch, g.data2      = []; end;
   try, g.plotdata2;        catch, g.plotdata2 = 'off'; end;
   try, g.mocap;		    catch, g.mocap		= 'off'; end; % nima
   try, g.selectcommand;     catch, g.selectcommand     = { '' '' '' }; end; % { defdowncom defmotioncom defupcom }
   try, g.ctrlselectcommand; catch, g.ctrlselectcommand = { '' '' '' }; end; % { defctrldowncom defctrlmotioncom defctrlupcom }
   try, g.datastd;          catch, g.datastd = []; end; %ozgur
   try, g.normed;            catch, g.normed = 0; end; %ozgur
   try, g.envelope;          catch, g.envelope = 0; end;%ozgur
   try, g.maxeventstring;    catch, g.maxeventstring = 10; end; % JavierLC
   try, g.isfreq;            catch, g.isfreq = 0;    end; % Ramon
      
   if strcmpi(g.ploteventdur, 'on')
       g.ploteventdur = 1; 
   else
       g.ploteventdur = 0; 
   end;
   
   if ndims(data) > 2
       g.trialstag = size(	data, 2);
   end;
   
   gfields = fieldnames(g);
   for index=1:length(gfields)
      switch gfields{index}
      case {'spacing', 'srate' 'eloc_file' 'winlength' 'fullscreen' 'position' 'title' 'plottitle' ...
               'trialstag'  'winrej' 'command' 'tag' 'xgrid' 'ygrid' 'color' 'colmodif'...
               'freqs' 'freqlimits' 'submean' 'children' 'limits' 'dispchans' 'wincolor' ...
               'maxeventstring' 'ploteventdur' 'butlabel' 'scale' 'events' 'data2' 'plotdata2' ...
               'mocap' 'selectcommand' 'ctrlselectcommand' 'datastd' 'normed' 'envelope' 'isfreq'}
      otherwise, error(['eegplot_w: unrecognized option: ''' gfields{index} '''' ]);
      end;
   end;

   % g.data=data; % never used and slows down display dramatically - Ozgur 2010
   
   if length(g.srate) ~= 1
   		disp('Error: srate must be a single number'); return;
   end;	
   if length(g.spacing) ~= 1
   		disp('Error: ''spacing'' must be a single number'); return;
   end;
   if length(g.winlength) ~= 1
   		disp('Error: winlength must be a single number'); return;
   end;	
   if ischar(g.title) ~= 1
   		disp('Error: title must be is a string'); return;
   end;	
   if ischar(g.command) ~= 1
   		disp('Error: command must be is a string'); return;
   end;	
   if ischar(g.tag) ~= 1
   		disp('Error: tag must be is a string'); return;
   end;	
   if ischar(g.fullscreen) ~= 1
   		disp('Error: position must be is a 4 elements array'); return;
   end;	
   if length(g.position) ~= 4
   		disp('Error: position must be is a 4 elements array'); return;
   end;	
   switch lower(g.xgrid)
	   case { 'on', 'off' }
       otherwise
           disp('Error: xgrid must be either ''on'' or ''off'''); return;
   end;	
   switch lower(g.ygrid)
	   case { 'on', 'off' }
       otherwise
           disp('Error: ygrid must be either ''on'' or ''off'''); return;
   end;	
   switch lower(g.submean)
	   case { 'on' 'off' }
       otherwise
           disp('Error: submean must be either ''on'' or ''off'''); return;
   end;	
   switch lower(g.scale)
	   case { 'on' 'off' }
       otherwise
           disp('Error: scale must be either ''on'' or ''off'''); return;
   end;	
   
   if ~iscell(g.color)
	   switch lower(g.color)
		case 'on', g.color = { 'k', 'm', 'c', 'b', 'g' }; 
		case 'off', g.color = { [ 0 0 0.4] };  
		otherwise 
		 disp('Error: color must be either ''on'' or ''off'' or a cell array'); 
                return;
	   end;	
   end;
   if length(g.dispchans) > size(data,1)
	   g.dispchans = size(data,1);
   end;
   if ~iscell(g.colmodif)
   		g.colmodif = { g.colmodif };
   end;
   if g.maxeventstring>20 % JavierLC
        disp('Error: maxeventstring must be equal or lesser than 20'); return;
   end;

   % max event string;  JavierLC
   % ---------------------------------
   MAXEVENTSTRING = g.maxeventstring;
   DEFAULT_AXES_POSITION = [0.05 0.03 0.865 1-(MAXEVENTSTRING-4)/100]; %[0.095 0.35 0.842 0.75-(MAXEVENTSTRING-5)/100];
   
   % convert color to modify into array of float
   % -------------------------------------------
   for index = 1:length(g.colmodif)
       if iscell(g.colmodif{index})
           tmpcolmodif{index} = g.colmodif{index}{1} ...
                                  + g.colmodif{index}{2}*10 ...
                                  + g.colmodif{index}{3}*100;
       else
           tmpcolmodif{index} = g.colmodif{index}(1) ...
                                  + g.colmodif{index}(2)*10 ...
                                  + g.colmodif{index}(3)*100;
       end;
   end;
   g.colmodif = tmpcolmodif;
   
   [g.chans,g.frames, tmpnb] = size(data);
   g.frames = g.frames*tmpnb;
  
  if g.spacing == 0
    g=optim_scale(data,g);
  end

  % set defaults
  % ------------ 
  g.incallback = 0;
  g.winstatus = 1;
  g.setelectrode  = 0;
  [g.chans,g.frames,tmpnb] = size(data);   
  g.frames = g.frames*tmpnb;
  g.nbdat = 1; % deprecated
  g.time  = 0;
  g.elecoffset = 0;
  
  % %%%%%%%%%%%%%%%%%%%%%%%%
  % Prepare figure and axes
  % %%%%%%%%%%%%%%%%%%%%%%%%
  
  figh = figure('UserData', g,... % store the settings here
      'Color',DEFAULT_FIG_COLOR, 'name', g.title,...
      'MenuBar','none','tag', g.tag ,'Position',g.position, ...
      'numbertitle', 'off', 'visible', 'off', 'Units', 'Normalized',...
      'interruptible', 'off', 'busyaction', 'cancel');
  if strcmp(g.fullscreen,'on')
      set(figh,'OuterPosition',[0 0 1 1]);
  end;
  pos = get(figh,'position'); % plot relative to current axes
  q = [pos(1) pos(2) 0 0];
  s = [pos(3) pos(4) pos(3) pos(4)]./100;
  clf;
  
  % Plot title if provided
  if ~isempty(g.plottitle)
      h = findobj('tag', 'eegplottitle'); 
      if ~isempty(h)
          set(h, 'string',g.plottitle);
      else
          h = textsc(g.plottitle, 'title'); 
          set(h, 'tag', 'eegplottitle');
      end;
  end
      
  % Background axis
  % --------------- 
  ax0 = axes('tag','backeeg','parent',figh,...
      'Position',DEFAULT_AXES_POSITION,...
      'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized'); 

  % Drawing axis
  % --------------- 
  YLabels = num2str((1:g.chans)');  % Use numbers as default
  YLabels = flipud(char(YLabels,' '));
  ax1 = axes('Position',DEFAULT_AXES_POSITION,...
      'userdata', data, ...% store the data here
      'tag','eegaxis','parent',figh,...%(when in g, slow down display)
      'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
      'gridlinestyle',DEFAULT_GRID_STYLE,...
      'Xlim',[0 g.winlength*g.srate],...
      'xtick',[0:g.srate*DEFAULT_GRID_SPACING:g.winlength*g.srate],...
      'Ylim',[0 (g.chans+1)*g.spacing],...
      'YTick',[0:g.spacing:g.chans*g.spacing],...
      'YTickLabel', YLabels,...
      'XTickLabel',num2str((0:DEFAULT_GRID_SPACING:g.winlength)'),...
      'TickLength',[.005 .005],...
      'Color','none',...
      'XColor',DEFAULT_AXIS_COLOR,...
      'YColor',DEFAULT_AXIS_COLOR,...
      'FontSize',8);

  if ischar(g.eloc_file) || isstruct(g.eloc_file)  % Read in electrode names
      if isstruct(g.eloc_file) && length(g.eloc_file) > size(data,1)
          g.eloc_file(end) = []; % common reference channel location
      end;
      eegplot_w('setelect', g.eloc_file, ax1);
  end;
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uicontrols
  % %%%%%%%%%%%%%%%%%%%%%%%%%

% positions of buttons
  posbut(1,:) =  [ 0.92    0.49    0.020    0.03 ]; % <<
  posbut(2,:) =  [ 0.94    0.49    0.020    0.03 ]; % <
  posbut(3,:) =  [ 0.96    0.49    0.020    0.03 ]; % >
  posbut(4,:) =  [ 0.98    0.49    0.020    0.03 ]; % >>
  posbut(5,:) =  [ 0.92    0.52    0.080    0.03 ]; % Eposition
  posbut(6,:) =  [ 0.92    0.41    0.080    0.03 ]; % Espacing/scale
  posbut(7,:) =  [ 0.92    0.70    0.080    0.03 ]; % elec
  posbut(8,:) =  [ 0.92    0.55    0.080    0.03 ]; % g.time
  posbut(9,:) =  [ 0.92    0.63    0.080    0.03 ]; % value
  posbut(14,:) = [ 0.92    0.73    0.080    0.03 ]; % elec tag
  posbut(15,:) = [ 0.92    0.58    0.080    0.03 ]; % g.time tag
  posbut(16,:) = [ 0.92    0.66    0.080    0.03 ]; % value tag
  posbut(10,:) = [ 0.96    0.38    0.020    0.03 ]; % +
  posbut(11,:) = [ 0.94    0.38    0.020    0.03 ]; % -
  posbut(12,:) = [ 0.92    0.03    0.080    0.05 ]; % accept/close
  posbut(13,:) = [ 0.92    0.15    0.080    0.03 ]; % cancel/close
  posbut(17,:) = [ 0.92    0.82    0.080    0.03 ]; % events types
  posbut(20,:) = [ 0.005   0.02    0.010    0.96 ]; % slider
  posbut(21,:) = [ 0.92    0.90    0.080    0.03 ]; % normalize
  posbut(22,:) = [ 0.92    0.94    0.080    0.03 ]; % stack channels(same offset)
  posbut(23,:) = [ 0.92    0.44    0.080    0.03 ]; % Espacing/scale tag

% Five move buttons: << < text > >> 

  u(1) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(1,:), ...
	'Tag','Pushbutton1',...
	'string','<<',...
    'FontSize',8,...
	'Callback',{@draw_data,figh,1,[],[],ax1});
  u(2) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(2,:), ...
	'Tag','Pushbutton2',...
	'string','<',...
	'Callback',{@draw_data,figh,2,[],[],ax1});
  u(5) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(5,:), ...
	'Style','edit', ...
	'Tag','EPosition',...
	'string', fastif(g.trialstag(1) == -1, '0', '1'),...
	'Callback', {@draw_data,figh,0,[],[],ax1});
  u(3) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(3,:), ...
	'Tag','Pushbutton3',...
	'string','>',...
	'Callback',{@draw_data,figh,3,[],[],ax1});
  u(4) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(4,:), ...
	'Tag','Pushbutton4',...
	'string','>>',...
    'FontSize',8,...
	'Callback',{@draw_data,figh,4,[],[],ax1});

% Text edit fields: ESpacing

  u(6) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',[1 1 1], ...
	'Position', posbut(6,:), ...
	'Style','edit', ...
	'Tag','ESpacing',...
	'string',num2str(g.spacing),...
	'Callback', {@change_scale,figh,0,ax1} );

% Slider for vertical motion
  u(20) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position', posbut(20,:), ...
   'Style','slider', ...
   'visible', 'off', ...
   'sliderstep', [0.9 1], ...
   'Tag','eegslider', ...
   'callback',{@draw_data,figh,0,[],[],ax1,'g.elecoffset = get(gcbo, ''value'')*(g.chans-g.dispchans);'}, ...
   'value', 0);

% Channels, position, value and tag

  u(9) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(7,:), ...
	'Style','text', ...
	'Tag','Eelec',...
	'string',' ');
  u(10) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(8,:), ...
	'Style','text', ...
	'Tag','Etime',...
	'string','0.00');
  u(11) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position',posbut(9,:), ...
	'Style','text', ...
	'Tag','Evalue',...
	'string','0.00');

  u(14)= uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(14,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','Eelecname',...
	'string','Channel');

  u(23)= uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(23,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','thescale',...
	'string','Scale');

% Values of time/value and freq/power in GUI
  if g.isfreq
      u15_string =  'Freq';
      u16_string  = 'Power';
  else
      u15_string =  'Time';
      u16_string  = 'Value';
  end
      
  u(15) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position', posbut(15,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','Etimename',...
	'string',u15_string);

  u(16) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'BackgroundColor',DEFAULT_FIG_COLOR, ...
	'Position',posbut(16,:), ...
	'Style','text', ...
	'FontSize',8,...
	'Tag','Evaluename',...
	'string',u16_string);

% ESpacing buttons: + -
  u(7) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(10,:), ...
	'Tag','Pushbutton5',...
	'string','+',...
	'FontSize',10,...
	'Callback',{@change_scale,figh,1,ax1});
  u(8) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(11,:), ...
	'Tag','Pushbutton6',...
	'string','-',...
	'FontSize',10,...
	'Callback',{@change_scale,figh,2,ax1});

% Button for Normalizing data
u(21) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(21,:), ...
    'Tag','Norm',...
    'string','Norm', 'callback', {@normalize_chan,figh});

cb_envelope = ['g = get(gcbf,''userdata'');'...
    'hmenu = findobj(gcf, ''Tag'', ''Envelope_menu'');' ...
    'g.envelope = ~g.envelope;' ...
    'set(gcbf,''userdata'',g);'...
    'set(gcbo,''string'',fastif(g.envelope,''Spread'',''Stack''));' ...
    'set(hmenu, ''Label'', fastif(g.envelope,''Spread channels'',''Stack channels''));' ...
    'eegplot_w(''drawp'',0);clear g;'];

% Button to plot envelope of data
u(22) = uicontrol('Parent',figh, ...
    'Units', 'normalized', ...
    'Position',posbut(22,:), ...
    'Tag','Envelope',...
    'string','Stack', 'callback', cb_envelope);

  if isempty(g.command) tmpcom = 'fprintf(''Rejections saved in variable TMPREJ\n'');';   
  else tmpcom = g.command;
  end;
  acceptcommand = [ 'g = get(gcbf, ''userdata'');' ... 
				    'TMPREJ = g.winrej;' ...
                    'if isfield(g, ''eloc_file'') && isfield(g.eloc_file, ''badchan''); '...
                         'TMPREJCHN = find([g.eloc_file.badchan]); '...
                    'else TMPREJCHN = [];'...
                    'end; ' ...
                    'if g.children, delete(g.children); end;' ...
                    'delete(gcbf);' ...
		  				  tmpcom ...
                    '; clear g;']; % quitting expression
  if ~isempty(g.command)
	  u(12) = uicontrol('Parent',figh, ...
						'Units', 'normalized', ...
						'Position',posbut(12,:), ...
						'Tag','Accept',...
						'string',g.butlabel, 'callback', acceptcommand);
  end;
  u(13) = uicontrol('Parent',figh, ...
	'Units', 'normalized', ...
	'Position',posbut(13,:), ...
	'string',fastif(isempty(g.command),'CLOSE', 'CANCEL'), 'callback', ...
		[	'g = get(gcbf, ''userdata'');' ... 
            'if g.children, delete(g.children); end;' ...
			'close(gcbf);'] );

  if ~isempty(g.events)
      u(17) = uicontrol('Parent',figh, ...
                        'Units', 'normalized', ...
                        'Position',posbut(17,:), ...
                        'string', 'Events', 'callback', 'eegplot_w(''drawlegend'', gcbf)');
  end;

  for i = 1: length(u) % Matlab 2014b compatibility
      if isprop(eval(['u(' num2str(i) ')']),'Style')
          set(u(i),'Units','Normalized');
      end
  end
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uimenus
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Figure Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  m(7) = uimenu('Parent',figh,'Label','Figure');
  m(8) = uimenu('Parent',m(7),'Label','Print');
  uimenu('Parent',m(7),'Label','Edit figure', 'Callback', 'eegplot_w(''noui'');');
  uimenu('Parent',m(7),'Label','Accept and close', 'Callback', acceptcommand );
  uimenu('Parent',m(7),'Label','Cancel and close', 'Callback','delete(gcbf)')
  
  % Portrait %%%%%%%%

  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''portrait'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
		
  uimenu('Parent',m(8),'Label','Portrait','checked',...
      'on','tag','orient','callback',timestring)
  
  % Landscape %%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''landscape'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
  
  uimenu('Parent',m(8),'Label','Landscape','checked',...
      'off','tag','orient','callback',timestring)

  % Print command %%%%%%%
  uimenu('Parent',m(8),'Label','Print','tag','printcommand','callback',...
  		['RESULT = inputdlg2( { ''Command:'' }, ''Print'', 1,  { ''print -r72'' });' ...
		 'if size( RESULT,1 ) ~= 0' ... 
		 '  eval ( RESULT{1} );' ...
		 'end;' ...
		 'clear RESULT;' ]);
  
  % Display Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  m(1) = uimenu('Parent',figh,...
      'Label','Display', 'tag', 'displaymenu');
  
  % window grid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % userdata = 4 cells : display yes/no, color, electrode yes/no, 
  %                      trial boundary adapt yes/no (1/0)  
  m(11) = uimenu('Parent',m(1),'Label','Data select/mark', 'tag', 'displaywin', ...
            'userdata', { 1, [0.8 1 0.8], 0, fastif( g.trialstag(1) == -1, 0, 1)});

          uimenu('Parent',m(11),'Label','Hide marks','Callback', ...
  	        ['g = get(gcbf, ''userdata'');' ...
            'if ~g.winstatus' ... 
            '  set(gcbo, ''label'', ''Hide marks'');' ...
            'else' ...
            '  set(gcbo, ''label'', ''Show marks'');' ...
            'end;' ...
            'g.winstatus = ~g.winstatus;' ...
            'set(gcbf, ''userdata'', g);' ...
            'eegplot_w(''drawb''); clear g;'] )

	% color %%%%%%%%%%%%%%%%%%%%%%%%%%
    if isunix % for some reasons, does not work under Windows
        uimenu('Parent',m(11),'Label','Choose color', 'Callback', ...
               [ 'g = get(gcbf, ''userdata'');' ...
                 'g.wincolor = uisetcolor(g.wincolor);' ...
                 'set(gcbf, ''userdata'', g ); ' ...
                 'clear g;'] )
    end;

  % plot durations
  % --------------
  if g.ploteventdur && isfield(g.events, 'duration')
      disp(['Use menu "Display > Hide event duration" to hide colored regions ' ...
           'representing event duration']);
  end;
  if isfield(g.events, 'duration')
      uimenu('Parent',m(1),'Label',fastif(g.ploteventdur, 'Hide event duration', 'Plot event duration'),'Callback', ...
             ['g = get(gcbf, ''userdata'');' ...
              'if ~g.ploteventdur' ... 
              '  set(gcbo, ''label'', ''Hide event duration'');' ...
              'else' ...
              '  set(gcbo, ''label'', ''Show event duration'');' ...
              'end;' ...
              'g.ploteventdur = ~g.ploteventdur;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_w(''drawb''); clear g;'] )
  end;

  % X grid %%%%%%%%%%%%
  m(3) = uimenu('Parent',m(1),'Label','Grid');
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''xgrid''),2) == 2' ... %on
		        '  set(AXESH,''xgrid'',''off'');',...
		        '  set(gcbo,''label'',''X grid on'');',...
		        'else' ...
		        '  set(AXESH,''xgrid'',''on'');',...
		        '  set(gcbo,''label'',''X grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label',fastif(strcmp(g.xgrid, 'off'), ...
         'X grid on','X grid off'), 'Callback',timestring)
  
  % Y grid %%%%%%%%%%%%%
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''ygrid''),2) == 2' ... %on
		        '  set(AXESH,''ygrid'',''off'');',...
		        '  set(gcbo,''label'',''Y grid on'');',...
		        'else' ...
		        '  set(AXESH,''ygrid'',''on'');',...
		        '  set(gcbo,''label'',''Y grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label',fastif(strcmp(g.ygrid, 'off'), ...
         'Y grid on','Y grid off'), 'Callback',timestring)

  % Grid Style %%%%%%%%%
  m(5) = uimenu('Parent',m(3),'Label','Grid Style');
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''--'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','- -','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-.'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','_ .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'','':'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','. .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','__','Callback',timestring)
  
  % Submean menu %%%%%%%%%%%%%
  cb =       ['g = get(gcbf, ''userdata'');' ...
              'if strcmpi(g.submean, ''on''),' ... 
              '  set(gcbo, ''label'', ''Remove DC offset'');' ...
              '  g.submean =''off'';' ...
              'else' ...
              '  set(gcbo, ''label'', ''Do not remove DC offset'');' ...
              '  g.submean =''on'';' ...
              'end;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_w(''drawp'', 0); clear g;'];
  uimenu('Parent',m(1),'Label',fastif(strcmp(g.submean, 'on'), ...
         'Do not remove DC offset','Remove DC offset'), 'Callback',cb)

  % Scale Eye %%%%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'eegplot_w(''scaleeye'',OBJ1,FIG1);',...
		'clear OBJ1 FIG1;'];
  m(7) = uimenu('Parent',m(1),'Label','Show scale','Callback',timestring);
  
  % Title %%%%%%%%%%%%
  uimenu('Parent',m(1),'Label','Title','Callback','eegplot_w(''title'')')
  
  % Stack/Spread %%%%%%%%%%%%%%%
  cb =       ['g = get(gcbf, ''userdata'');' ...
              'hbutton = findobj(gcf, ''Tag'', ''Envelope'');' ...  % find button
              'if g.envelope == 0,' ... 
              '  set(gcbo, ''label'', ''Spread channels'');' ...
              '  g.envelope = 1;' ...
              '  set(hbutton, ''String'', ''Spread'');' ...
              'else' ...
              '  set(gcbo, ''label'', ''Stack channels'');' ...
              '  g.envelope = 0;' ...
              '  set(hbutton, ''String'', ''Stack'');' ...
              'end;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_w(''drawp'', 0); clear g;'];
  uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
         'Stack channels','Spread channels'), 'Callback',cb, 'Tag', 'Envelope_menu')
     
  % Normalize/denormalize %%%%%%%%%%%%%%%
  uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
         'Normalize channels','Denormalize channels'), 'Callback', {@normalize_chan,figh}, 'Tag', 'Normalize_menu')

  
  % Settings Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(2) = uimenu('Parent',figh,...
      'Label','Settings'); 
  
  % Window %%%%%%%%%%%%
  uimenu('Parent',m(2),'Label','Time range to display',...
      'Callback','eegplot_w(''window'')')
  
  % Electrode window %%%%%%%%
  uimenu('Parent',m(2),'Label','Number of channels to display',...
      'Callback','eegplot_w(''winelec'')')
  
  % Electrodes %%%%%%%%
  m(6) = uimenu('Parent',m(2),'Label','Channel labels');
  
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'YTICK = get(AXESH,''YTick'');',...
		'YTICK = length(YTICK);',...
		'set(AXESH,''YTickLabel'',flipud(char(num2str((1:YTICK-1)''),'' '')));',...
		'clear FIGH AXESH YTICK;'];
  uimenu('Parent',m(6),'Label','Show number','Callback',timestring)
  uimenu('Parent',m(6),'Label','Load .loc(s) file',...
      'Callback','eegplot_w(''loadelect'');')
  
  % Zooms %%%%%%%%
 % if ismatlab && verLessThan('matlab','8.4.0')
 %     zm = uimenu('Parent',m(2),'Label','Zoom off/on');
 %     commandzoom = [ 'set(gcbf, ''WindowButtonDownFcn'', [ ''zoom(gcbf,''''down''''); eegplot(''''zoom'''', gcbf, 1);'' ]);' ...
 %         'tmpg = get(gcbf, ''userdata'');' ...
 %         'clear tmpg tmpstr;'];
 %     uimenu('Parent',zm,'Label','Zoom on', 'callback', commandzoom);
 %     uimenu('Parent',zm,'Label','Zoom off', 'separator', 'on', 'callback', ...
 %         ['zoom(gcbf, ''off''); tmpg = get(gcbf, ''userdata'');' ...
 %         'set(gcbf, ''windowbuttondownfcn'', tmpg.commandselect{1});' ...
 %         'set(gcbf, ''windowbuttonupfcn'', tmpg.commandselect{3});' ...
 %         'clear tmpg;' ]);
 % else
 %      % This is failing for us http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
 %      uimenu('Parent',m(2),'Label','Zoom off/on', 'callback', 'warning(''FIXME: Zoom not work in MATLAB >= 8.4.0'')');
 % end
      
  uimenu('Parent',figh,'Label', 'Help', 'callback', 'pophelp(''eegplot_w'');');

  % Events %%%%%%%%
  ev = uimenu('Parent',m(2),'Label','Events');
  comeventmaxstring   = [ 'tmpg = get(gcbf, ''userdata'');' ...
                'tmpg.plotevent = ''on'';' ...
                'set(gcbf, ''userdata'', tmpg); clear tmpg; eegplot_w(''emaxstring'');']; % JavierLC      
  comeventleg  = [ 'eegplot_w(''drawlegend'', gcbf);'];
    
  uimenu('Parent',ev,'Label','Events on'    , 'callback', {@draw_data,figh,0,[],[],ax1,'g.plotevent = ''on'';'},  'enable', fastif(isempty(g.events), 'off', 'on'));
  uimenu('Parent',ev,'Label','Events off'   , 'callback', {@draw_data,figh,0,[],[],ax1,'g.plotevent = ''off'';'}, 'enable', fastif(isempty(g.events), 'off', 'on'));
  uimenu('Parent',ev,'Label','Events'' string length'   , 'callback', comeventmaxstring, 'enable', fastif(isempty(g.events), 'off', 'on')); % JavierLC
  uimenu('Parent',ev,'Label','Events'' legend', 'callback', comeventleg , 'enable', fastif(isempty(g.events), 'off', 'on'));
  

  % %%%%%%%%%%%%%%%%%
  % Set up autoselect                                                        
  % NOTE: commandselect{2} option has been moved to a
  %       subfunction to improve speed
  %%%%%%%%%%%%%%%%%%%
  if ~isempty(g.ctrlselectcommand{1}) || ~isempty(g.ctrlselectcommand{3}) || ...
         ~isempty(g.selectcommand{1}) || ~isempty(g.selectcommand{3})
      g.commandselect{1} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' ...
           g.ctrlselectcommand{1} '; else ' g.selectcommand{1} '; end;' ];
      g.commandselect{3} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' ...
           g.ctrlselectcommand{3} '; else ' g.selectcommand{3} '; end;' ];
      set(figh, 'windowbuttondownfcn',   g.commandselect{1});
      set(figh, 'windowbuttonupfcn',     g.commandselect{3});
  else
      set(figh, 'windowbuttondownfcn',   {@mouse_down,figh});
      set(figh, 'windowbuttonupfcn',     {@mouse_up,figh});
  end;
  set(figh, 'WindowScrollWheelFcn',  {@mouse_scroll_wheel,figh,ax0,ax1,u(10),u(11),u(9)});
  set(figh, 'windowbuttonmotionfcn', {@mouse_motion,figh,ax0,ax1,u(10),u(11),u(9)});
  set(figh, 'WindowKeyPressFcn',     {@eegplot_readkey,figh,ax0,ax1,u(10),u(11),u(9)});
  set(figh, 'interruptible', 'off');
%  set(figh, 'busyaction', 'cancel');
%  set(figh, 'windowbuttondownfcn', commandpush);
%  set(figh, 'windowbuttonmotionfcn', commandmove);
%  set(figh, 'windowbuttonupfcn', commandrelease);
  
  % prepare event array if any
  % --------------------------
  if ~isempty(g.events)
      if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end;
  end;
      
  if ~isempty(g.events)
      if ischar(g.events(1).type)
           [g.eventtypes, ~, indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
      else [g.eventtypes, ~, indexcolor] = unique_bc([ g.events.type ]);
      end;
      %indexcolor=length(indexcolor)-indexcolor+1;
      g.eventcolors     = { 'r', [0 0.8 0], 'b', 'm', [1 0.5 0],  [0.5 0 0.5], [0.6 0.3 0] };  
      g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
      g.eventwidths     = [ 2.5 1 ];
      g.eventtypecolors = g.eventcolors(mod([1:length(g.eventtypes)]-1 ,length(g.eventcolors))+1);
      g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
      g.eventtypestyle  = g.eventstyle (mod([1:length(g.eventtypes)]-1 ,length(g.eventstyle))+1);
      g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);
      
      % for width, only boundary events have width 2 (for the line)
      % -----------------------------------------------------------
      indexwidth = ones(1,length(g.eventtypes))*2;
      if iscell(g.eventtypes)
          index=find(ismember(g.eventtypes,{'boundary'}));
          if ~isempty(index)
              indexwidth(index) = 1;
              g.eventtypestyle{index} = '-';
              g.eventtypecolors{index} = 'c';
              g.eventstyle(find(indexcolor==index))={'-'};
              g.eventcolors(find(indexcolor==index))={'c'};
          end;
      end;
      g.eventtypewidths = g.eventwidths (mod(indexwidth([1:length(g.eventtypes)])-1 ,length(g.eventwidths))+1);
      g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);
      
      % latency and duration of events
      % ------------------------------
      g.eventlatencies  = [ g.events.latency ]+1;
      if isfield(g.events, 'duration')
           durations = { g.events.duration };
           durations(cellfun(@isempty, durations)) = { NaN };
           g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
      else g.eventlatencyend   = [];
      end;
      g.plotevent       = 'on';
  end;
  if isempty(g.events)
      g.plotevent      = 'off';
  end;

  set(figh, 'userdata', g);
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot EEG Data
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  axes(ax1)
  hold on
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot Spacing I
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  YLim = get(ax1,'Ylim');
  A = DEFAULT_AXES_POSITION;
  axes('Position',[A(1)+A(3) 0.3 1-A(1)-A(3) A(4)],'Visible','off','Ylim',YLim,'tag','eyeaxes')
  axis manual
  if strcmp(SPACING_EYE,'on')
      set(m(7),'checked','on')
  else
      set(m(7),'checked','off');
  end 
  eegplot_w('scaleeye', [], gcf);
  if strcmp(lower(g.scale), 'off')
	  eegplot_w('scaleeye', 'off', gcf);
  end;
  
  eegplot_w('drawp', 0);
  if g.dispchans ~= g.chans
  	   eegplot_w('zoom', gcf);
  end;  
  eegplot_w('scaleeye', [], gcf);
  
  h = findobj(gcf, 'style', 'pushbutton');
  set(h, 'backgroundcolor', BUTTON_COLOR);
  h = findobj(gcf, 'tag', 'eegslider');
  set(h, 'backgroundcolor', BUTTON_COLOR);
  set(figh, 'visible', 'on');
  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Main Function
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
  try p1 = varargin{1}; p2 = varargin{2}; catch, end;
  switch data
  case 'drawp'
    % Redraw EEG and change position
    draw_data([],[],gcf,p1)
    
  case 'drawb' 
    % Draw background
    draw_background
    
  case 'draws'
    % Redraw EEG and change scale
    change_scale([],[],gcf,p1)

  case 'draww'
    % Redraw EEG and change window size
    change_eeg_window_length([],[],gcf,p1)
    
  case 'window'  % change window size
    % get new window length with dialog box
    % -------------------------------------
    g = get(gcf,'UserData');
	result       = inputdlg2( { fastif(g.trialstag==-1,'New window length (s):', 'Number of epoch(s):') }, 'Change window length', 1,  { num2str(g.winlength) });
	if size(result,1) == 0 return; end;

	g.winlength = eval(result{1}); 
	set(gcf, 'UserData', g);
	eegplot_w('drawp',0);	
	return;
    
  case 'winelec'  % change channel window size
                  % get new window length with dialog box
                  % -------------------------------------
   fig = gcf;
   g = get(gcf,'UserData');
   result = inputdlg2( ...
{ 'Number of channels to display:' } , 'Change number of channels to display', 1,  { num2str(g.dispchans) });
   if size(result,1) == 0 return; end;
   
   g.dispchans = eval(result{1});
   if g.dispchans<0 || g.dispchans>g.chans
       g.dispchans =g.chans;
   end;
   set(gcf, 'UserData', g);
   eegplot_w('updateslider', fig);
   eegplot_w('drawp',0);	
   eegplot_w('scaleeye', [], fig);
   return;
   
   case 'emaxstring'  % change events' string length  ;  JavierLC
      % get dialog box
      % -------------------------------------
      g = get(gcf,'UserData');
      result = inputdlg2({ 'Max events'' string length:' } , 'Change events'' string length to display', 1,  { num2str(g.maxeventstring) });
      if size(result,1) == 0 return; end;                  
      g.maxeventstring = eval(result{1});
      set(gcf, 'UserData', g);
      eegplot_w('drawb');
      return;
      
  case 'loadelect' % load channels
	[inputname,inputpath] = uigetfile('*','Channel locations file');
	if inputname == 0 return; end;
	if ~exist([ inputpath inputname ],'file')
		error('no such file');
	end;

	AXH0 = findobj('tag','eegaxis','parent',gcf);
	eegplot_w('setelect',[ inputpath inputname ],AXH0);
	return;
  
  case 'setelect'
    % Set channels    
    eloc_file = p1;
    axeshand = p2;
    outvar1 = 1;
    if isempty(eloc_file)
      outvar1 = 0;
      return
    end
    
    tmplocs = readlocs(eloc_file);
	YLabels = { tmplocs.labels };
    YLabels = strvcat(YLabels);
    
    YLabels = flipud(char(YLabels,' '));
    set(axeshand,'YTickLabel',YLabels)
  
  case 'title'
    % Get new title
	h = findobj('tag', 'eegplottitle');
	
	if ~isempty(h)
		result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { get(h(1), 'string') });
		if ~isempty(result), set(h, 'string', result{1}); end;
	else 
		result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { '' });
		if ~isempty(result), h = textsc(result{1}, 'title'); set(h, 'tag', 'eegplottitle');end;
	end;
	
	return;

  case 'scaleeye'
    % Turn scale I on/off
    obj = p1;
    figh = p2;
	g = get(figh,'UserData');
    % figh = get(obj,'Parent');

    if ~isempty(obj)
		eyeaxes = findobj('tag','eyeaxes','parent',figh);
		children = get(eyeaxes,'children');
		if ischar(obj)
			if strcmp(obj, 'off')
				set(children, 'visible', 'off');
				set(eyeaxes, 'visible', 'off');
				return;
			else
				set(children, 'visible', 'on');
				set(eyeaxes, 'visible', 'on');
			end;
		else
			toggle = get(obj,'checked');
			if strcmp(toggle,'on')
				set(children, 'visible', 'off');
				set(eyeaxes, 'visible', 'off');
				set(obj,'checked','off');
				return;
			else
				set(children, 'visible', 'on');
				set(eyeaxes, 'visible', 'on');
				set(obj,'checked','on');
			end;
		end;
    end;
	
	eyeaxes = findobj('tag','eyeaxes','parent',figh);
    ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
	YLim = double(get(ax1, 'ylim'));
    
	ESpacing = findobj('tag','ESpacing','parent',figh);
	g.spacing= str2num(get(ESpacing,'string'));
	
	axes(eyeaxes); cla; axis off;
    set(eyeaxes, 'ylim', YLim);
    set(eyeaxes, 'xlim', [0 1]);
    
	Xl = double([.01 .05; .03 .03; .01 .05]);
    Yl = double([ g.spacing g.spacing; g.spacing 0; 0 0] + YLim(1));
	plot(Xl(1,:),Yl(1,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline'); hold on;
	plot(Xl(2,:),Yl(2,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
	plot(Xl(3,:),Yl(3,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
    set(eyeaxes, 'tag', 'eyeaxes');
    
  case 'noui'
      if ~isempty(varargin)
          eegplot_w( varargin{:} ); fig = gcf;
      else 
          fig = findobj('tag', 'eegplot_w');
      end;
      set(fig, 'menubar', 'figure');
      
      % find button and text
      obj = findobj(fig, 'style', 'pushbutton'); delete(obj);
      obj = findobj(fig, 'style', 'edit'); delete(obj);
      obj = findobj(fig, 'style', 'text'); 
      %objscale = findobj(obj, 'tag', 'thescale');
      %delete(setdiff(obj, objscale));
	  obj = findobj(fig, 'tag', 'Eelec');delete(obj);
	  obj = findobj(fig, 'tag', 'Etime');delete(obj);
	  obj = findobj(fig, 'tag', 'Evalue');delete(obj);
	  obj = findobj(fig, 'tag', 'Eelecname');delete(obj);
	  obj = findobj(fig, 'tag', 'Etimename');delete(obj);
	  obj = findobj(fig, 'tag', 'Evaluename');delete(obj);
	  obj = findobj(fig, 'type', 'uimenu');delete(obj);
 
   case 'zoom' % if zoom
      fig = varargin{1};
      ax1 = findobj('tag','eegaxis','parent',fig); 
      ax2 = findobj('tag','backeeg','parent',fig); 
      tmpxlim  = get(ax1, 'xlim');
      tmpylim  = get(ax1, 'ylim');
      tmpxlim2 = get(ax2, 'xlim');
      set(ax2, 'xlim', get(ax1, 'xlim'));
      g = get(fig,'UserData');
      
      % deal with abscissa
      % ------------------
      if g.trialstag ~= -1
          Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'));
          g.winlength = (tmpxlim(2) - tmpxlim(1))/g.trialstag;
          Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.trialstag;
          Eposition = round(Eposition*1000)/1000;
          set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition));
      else
          Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'))-1;
          g.winlength = (tmpxlim(2) - tmpxlim(1))/g.srate;	
          Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.srate;
          Eposition = round(Eposition*1000)/1000;
          set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition+1));
      end;  
      
      % deal with ordinate
      % ------------------
      g.elecoffset = tmpylim(1)/g.spacing;
      g.dispchans  = round(1000*(tmpylim(2)-tmpylim(1))/g.spacing)/1000;      
      
      set(fig,'UserData', g);
      eegplot_w('updateslider', fig);
      eegplot_w('drawp', 0);
      eegplot_w('scaleeye', [], fig);

      % reactivate zoom if 3 arguments
      % ------------------------------
      if exist('p2', 'var') == 1
          if ismatlab && verLessThan('matlab','8.4.0')
              set(gcbf, 'windowbuttondownfcn', [ 'zoom(gcbf,''down''); eegplot(''zoom'', gcbf, 1);' ]);
          else
              warning('FIXME: Zoom not work in MATLAB >= 8.4.0')
          end
      end;

	case 'updateslider' % if zoom
      fig = varargin{1};
      g = get(fig,'UserData');
      sliider = findobj('tag','eegslider','parent',fig);
      if g.elecoffset < 0
         g.elecoffset = 0;
      end;
      if g.dispchans >= g.chans
         g.dispchans = g.chans;
         g.elecoffset = 0;
         set(sliider, 'visible', 'off');
      else
         set(sliider, 'visible', 'on');         
		 set(sliider, 'value', g.elecoffset/g.chans, ...
					  'sliderstep', [1/(g.chans-g.dispchans) g.dispchans/(g.chans-g.dispchans)]);
         %'sliderstep', [1/(g.chans-1) g.dispchans/(g.chans-1)]);
      end;
      if g.elecoffset < 0
         g.elecoffset = 0;
      end;
      if g.elecoffset > g.chans-g.dispchans
         g.elecoffset = g.chans-g.dispchans;
      end;
      set(fig,'UserData', g);
	  eegplot_w('scaleeye', [], fig);
   
   case 'drawlegend'
      fig = varargin{1};
      g = get(fig,'UserData');
      
      if ~isempty(g.events) % draw vertical colored lines for events, add event name text above
          nleg = length(g.eventtypes);
          fig2 = figure('numbertitle', 'off', 'name', '', 'visible', 'off', 'menubar', 'none', 'color', DEFAULT_FIG_COLOR);
          pos = get(fig2, 'position');
          set(fig2, 'position', [ pos(1) pos(2) 130 14*nleg+20]);
          
          for index = 1:nleg
              plot([10 30], [(index-0.5) * 10 (index-0.5) * 10], 'color', g.eventtypecolors{index}, 'linestyle', ...
                          g.eventtypestyle{ index }, 'linewidth', g.eventtypewidths( index )); hold on;
              if iscell(g.eventtypes)
                  th=text(35, (index-0.5)*10, g.eventtypes{index}, ...
                                    'color', g.eventtypecolors{index});
              else
                  th=text(35, (index-0.5)*10, num2str(g.eventtypes(index)), ...
                                    'color', g.eventtypecolors{index});
              end;
          end;
          xlim([0 130]);
          ylim([0 nleg*10]);
          axis off;
          set(fig2, 'visible', 'on');
      end;


  % motion button: move windows or display current position (channel, g.time and activation)
  % ----------------------------------------------------------------------------------------
   % case moved as subfunction    
  % add topoplot
  % ------------
  case 'topoplot'
    fig = varargin{1};
    g = get(fig,'UserData');
    if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
        return;
    end;
    ax1 = findobj('tag','backeeg','parent',fig); 
    tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    % plot vertical line
    yl = ylim(ax1);
    plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    
    if g.trialstag ~= -1
          lowlim = round(g.time*g.trialstag+1);
    else, lowlim = round(g.time*g.srate+1);
    end;
    data = get(ax1,'UserData');
    datapos = max(1, round(tmppos(1)+lowlim));
    datapos = min(datapos, g.frames);

    figure; topoplot(data(:,datapos), g.eloc_file);
    if g.trialstag == -1
         latsec = (datapos-1)/g.srate;
         title(sprintf('Latency of %d seconds and %d milliseconds', floor(latsec), round(1000*(latsec-floor(latsec)))));
    else
        trial = ceil((datapos-1)/g.trialstag);
        latintrial = eeg_point2lat(datapos, trial, g.srate, g.limits, 0.001);
        title(sprintf('Latency of %d ms in trial %d', round(latintrial), trial));
    end;
    
  % release button: check window consistency, add to trial boundaries
  % -------------------------------------------------------------------
  case 'defupcom'
    mouse_up([],[],varargin{1}); % Just for compatibility with original eegplot()
         
  % push button: create/remove window
  % ---------------------------------
  case 'defdowncom'
      mouse_down([],[],varargin{1}); % Just for compatibility with original eegplot()
   otherwise
      error(['Error - invalid eegplot_w() parameter: ',data])
  end
end

% Redraw EEG and change position
% ---------------------------------
function draw_data(varargin)

    if nargin >= 3
        figh = varargin{3};
        %figure(figh);
    else
        figh = gcf;
    end;
    if strcmp(get(figh,'tag'),'dialog')
        figh = get(figh,'UserData');
    end
    
    if nargin >= 4
        p1 = varargin{4};
        if ~isnumeric(p1)
            p1 = 0;
        end;
    else
        p1 = 0;
    end;
    
    if nargin >= 5 % Children Object
        p2 = varargin{5};
    else
        p2 = [];
    end;
    
    g = [];
    if nargin >= 6
        g = varargin{6};
    end;
    if isempty(g)
        g = get(figh,'UserData');
    end;
    if ~isfield(g,'trialstag')
        return;
    end;
    
    ax1 = [];
    if nargin >= 7
        ax1 = varargin{7};
    end;
    if isempty(ax1)
        ax1 = findobj('tag','eegaxis','parent',figh); % axes handle
    end;
    
    if nargin >= 8
        custom_command = varargin{8};
    else
        custom_command = '';
    end;
    
    % compare versions once, because it slows down drawing
    verLessThan_matlab_9 = ismatlab && verLessThan('matlab','9.0.0');
    
    %axes(ax1);
    data = get(ax1,'UserData');
    ESpacing  = findobj('tag','ESpacing', 'parent',figh); % ui handle
    EPosition = findobj('tag','EPosition','parent',figh); % ui handle
    if ~isempty(EPosition) && ~isempty(ESpacing)
        EPosition_new = str2num(get(EPosition,'string'));
        if ~isempty(EPosition_new)
            g.time = EPosition_new;
        end;
        if g.trialstag(1) ~= -1
            g.time = g.time - 1;
        end;
        g.spacing = str2num(get(ESpacing,'string'));
    end;
    
    if ~isempty(custom_command)
        try eval(custom_command); catch, end;
    end;
    
    switch p1
        case 1
        g.time = g.time-g.winlength;     % << subtract one window length
        case 2
        g.time = g.time-g.winlength/5;   % < subtract one second
        case 3
        g.time = g.time+g.winlength/5;   % > add one second
        case 4
        g.time = g.time+g.winlength;     % >> add one window length
    end
    
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end;
    
    % Update edit box
    % ---------------
    g.time = max(0,min(g.time,ceil((g.frames-1)/multiplier)-g.winlength));
    if g.trialstag(1) == -1
        set(EPosition,'string',num2str(g.time)); 
    else 
        set(EPosition,'string',num2str(g.time+1)); 
    end; 
    set(figh, 'userdata', g);

    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    
    % Plot data and update axes
    % -------------------------
    switch lower(g.submean) % subtract the mean ?
        case 'on'
            if ~isempty(g.data2)
                meandata = nan_mean(g.data2(:,lowlim:highlim)');
            else
                meandata = nan_mean(data(:,lowlim:highlim)');
            end
        otherwise, meandata = zeros(1,g.chans);
    end;
    
    if strcmpi(g.plotdata2, 'off')
        cla(ax1)
    end;
    
    oldspacing = g.spacing;
    if g.envelope
        g.spacing = 0;
    end
    
    % plot data
    % ---------
    hold(ax1,'on')
    
    chans_list_bad=[];
    if ~isfield(g, 'eloc_file') || ~isfield(g.eloc_file, 'badchan')
        chans_list_good=1:g.chans;
    else
        chans_list_bad=g.chans-find([g.eloc_file.badchan])+1;
        chans_list_good=setdiff(1:g.chans,chans_list_bad);
    end;
    
    % plot channels whose "badchan" field is set to 1.
    % Bad channels are plotted first so that they appear behind the good
    % channels in the eegplot_w figure window.
    if ~isempty(chans_list_bad)
        tmp_plot_data_x=1:length(lowlim:highlim);
        tmp_plot_data_y=nan(length(chans_list_bad),length(lowlim:highlim));
        for ii = 1:length(chans_list_bad)
            i=chans_list_bad(ii);
            tmp_plot_data_y(ii,tmp_plot_data_x)=data(g.chans-i+1,lowlim:highlim) ...
                - meandata(g.chans-i+1) ...
                + i*g.spacing ...
                + (g.dispchans+1)*(oldspacing-g.spacing)/2 ...
                + g.elecoffset*(oldspacing-g.spacing);
        end
        plot(ax1,tmp_plot_data_y', 'color', [ .85 .85 .85 ], 'clipping','on');
        for i = chans_list_bad
            line_params = ...
                {1,mean(i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing),2),...
                'Marker','<','MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',6,...
                'clipping','off','userdata',g.chans-i+1,'ButtonDownFcn',{@MarkChannel,figh,g.chans-i+1}};
            if verLessThan_matlab_9
                line(line_params{:})
            else
                line(ax1,line_params{:});
            end;
        end
    end;
    
    % plot good channels on top of bad channels (if g.eloc_file(i).badchan = 0... or there is no bad channel information)
    if ~isempty(chans_list_good)
        chans_list_good_N=length(chans_list_good);
        tmp_plot_data_x_N=length(lowlim:highlim);
        plot_at_once=2; % mode: 0, 1 or 2
        if strcmpi(g.plotdata2, 'on')
            tmpcolor = [ 1 0 0 ];
        elseif length(g.color) == 1
            tmpcolor = g.color{1};
        else
            plot_at_once=0; % in this case only mode "0" allowed
        end;
        switch plot_at_once
            case 1
                tmp_plot_data_x=1:tmp_plot_data_x_N;
                tmp_plot_data_y=nan(length(chans_list_good),tmp_plot_data_x_N);
            case 2
                tmp_plot_data_x= repmat([1:tmp_plot_data_x_N NaN],1,chans_list_good_N) ;
                tmp_plot_data_y= nan(1, chans_list_good_N*(tmp_plot_data_x_N+1));
        end;
        for ii = 1:chans_list_good_N
            i=chans_list_good(ii);
            tmp_plot_data_y_i=data(g.chans-i+1,lowlim:highlim) ...
                - meandata(g.chans-i+1)+i*g.spacing ...
                + (g.dispchans+1)*(oldspacing-g.spacing)/2 ...
                + g.elecoffset*(oldspacing-g.spacing);
            switch plot_at_once
                case 0
                    tmpcolor = g.color{mod(g.chans-i,length(g.color))+1};
                    plot(tmp_plot_data_y_i, 'color', tmpcolor, 'clipping','on')
                case 1
                    tmp_plot_data_y(ii,tmp_plot_data_x)=tmp_plot_data_y_i;
                case 2
                    tmp_plot_data_y(1,(ii-1)*(tmp_plot_data_x_N+1)+[1:tmp_plot_data_x_N])=tmp_plot_data_y_i;
            end;
        end;
        switch plot_at_once
            case 1
                plot(ax1,tmp_plot_data_y', 'color', tmpcolor, 'clipping','on');
            case 2
                plot(ax1,tmp_plot_data_x,tmp_plot_data_y, 'color', tmpcolor, 'clipping','on');
        end;
%         if (isfield(g, 'eloc_file') && isstruct(g.eloc_file)) && ~isempty(g.command)
%             for i = chans_list_good
%                 line(ax1,1,mean(i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing),2),...
%                     'Marker','>','MarkerEdgeColor','g','MarkerFaceColor','g','MarkerSize',6,'clipping','off','userdata',g.chans-i+1,'ButtonDownFcn',{@MarkChannel,figh,g.chans-i+1});
%             end;
%         end;
    end;
    
    % draw selected channels
    % ------------------------
    if ~isempty(g.winrej) && size(g.winrej,2) > 2
    	for tpmi = 1:size(g.winrej,1) % scan rows
            if (g.winrej(tpmi,1) >= lowlim && g.winrej(tpmi,1) <= highlim) || ...
               (g.winrej(tpmi,2) >= lowlim && g.winrej(tpmi,2) <= highlim)
                abscmin = max(1,round(g.winrej(tpmi,1)-lowlim));
                abscmax = round(g.winrej(tpmi,2)-lowlim);
                maxXlim = get(gca, 'xlim');
                abscmax = min(abscmax, round(maxXlim(2)-1));
                for i = 1:g.chans
                    if g.winrej(tpmi,g.chans-i+1+5)
                        plot(ax1,abscmin+1:abscmax+1,data(g.chans-i+1,abscmin+lowlim:abscmax+lowlim) ...
                            -meandata(g.chans-i+1)+i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), 'color','r','clipping','on')
                    end;
                end
            end;
    	end;
    end;
    g.spacing = oldspacing;
    set(ax1, 'Xlim', [1 g.winlength*multiplier+1]);

    % ordinates: even if all elec are plotted, some may be hidden
    set(ax1, 'ylim',[g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] );
    
    if g.children ~= 0
        draw_data([],[],g.children,p1,p2);
        figure(figh);
    end;

     % draw second data if necessary
     if ~isempty(g.data2)
         tmpdata = data;
         set(ax1, 'userdata', g.data2);
         g.data2 = [];
         g.plotdata2 = 'on';
         set(figh, 'userdata', g);
         draw_data([],[],figh,0,[],g,ax1);
         g.plotdata2 = 'off';
         g.data2 = get(ax1, 'userdata');
         set(ax1, 'userdata', tmpdata);
         set(figh, 'userdata', g);
     else 
         draw_background([],[],figh,g);
     end;


% Draw background
% ---------------------------------
function draw_background(varargin)

if nargin >= 3
    fig = varargin{3};
else
    fig = gcf;
end;
if nargin >= 4
    g = varargin{4};
else
    g = get(fig,'UserData');  % Data (Note: this could also be global);
end;
if ~isfield(g,'trialstag')
    return;
end;

ax0 = findobj('tag','backeeg','parent',fig); % axes handle
ax1 = findobj('tag','eegaxis','parent',fig); % axes handle

% compare versions once, because it slows down drawing
verLessThan_matlab_9 = ismatlab && verLessThan('matlab','9.0.0');

% Plot data and update axes
if verLessThan_matlab_9
    axes(ax0); % changing axes very slows down drawing
end;
cla(ax0);
hold(ax0,'on');
% plot rejected windows
if g.trialstag ~= -1
    multiplier = g.trialstag;
else
    multiplier = g.srate;
end;

% draw rejection windows
% ----------------------
lowlim = round(g.time*multiplier+1);
highlim = round(min((g.time+g.winlength)*multiplier+1));
%displaymenu = findobj('tag','displaymenu','parent',gcf);
if ~isempty(g.winrej) && g.winstatus
    if g.trialstag ~= -1 % epoched data
        indices = find((g.winrej(:,1)' >= lowlim & g.winrej(:,1)' <= highlim) | ...
            (g.winrej(:,2)' >= lowlim & g.winrej(:,2)' <= highlim));
        if ~isempty(indices)
            tmpwins1 = g.winrej(indices,1)';
            tmpwins2 = g.winrej(indices,2)';
            if size(g.winrej,2) > 2
                tmpcols  = g.winrej(indices,3:5);
            else
                tmpcols  = g.wincolor;
            end;
            try    [cumul, indicescount] = histc(  tmpwins1, (min(tmpwins1)-1):g.trialstag:max(tmpwins2));
            catch, [cumul, indicescount] = myhistc(tmpwins1, (min(tmpwins1)-1):g.trialstag:max(tmpwins2));
            end;
            count = zeros(size(cumul));
            %if ~isempty(find(cumul > 1)), find(cumul > 1), end;
            for tmpi = 1:length(tmpwins1)
                poscumul = indicescount(tmpi);
                heightbeg = count(poscumul)/cumul(poscumul);
                heightend = heightbeg + 1/cumul(poscumul);
                count(poscumul) = count(poscumul)+1;
                winrej = [tmpwins1(tmpi)-lowlim tmpwins2(tmpi)-lowlim ...
                          tmpwins2(tmpi)-lowlim tmpwins1(tmpi)-lowlim];
                winheigh = [heightbeg heightbeg heightend heightend];
                patch_params = {winrej, winheigh, tmpcols(tmpi,:), 'EdgeColor', tmpcols(tmpi,:)};
                if verLessThan_matlab_9
                    patch(patch_params{:});
                else
                    patch(ax0, patch_params{:});
                end;
            end;
        end;
    else
        event2plot1 = find ( g.winrej(:,1) >= lowlim & g.winrej(:,1) <= highlim );
        event2plot2 = find ( g.winrej(:,2) >= lowlim & g.winrej(:,2) <= highlim );
        event2plot3 = find ( g.winrej(:,1) <  lowlim & g.winrej(:,2) >  highlim );
        event2plot  = union_bc(union(event2plot1, event2plot2), event2plot3);
        
        for tpmi = event2plot(:)'
            if size(g.winrej,2) > 2
                tmpcols  = g.winrej(tpmi,3:5);
            else
                tmpcols  = g.wincolor;
            end;
            winrej=[g.winrej(tpmi,1)-lowlim g.winrej(tpmi,2)-lowlim ...
                   g.winrej(tpmi,2)-lowlim g.winrej(tpmi,1)-lowlim];
            patch_params={winrej, [0 0 1 1], tmpcols, 'EdgeColor', tmpcols};
            if verLessThan_matlab_9
                patch(patch_params{:});
            else
                patch(ax0, patch_params{:});
            end;
        end;
    end;
end;

% plot tags
% ---------
%if trialtag(1) ~= -1 & displaystatus % put tags at arbitrary places
% 	for tmptag = trialtag
%		if tmptag >= lowlim & tmptag <= highlim
%			plot([tmptag-lowlim tmptag-lowlim], [0 1], 'b--');
%		end;
%	end;
%end;

% draw events if any
% ------------------
if strcmpi(g.plotevent, 'on')
    % JavierLC ###############################
    MAXEVENTSTRING = g.maxeventstring;
    if MAXEVENTSTRING<0
        MAXEVENTSTRING = 0;
    elseif MAXEVENTSTRING>75
        MAXEVENTSTRING=75;
    end
    % JavierLC ###############################
    AXES_POSITION = [0.05 0.03 0.865 1-(MAXEVENTSTRING-4)/100];
else % JavierLC
    AXES_POSITION = [0.05 0.03 0.865 0.96];
end;

if ~isempty(g.events)
      if ischar(g.events(1).type)
          eventlist={g.events.type};
          evnt_groups=g.eventtypes;
      else
          eventlist=arrayfun(@(x) num2str(g.events(x).type), 1:length(g.events),'UniformOutput',false);
          evnt_groups=arrayfun(@(x) num2str(g.eventtypes(x)), 1:length(g.eventtypes),'UniformOutput',false);
      end;
else
    eventlist={};
end;
if strcmpi(g.plotevent, 'on') || ismember('boundary',eventlist)
    % find event to plot
    % ------------------
    event2plot    = find ( g.eventlatencies >=lowlim & g.eventlatencies <= highlim );
    if ~isempty(g.eventlatencyend)
        event2plot2 = find ( g.eventlatencyend >= lowlim & g.eventlatencyend <= highlim );
        event2plot3 = find ( g.eventlatencies  <  lowlim & g.eventlatencyend >  highlim );
        event2plot  = union_bc(union(event2plot, event2plot2), event2plot3);
    end;
    [event2plot_ut,~,event2plot_uti]=unique_bc(eventlist(event2plot));
    if ~strcmpi(g.plotevent, 'on')
        event2plot=event2plot(find(ismember(eventlist(event2plot),{'boundary'})));
        event2plot_ut=eventlist(event2plot);
        event2plot_uti=ones(1,length(event2plot));
    end;
    for evnt_group_idx_tmp=1:length(event2plot_ut)
        %Just repeat for the first one
        if evnt_group_idx_tmp == 1
            EVENTFONT = ' \fontsize{8} ';
            ylims=ylim(ax0);
        end
        evnt_group=event2plot_ut{evnt_group_idx_tmp};
        evnt_group_idx=find(ismember(evnt_groups,evnt_group));
        evnt_group_color = g.eventtypecolors{evnt_group_idx};
        event2plot_activ = event2plot(find(event2plot_uti==evnt_group_idx_tmp));
        
        % draw latency line
        % -----------------
        tmplat = g.eventlatencies(event2plot_activ)-lowlim-1; % [lat1 lat2]
        plot_x = reshape([ tmplat; tmplat; NaN(1,length(tmplat))], [1 3*length(tmplat)]); % [lat1 lat1 NaN lat2 lat2 NaN]
        plot_y = repmat([ylims NaN],1,length(tmplat));
        plot(ax0, plot_x, plot_y, ...
            'color', evnt_group_color,...
            'linestyle', g.eventtypestyle{evnt_group_idx}, ...
            'linewidth', g.eventtypewidths(evnt_group_idx));
        
        if ~strcmpi(g.plotevent, 'on')
            break;
        end;
        % schtefan: add Event types text above event latency line
        % -------------------------------------------------------
        evntxt = strrep(evnt_group,'_','-');
        if length(evntxt)>MAXEVENTSTRING
            evntxt = [ evntxt(1:MAXEVENTSTRING-1) '...' ]; % truncate
        end;
        for index = 1:length(event2plot_activ)
            tmplat1=tmplat(index);
            try
                text_prop={tmplat1, ylims(2)-0.005, [EVENTFONT evntxt], ...
                    'color', evnt_group_color, ...
                    'horizontalalignment', 'left',...
                    'rotation',90};
                if verLessThan_matlab_9
                    text(text_prop{:});
                else
                    text(ax0, text_prop{:});
                end;
            catch
            end;
            
            % draw duration is not 0
            % ----------------------
            if g.ploteventdur && ~isempty(g.eventlatencyend) ...
                    && g.eventtypewidths(evnt_group_idx) ~= 2.5 % do not plot length of boundary events
                tmplatend = g.eventlatencyend(event2plot_activ(index))-lowlim-1;
                if tmplatend ~= 0
                    tmplim = ylims;
                    patch_params = {[ tmplat1 tmplatend tmplatend tmplat1 ], ...
                        [ tmplim(1) tmplim(1) tmplim(2) tmplim(2) ], ...
                        evnt_group_color, ...  % this argument is color
                        'EdgeColor', 'none' };
                    if verLessThan_matlab_9
                        patch(patch_params{:});
                    else
                        patch(ax0, patch_params{:});
                    end;
                end;
            end;
        end;
    end;
end;

if g.trialstag(1) ~= -1
    
    % plot trial limits
    % -----------------
    tmptag = [lowlim:highlim];
    tmpind = find(mod(tmptag-1, g.trialstag) == 0);
    for index = tmpind
        plot(ax0, [tmptag(index)-lowlim-1 tmptag(index)-lowlim-1], [0 1], 'b--');
    end;
    alltag = tmptag(tmpind);
    
    % compute Xticks
    % --------------
    tagnum = (alltag-1)/g.trialstag+1;
    set(ax0,'XTickLabel', tagnum,'YTickLabel', [],...
        'Xlim',[0 g.winlength*multiplier],...
        'XTick',alltag-lowlim+g.trialstag/2, 'YTick',[], 'tag','backeeg');
    
    tagpos  = [];
    if ~isempty(alltag)
        alltag = [alltag(1)-g.trialstag alltag alltag(end)+g.trialstag]; % add border trial limits
    else
        alltag = [ floor(lowlim/g.trialstag)*g.trialstag ceil(highlim/g.trialstag)*g.trialstag ]+1;
    end;
    
    nbdiv = 20/g.winlength; % approximative number of divisions
    divpossible = [ 100000./[1 2 4 5] 10000./[1 2 4 5] 1000./[1 2 4 5] 100./[1 2 4 5 10 20]]; % possible increments
    [~, indexdiv] = min(abs(nbdiv*divpossible-(g.limits(2)-g.limits(1)))); % closest possible increment
    incrementpoint = divpossible(indexdiv)/1000*g.srate;
    
    % tag zero below is an offset used to be sure that 0 is included
    % in the absicia of the data epochs
    if g.limits(2) < 0, tagzerooffset  = (g.limits(2)-g.limits(1))/1000*g.srate+1;
    else                tagzerooffset  = -g.limits(1)/1000*g.srate;
    end;
    if tagzerooffset < 0, tagzerooffset = 0; end;
    
    for i=1:length(alltag)-1
        if ~isempty(tagpos) && tagpos(end)-alltag(i)<2*incrementpoint/3
            tagpos  = tagpos(1:end-1);
        end;
        if ~isempty(g.freqlimits)
            tagpos  = [ tagpos linspace(alltag(i),alltag(i+1)-1, nbdiv) ];
        else
            if tagzerooffset ~= 0
                tmptagpos = [alltag(i)+tagzerooffset:-incrementpoint:alltag(i)];
            else
                tmptagpos = [];
            end;
            tagpos  = [ tagpos [tmptagpos(end:-1:2) alltag(i)+tagzerooffset:incrementpoint:(alltag(i+1)-1)]];
        end;
    end;
    
    % find corresponding epochs
    % -------------------------
    if ~g.isfreq
        tmplimit = g.limits;
        tpmorder = 1E-3;
    else
        tmplimit = g.freqlimits;
        tpmorder = 1;
    end
    tagtext = eeg_point2lat(tagpos, floor((tagpos)/g.trialstag)+1, g.srate, tmplimit,tpmorder);
    set(ax1,'XTickLabel', tagtext,'XTick', tagpos-lowlim);
else
    DEFAULT_GRID_SPACING = 10^ceil(log10(g.winlength)-1);
    if g.winlength / DEFAULT_GRID_SPACING < 2
        DEFAULT_GRID_SPACING = DEFAULT_GRID_SPACING / 2;
    end;
    set(ax0,'XTickLabel', [],'YTickLabel', [],...
        'Xlim', [0 g.winlength*multiplier],...
        'XTick',[], 'YTick',[], ...
        'Position', AXES_POSITION);
    set(ax1,'Position', AXES_POSITION);
    if g.isfreq
        set(ax1,'XTick', [1:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier+1]);
        set(ax1,'XTickLabel', num2str((g.freqs(1):DEFAULT_GRID_SPACING:g.freqs(end))'));
    else
        XTickStartSec = DEFAULT_GRID_SPACING*ceil(g.time/DEFAULT_GRID_SPACING);
        XTickStart = multiplier*(XTickStartSec-g.time) + 1;
        set(ax1,'XTick', [XTickStart:(multiplier*DEFAULT_GRID_SPACING):(g.winlength*multiplier+1)]);
        set(ax1,'XTickLabel', num2str((XTickStartSec:DEFAULT_GRID_SPACING:g.time+g.winlength)'));
    end;
end;
if verLessThan_matlab_9
    axes(ax1); % changing axes very slows down drawing
end;


% Redraw EEG and change window size
function change_eeg_window_length(~,~,fig,p1)
    g = get(fig,'UserData');
    switch p1
        case 0
            g.winlength = 5 ;
        case 1
            if g.trialstag==-1
                g.winlength = g.winlength * 0.8 ;
            else                
                g.winlength = max(1, g.winlength - 1) ;
            end;
        case 2
            if g.trialstag==-1
                g.winlength = g.winlength * 1.25 ;
            else                
                g.winlength = g.winlength + 1 ;
            end;
    end;
	%set(fig, 'UserData', g);
	draw_data([],[],fig,0,[],g);


function change_scale(varargin)

    if nargin >= 3
        fig = varargin{3};
    else
        fig = gcf;
    end;
%     if strcmp(get(fig,'tag'),'dialog')
%         fig = get(fig,'UserData');
%     end
    
    if nargin >= 4
        p1 = varargin{4};
        if ~isnumeric(p1)
            p1 = 0;
        end;
    else
        p1 = 0;
    end;
        
    if nargin >= 5
        ax1 = varargin{5};
    else
        ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    end;
    
    g = get(fig,'UserData');
    if ~isfield(g,'trialstag')
        return;
    end;
    data = get(ax1, 'userdata');
    ESpacing = findobj('tag','ESpacing','parent',fig);   % ui handle
    EPosition = findobj('tag','EPosition','parent',fig); % ui handle
    if g.trialstag(1) == -1
        g.time = str2num(get(EPosition,'string'));  
    else 
        g.time = str2num(get(EPosition,'string'))-1;   
    end;        
    g.spacing = str2num(get(ESpacing,'string'));
    if isempty(g.spacing)
        g.spacing=0;
    end;
    switch p1
        case 1
            g.spacing = g.spacing * 1.25;
        case 2
            g.spacing = max(0.005, g.spacing * 0.8);
    end
    if ismember(p1, [1 2])
        spacing_deka=10^(floor(log10(g.spacing))-1);
        g.spacing = spacing_deka*round(g.spacing/spacing_deka);
    end;
    if round(g.spacing*100) == 0
        if g.spacing == 0
            g=optim_scale(data,g);
        else
            maxindex = min(10000, g.frames);
            g.spacing = 0.01*max(max(data(:,1:maxindex),[],2),[],1)-min(min(data(:,1:maxindex),[],2),[],1);  % Set g.spacingto max/min data
        end;
    end;

    % update edit box
    % ---------------
    set(ESpacing,'string',num2str(g.spacing,4))  
    %set(fig, 'userdata', g);
    draw_data([],[],fig,0,[],g);
    set(ax1,...
        'YTick', [0:g.spacing:g.chans*g.spacing],...
        'Ylim',  [g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] ); % 'YLim',[0 (g.chans+1)*g.spacing]
    
    % update scaling eye (I) if it exists
    % -----------------------------------
    eyeaxes = findobj('tag','eyeaxes','parent',fig);
    if ~isempty(eyeaxes)
      eyetext = findobj('type','text','parent',eyeaxes,'tag','thescalenum');
      set(eyetext,'string',num2str(g.spacing,4))
    end

% push mouse button
% ---------------------------------
function mouse_down(varargin)
fig = varargin{3};
if strcmp(get(fig, 'SelectionType'),'alt')
    eegplot_w('topoplot', fig);
    return;
end;
%show_mocap_timer = timerfind('tag','mocapDisplayTimer'); if ~isempty(show_mocap_timer),  end; % nima
SelectionType=get(fig, 'SelectionType');
if ismember(SelectionType, {'normal', 'extend'})
    ax1 = findobj('tag','backeeg','parent',fig);
    tmppos = get(ax1, 'currentpoint');
    g = get(fig,'UserData'); % get data of backgroung image {g.trialstag g.winrej incallback}
    if g.incallback ~= 1 % interception of nestest calls
        if g.trialstag ~= -1
            lowlim = round(g.time*g.trialstag+1);
            highlim = round(g.winlength*g.trialstag);
        else
            lowlim  = round(g.time*g.srate+1);
            highlim = round(g.winlength*g.srate);
        end;
        if (tmppos(1) >= 0) && (tmppos(1) <= highlim)
            if isempty(g.winrej)
                Allwin=0;
            else
                Allwin = (g.winrej(:,1) < lowlim+tmppos(1)) & (g.winrej(:,2) > lowlim+tmppos(1));
            end;
            if strcmp(SelectionType,'extend') || (any(Allwin) && g.setelectrode)
                ax2 = findobj('tag','eegaxis','parent',fig);
                tmppos = get(ax2, 'currentpoint');
                tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
                tmpelec = min(max(tmpelec, 1), g.chans);
            end;
            if strcmp(SelectionType,'extend')
                if ~isempty(tmpelec)
                    MarkChannel([],[],fig,tmpelec);
                end;
            else
                if any(Allwin) % remove the mark or select electrode if necessary
                    lowlim = find(Allwin==1);
                    if g.setelectrode  % select electrode
                        g.winrej(lowlim,tmpelec+5) = ~g.winrej(lowlim,tmpelec+5); % set the electrode
                    else  % remove mark
                        g.winrej(lowlim,:) = [];
                    end;
                else
                    if g.trialstag ~= -1 % find nearest trials boundaries if epoched data
                        alltrialtag = [0:g.trialstag:g.frames];
                        I1 = find(alltrialtag < (tmppos(1)+lowlim) );
                        if ~isempty(I1) && I1(end) ~= length(alltrialtag)
                            g.winrej = [g.winrej' [alltrialtag(I1(end)) alltrialtag(I1(end)+1) g.wincolor zeros(1,g.chans)]']';
                        end;
                    else
                        g.incallback = 1;  % set this variable for callback for continuous data
                        if size(g.winrej,2) < 5
                            g.winrej(:,3:5) = repmat(g.wincolor, [size(g.winrej,1) 1]);
                        end;
                        if size(g.winrej,2) < 5+g.chans
                            g.winrej(:,6:(5+g.chans)) = zeros(size(g.winrej,1),g.chans);
                        end;
                        tmppos_x=mouse_near_boundary_correction(tmppos(1)+lowlim,g);
                        g.winrej = [g.winrej' [tmppos_x tmppos_x g.wincolor zeros(1,g.chans)]']';
                    end;
                end;
                set(fig,'UserData', g);
                draw_background([],[],fig,g); % redraw background
            end;
        end;
    end;
end;

% release mouse button
% ---------------------------------
function mouse_up(varargin)
fig = varargin{3};
g = get(fig,'UserData');
g.incallback = 0;
%set(fig,'UserData', g);  % early save in case of bug in the following
if strcmp(g.mocap,'on'), g.winrej = g.winrej(end,:);end; % nima
if ~isempty(g.winrej)'
    if g.winrej(end,1) == g.winrej(end,2) % remove unitary windows
        g.winrej = g.winrej(1:end-1,:);
    else
        if g.winrej(end,1) > g.winrej(end,2) % reverse values if necessary
            g.winrej(end, 1:2) = [g.winrej(end,2) g.winrej(end,1)];
        end;
        g.winrej(end,1) = max(1, g.winrej(end,1));
        g.winrej(end,2) = min(g.frames, g.winrej(end,2));
        if g.trialstag == -1 % find nearest trials boundaries if necessary
            I1 = find((g.winrej(end,1) >= g.winrej(1:end-1,1)) & (g.winrej(end,1) <= g.winrej(1:end-1,2)) );
            if ~isempty(I1)
                g.winrej(I1,2) = max(g.winrej(I1,2), g.winrej(end,2)); % extend epoch
                g.winrej = g.winrej(1:end-1,:); % remove if empty match
            else
                I2 = find((g.winrej(end,2) >= g.winrej(1:end-1,1)) & (g.winrej(end,2) <= g.winrej(1:end-1,2)) );
                if ~isempty(I2)
                    g.winrej(I2,1) = min(g.winrej(I2,1), g.winrej(end,1)); % extend epoch
                    g.winrej = g.winrej(1:end-1,:); % remove if empty match
                else
                    I2 = find((g.winrej(end,1) <= g.winrej(1:end-1,1)) & (g.winrej(end,2) >= g.winrej(1:end-1,1)) );
                    if ~isempty(I2)
                        g.winrej(I2,:) = []; % remove if empty match
                    end;
                end;
            end;
        end;
    end;
end;
set(fig,'UserData', g);
draw_background([],[],fig,g);
if strcmp(g.mocap,'on')
    show_mocap_for_eegplot(g.winrej); 
    g.winrej = g.winrej(end,:); 
end; % nima


% Function to show the value and electrode at mouse position
function mouse_motion(varargin)
fig = varargin{3};
ax0 = varargin{4};
tmppos = get(ax0, 'currentpoint');
g = get(fig,'UserData');
    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
    else
        lowlim = round(g.time*g.srate+1);
        highlim = round(g.winlength*g.srate);
    end;
    
    if g.incallback && g.trialstag == -1
        tmppos_x=mouse_near_boundary_correction(tmppos(1)+lowlim,g);
        g.winrej = [g.winrej(1:end-1,:)' [g.winrej(end,1) tmppos_x g.winrej(end,3:end)]']';
        set(fig,'UserData', g);
        if tmppos_x < lowlim - highlim * 0.03
            draw_data([],[],fig,2,[],g);
        elseif tmppos_x > lowlim + highlim * 1.03
            draw_data([],[],fig,3,[],g);
        else
            draw_background([],[],fig,g);
        end;
    else
      hh = varargin{6}; % h = findobj('tag','Etime','parent',fig);
      if ~isnumeric(hh) && isobject(hh) && isvalid(hh)
        ax1 = varargin{5};% ax1 = findobj('tag','eegaxis','parent',fig);
        hv = varargin{7}; % hh = findobj('tag','Evalue','parent',fig);
        he = varargin{8}; % hh = findobj('tag','Eelec','parent',fig);  % put electrode in the box
        if g.trialstag ~= -1
            point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
        else
            point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
        end;
        if point_is_valid
            if g.trialstag ~= -1
                tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)) + g.limits(1);
                if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
            else
                tmpval = (tmppos(1)+lowlim-1)/g.srate;
                if g.isfreq, tmpval = tmpval+g.freqs(1); end
            end;
            set(hh, 'string', num2str(tmpval)); % put g.time in the box
        else
            set(hh, 'string', ' ');
        end;
        if ~g.envelope && point_is_valid
            eegplotdata = get(ax1, 'userdata');
            if isempty(eegplotdata); return; end;
            tmppos = get(ax1, 'currentpoint');
            tmpelec = round(tmppos(1,2) / g.spacing);
            tmpelec = min(max(double(tmpelec), 1),g.chans);
            labls = get(ax1, 'YtickLabel');
            set(hv, 'string', num2str(eegplotdata(g.chans+1-tmpelec, min(g.frames,max(1,double(round(tmppos(1)+lowlim)))))));  % put value in the box
            set(he, 'string', labls(tmpelec+1,:));
        else
            set(hv, 'string', ' ');
            set(he, 'string', ' ');
        end
      end;
    end;
 

% Attract position to boundaries
function [tmppos_x]=mouse_near_boundary_correction(tmppos_x,g)
boundaries_lat=[0 g.frames] + 0.5;
if isfield(g,'eventtypes')
    if iscellstr(g.eventtypes)
        if ismember({'boundary'},g.eventtypes)
            boundaries_lat=unique([boundaries_lat ...
                g.eventlatencies(find(ismember({g.events.type},{'boundary'}))) ]);
        end;
    end;
end;
[~,boundary_closest_id]=min(abs(boundaries_lat-tmppos_x));
boundary_closest_lat=boundaries_lat(boundary_closest_id);
if abs(boundary_closest_lat - tmppos_x) < (g.srate*g.winlength*0.02)
    tmppos_x=round(boundary_closest_lat);
elseif tmppos_x > boundaries_lat(end)
    tmppos_x = boundaries_lat(end);
end;


% function not supported under Mac
% --------------------------------
function [reshist, allbin] = myhistc(vals, intervals)
reshist = zeros(1, length(intervals));
allbin = zeros(1, length(vals));
for index=1:length(vals)
    minvals = vals(index)-intervals;
    bintmp  = find(minvals >= 0);
    [~, indextmp] = min(minvals(bintmp));
    bintmp = bintmp(indextmp);
    
    allbin(index) = bintmp;
    reshist(bintmp) = reshist(bintmp)+1;
end;


function g=optim_scale(data,g)
    maxindex = min(10000, g.frames);
	stds = std(data(:,1:maxindex),[],2);
    g.datastd = stds;
	stds = sort(stds);
	if length(stds) > 2
		stds = mean(stds(2:end-1));
	else
		stds = mean(stds);
	end;
    g.spacing = stds*3;
    if g.spacing > 10
      g.spacing = round(g.spacing);
    end
    if g.spacing  == 0 || isnan(g.spacing)
        g.spacing = 1; % default
    elseif g.spacing > 1.9 && g.spacing < 10000
        optim_scale=[2 3 5 7 10 15 20 30 50 75 100 150 200 250 300 500 750 1000 1500 2000 2500 3000 10000];
        i=find(optim_scale > g.spacing);
        g.spacing = optim_scale(i(1));
    end;


% Mouse scroll wheel
function mouse_scroll_wheel(~,eventdata,fig,varargin)
modifiers = get(fig,'currentModifier');
wheel_up=eventdata.VerticalScrollCount < 0;
if wheel_up
    if ismember('shift',modifiers)
        draw_data([],[],fig,1);
    elseif ismember('control',modifiers)
        change_eeg_window_length([],[],fig,2);
    elseif ismember('alt',modifiers)
        change_scale([],[],fig,1);
    else
        draw_data([],[],fig,2);
    end;
else
    if ismember('shift',modifiers)
        draw_data([],[],fig,4);
    elseif ismember('control',modifiers)
        change_eeg_window_length([],[],fig,1);
    elseif ismember('alt',modifiers)
        change_scale([],[],fig,2);
    else
        draw_data([],[],fig,3);
    end;
end;
if nargin > 3
    mouse_motion([],[],fig,varargin{:});
end;


function normalize_chan(~,~,fig)
g = get(fig,'userdata');
if g.normed
    disp('Denormalizing...');
else
    disp('Normalizing...'); 
end;
hmenu = findobj(fig, 'Tag', 'Normalize_menu');
hbutton = findobj(fig, 'Tag', 'Norm');
ax1 = findobj('tag','eegaxis','parent',fig);
data = get(ax1,'UserData');
if isempty(g.datastd)
    data(:,1:min(1000,g.frames));
    g.datastd = std(data(:,1:min(1000,g.frames)),[],2); 
end;
if g.normed
    for i = 1:size(data,1)
        data(i,:,:) = data(i,:,:)*g.datastd(i);
        if ~isempty(g.data2)
            g.data2(i,:,:) = g.data2(i,:,:)*g.datastd(i);
        end;
    end;
    set(hbutton,'string', 'Norm');
    set(findobj('tag','ESpacing','parent',fig),'string',num2str(g.oldspacing));
else
    for i = 1:size(data,1)
        data(i,:,:) = data(i,:,:)/g.datastd(i);
        if ~isempty(g.data2)
            g.data2(i,:,:) = g.data2(i,:,:)/g.datastd(i);
        end;
    end;
    set(hbutton,'string', 'Denorm');
    g.oldspacing = g.spacing;
    %set(findobj('tag','ESpacing','parent',fig),'string','5');
end;
g.normed = 1 - g.normed;
%change_scale([],[],fig,0,ax1);
set(hmenu, 'Label', fastif(g.normed,'Denormalize channels','Normalize channels'));
set(fig,'userdata',g);
set(ax1,'UserData',data);
draw_data([],[],fig,0,[],g,ax1);
disp('Done.');


function MarkChannel(~,~,fig,channel_index)
g=get(fig,'UserData');
%channel_index=get(channel_obj,'userdata')
if isempty(g.command)
    clear global in_callback; return;
end;
if isfield(g, 'eloc_file')
    if ~isfield(g.eloc_file, 'badchan')
        for ii=1:length(g.eloc_file)
            g.eloc_file(ii).badchan = 0;
        end;
    end;
    g.eloc_file(channel_index).badchan = 1-g.eloc_file(channel_index).badchan;
    %set(fig,'UserData',g);
    draw_data([],[],fig,0,[],g);
end;


function eegplot_readkey(~,evnt,varargin)
if nargin >= 3
    fig = varargin{1};
else
    fig = gcf;
end;
g = get(fig,'UserData');
modifiers = get(fig,'currentModifier');
switch evnt.Key
    case 'pageup'
        draw_data([],[],fig,1,[],g);
    case 'leftarrow'
        draw_data([],[],fig,2,[],g);
    case 'rightarrow'
        draw_data([],[],fig,3,[],g);
    case 'pagedown'
        draw_data([],[],fig,4,[],g);
    case {'home' 'end'}
        EPosition = findobj('tag','EPosition','parent',fig);
        id=find(ismember({'home' 'end'},evnt.Key));
        if g.trialstag == -1
            limi=[g.limits(1)/1000 ceil(g.limits(2)/1000-g.winlength)];
        else
            limi=[1 1 + g.frames/g.trialstag - g.winlength];
        end;
        set(EPosition,'string',num2str(limi(id)));
        draw_data([],[],fig,0,[],g);
    case 'uparrow'
        if ismember('control',modifiers)
            change_eeg_window_length([],[],fig,2);
        elseif ismember('alt',modifiers)
            change_scale([],[],fig,1);
        end;
    case 'downarrow'
        if ismember('control',modifiers)
            change_eeg_window_length([],[],fig,1);
        elseif ismember('alt',modifiers)
            change_scale([],[],fig,2);
        end;
    case {'space'}
        eegplot_w('window');
    case {'tab'}
        eegplot_w('winelec');
    case {'v'}
        draw_data([],[],fig,0,[],[],[],...
            'if strcmp(g.plotevent,''on''); g.plotevent = ''off''; else g.plotevent = ''on''; end;');
end
if nargin > 3
    mouse_motion([],[],varargin{:})
end;

