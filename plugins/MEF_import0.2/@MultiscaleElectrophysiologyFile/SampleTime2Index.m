function [sample_index, sample_yn] = SampleTime2Index(this, varargin)
% SAMPLETIME2INDEX Convert sample time to sample index
% 
% Syntax:
%   [sample_index, sample_yn] = SampleTime2Index(this, sample_time)
%   [sample_index, sample_yn] = SampleTime2Index(__, st_unit)
% 
% Input(s):
%   this            - [obj] MultiscaleElectrophysiologyFile object
%   sample_time     - [num array] array of sample time (default unit uUTC)
%   st_unit         - [str] (optional) sample time unit: 'uUTC' (default)
%                     or 'u', 'mSec', 'Second' or 's', 'Minute' or 'm', 'Hour' or
%                     'h' and 'Day' or 'd'.
% 
% Output(s):
%   sample_index    - [num array] sample indices corresponding to sample
%                     time
%   sample_yn       - [logical array] true: this sample index corresponding
%                     to physically collected data
% 
% Note:
% 
% See also .

% Copyright 2019 Richard J. Cui. Created: Sun 05/05/2019 10:29:21.071 PM
% $Revision: 0.3 $  $Date: Thu 05/09/2019 11:15:44.427 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% parse inputs
% ------------
q = parseInputs(this, varargin{:});
sample_time = q.sample_time;
st_unit = q.st_unit;
switch lower(st_unit) % convert to uUTC
    case 'msec'
        sample_time = round(sample_time*1e3);
    case 'second'
        sample_time = round(sample_time*1e6);
    case 'minute'
        sample_time = round(sample_time*60*1e6);
    case 'hour'
        sample_time = round(sample_time*60*60*1e6);
    case 'day'
        sample_time = round(sample_time*24*60*60*1e6);
end % switch

% set paras
% ----------
fs = this.Header.sampling_frequency;
MPS = 1e6; % microsecond per second
sample_index = zeros(size(sample_time));
sample_yn = false(size(sample_time));
[sorted_st, orig_index] = sort(sample_time);
sorted_sample_index = sample_index;
sorted_sample_yn = sample_yn;

if isempty(this.Continuity)
    this.analyzeContinuity;
end % if
cont = this.Continuity;

% within continuous segment
% -------------------------
cont_start_end = cont{:, {'SampleTimeStart', 'SampleTimeEnd'}};
num_seg = size(cont_start_end, 1); % number of segments
for k = 1:num_seg
    start_k = cont_start_end(k, 1);
    end_k = cont_start_end(k, 2);
    ind_k = sorted_st >= start_k & sorted_st <= end_k;
    
    if ~isempty(ind_k)
        si_k = cont.SampleIndexStart(k);
        time_diff = sorted_st(ind_k) - start_k;
        ind_diff = floor(time_diff*fs/MPS);
        sorted_ti_k = si_k+ind_diff;
        sorted_sample_index(ind_k) = sorted_ti_k;
        sorted_sample_yn(ind_k) = true;
    end % if
end % for

% within discontinous segment
% ----------------------------
a = cont_start_end.';
b = cat(1, -inf, a(:), inf);
discont_start_end = reshape(b, 2, numel(b)/2).';
num_seg = size(discont_start_end, 1); % number of segments
for k = 1:num_seg
    start_k = discont_start_end(k, 1);
    end_k = discont_start_end(k, 2);
    ind_k = sorted_st > start_k & sorted_st < end_k;
    
    if sum(ind_k) ~= 0
        if start_k == -inf
            si_k = cont.SampleIndexStart(k);
            time_diff = sorted_st(ind_k)-end_k;
            ind_diff = floor(time_diff*fs/MPS);
        else
            si_k = cont.SampleIndexEnd(k-1);
            time_diff = sorted_st(ind_k) - start_k;
            ind_diff = ceil(time_diff*fs/MPS);
        end % if
        sorted_ti_k = si_k+ind_diff;
        sorted_sample_index(ind_k) = sorted_ti_k;
        sorted_sample_yn(ind_k) = false;
    end % if
end % for

% output
% ------
sample_index(orig_index) = sorted_sample_index;
sample_yn(orig_index) = sorted_sample_yn;

end

% =========================================================================
% subroutines
% =========================================================================
function q = parseInputs(varargin)

% defaults
defaultSTUnit = 'uutc';
expectedSTUnit = {'uutc', 'msec', 'second', 'minute', 'hour', 'day'};

% parse rules
p = inputParser;
p.addRequired('this', @isobject);
p.addRequired('sample_time', @isnumeric);
p.addOptional('st_unit', defaultSTUnit,...
    @(x) any(validatestring(x, expectedSTUnit)));

% parse and return the results
p.parse(varargin{:});
q.this = p.Results.this;
q.sample_time = p.Results.sample_time;
q.st_unit = p.Results.st_unit;

end % function

% [EOF]
