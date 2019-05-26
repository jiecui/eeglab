function [sample_time, sample_yn] = SampleIndex2Time(this, varargin)
% SampleIndex2Time Convert sample index to sample time
% 
% Syntax
%   [sample_time, sample_yn] = SampleIndex2Time(this, sample_index)
%   [sample_time, sample_yn] = SampleIndex2Time(__, st_unit)
% 
% Input(s):
%   this            - [obj] MultiscaleElectrophysiologyFile object
%   sample_index    - [num array] array of sample index (must be integers)
%   st_unit         - [str] (optional) sample time unit: 'uUTC' (default)
%                     or 'u', 'mSec', 'Second' or 's', 'Minute' or 'm', 'Hour' or
%                     'h' and 'Day' or 'd'.
% 
% Output(s):
%   sample_time     - [num array] sample time corresponding to sample
%                     indices (default unit: uUTC)
%   sample_yn       - [logical array] true: this sample time corresponding
%                     to physically collected data
% 
% Note:
%   An error less than one sample time may occure.
% 
% See also SampleTime2Index.

% Copyright 2019 Richard J. Cui. Created: Mon 05/06/2019  9:29:08.940 PM
% $Revision: 0.3 $  $Date: Fri 05/24/2019  4:07:08.928 PM $
%
% 1026 Rocky Creek Dr NE
% Rochester, MN 55906, USA
%
% Email: richard.cui@utoronto.ca

% parse inputs
% ------------
q = parseInputs(this, varargin{:});
sample_index = q.sample_index;
st_unit = q.st_unit;

% set paras
% ----------
fs = this.Header.sampling_frequency;
MPS = 1e6; % microsecond per second
sample_time = zeros(size(sample_index));
sample_yn = false(size(sample_index));
[sorted_si, orig_index] = sort(sample_index);
sorted_sample_time = sample_index;
sorted_sample_yn = sample_yn;

if isempty(this.Continuity)
    this.analyzeContinuity;
end % if
cont = this.Continuity;

% within continuous segment
% -------------------------
cont_start_end = cont{:, {'SampleIndexStart', 'SampleIndexEnd'}};
num_seg = size(cont_start_end, 1); % number of segments
for k = 1:num_seg
    start_k = cont_start_end(k, 1);
    end_k = cont_start_end(k, 2);
    ind_k = sorted_si >= start_k & sorted_si <= end_k;
    
    if ~isempty(ind_k)
        st_k = cont.SampleTimeStart(k);
        index_diff = sorted_si(ind_k)-start_k;
        time_diff = index_diff*MPS/fs;
        sorted_st_k = st_k+time_diff;
        sorted_sample_time(ind_k) = round(sorted_st_k); % uUTC integer
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
    ind_k = sorted_si > start_k & sorted_si < end_k;
    
    if sum(ind_k) ~= 0
        if start_k == -inf
            st_k = cont.SampleTimeStart(k);
            index_diff = sorted_si(ind_k)-end_k;
            time_diff = index_diff*MPS/fs;
            sorted_st_k = st_k+time_diff;
        else
            st_k = cont.SampleTimeEnd(k-1);
            index_diff = sorted_si(ind_k) - start_k;
            time_diff = (index_diff-1)*MPS/fs;
            sorted_st_k = st_k+time_diff+1;
        end % if
        sorted_sample_time(ind_k) = round(sorted_st_k); % uUTC integer
        sorted_sample_yn(ind_k) = false;
    end % if
end % for

% output
% ------
switch lower(st_unit)
    case 'msec'
        sorted_sample_time = sorted_sample_time/1e3;
    case 'second'
        sorted_sample_time = sorted_sample_time/1e6;
    case 'minute'
        sorted_sample_time = sorted_sample_time/(60*1e6);
    case 'hour'
        sorted_sample_time = sorted_sample_time/(60*60*1e6);
    case 'day'
        sorted_sample_time = sorted_sample_time/(24*60*1e6);
end % switch
sample_time(orig_index) = sorted_sample_time;
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
p.addRequired('sample_index', @isnumeric);
p.addOptional('st_unit', defaultSTUnit,...
    @(x) any(validatestring(x, expectedSTUnit)));

% parse and return the results
p.parse(varargin{:});
q.this = p.Results.this;
q.sample_index = p.Results.sample_index;
q.st_unit = p.Results.st_unit;

end % function

% [EOF]