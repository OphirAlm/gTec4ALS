function varargout = bandpass(x,varargin)
%BANDPASS Filter signals with a bandpass filter
%   Y = BANDPASS(X,Wpass) filters input X with a bandpass filter that has a
%   passband frequency range defined by the two element vector Wpass =
%   [WpassLower, WpassUpper]. Elements of Wpass are given in normalized
%   units of pi*radians/sample and its values must be within the (0,1)
%   interval. X can be a vector or a matrix containing double or single
%   precision data. When X is a matrix, each column is filtered
%   independently.
%
%   BANDPASS performs zero phase filtering on input X using a bandpass
%   filter with a stopband attenuation of 60 dB. The bandpass filter
%   attenuates frequencies below and above the specified lower and upper
%   passband frequencies. BANDPASS compensates for the delay introduced by
%   the filter, and returns output Y having the same dimensions as X.
%
%   Y = BANDPASS(X,Fpass,Fs) specifies Fs as a positive numeric scalar
%   corresponding to the sample rate of X in units of hertz. Fpass =
%   [FpassLower, FpassUpper], is a two element vector that defines the
%   passband frequency range of the filter in units of hertz.
%
%   YT = BANDPASS(XT,Fpass) filters the data in timetable XT with a
%   bandpass filter that has a passband frequency range defined by a two
%   element vector, Fpass = [FpassLower, FpassUpper], in units of hertz,
%   and returns a timetable YT of the same size as XT. XT must contain
%   numeric double or single precision data. The row times must be
%   durations in seconds with increasing, finite, and uniformly spaced
%   values. All variables in the timetable and the columns inside each
%   variable are filtered independently.
%
%   BANDPASS(...,'Steepness',S) specifies the transition band steepness
%   factor as a scalar, S in the [0.5, 1) interval, or as a two element
%   vector S = [SLower, SUpper] with SLower, and SUpper each in the [0.5,
%   1) interval. Specify S as a vector to control the steepness of the
%   upper and lower transition bands of the filter independently. When S is
%   a scalar, the same factor is used to control the steepness of both
%   upper and lower transition bands making them of equal width. As S
%   increases, the filter response increasingly approaches the ideal
%   bandpass response, but the resulting filter length and the
%   computational cost of the filtering operation also increases. When not
%   specified, Steepness defaults to [0.85 0.85]. See the documentation to
%   learn more about the filter design used in this function.
%
%   BANDPASS(...,'StopbandAttenuation',A) specifies stopband attenuation,
%   A, of the filter as a positive scalar in dB. When not specified,
%   StopbandAttenuation defaults to 60 dB.
%
%   BANDPASS(...,'ImpulseResponse',R) specifies the type of impulse
%   response of the filter, R, as 'auto', 'fir', or 'iir'. If R is set to
%   'fir', LOWPASSFILT designs a minimum-order FIR filter. In this case,
%   the input signal has to be twice as long as the filter required to meet
%   the specifications. If R is set to 'iir', BANDPASS designs a IIR filter
%   and uses the FILTFILT function to perform zero-phase filtering. If R is
%   set to 'auto', BANDPASS designs a minimum-order FIR filter if the input
%   signal is long enough, and a IIR filter otherwise. When not specified
%   ImpulseResponse defaults to 'auto'.
%
%   [Y,D] = BANDPASS(...) returns the digital filter, D, used to filter the
%   signal. Call fvtool(D) to visualize the filter response. Call
%   filter(D,X) to filter data.
%
%   BANDPASS(...) with no output arguments plots the original and filtered
%   signals in time and frequency domains.
%
%   % EXAMPLE 1:
%      % Create a signal sampled at 1 kHz. The signal contains three tones,
%      % at 50, 150, and 250 Hz, and additive noise. Bandpass filter the
%      % signal to remove the 50 and 250 Hz tones.
%      Fs = 1e3;
%      t = (0:1000)'/Fs;
%      x = sin(2*pi*[50 150 250].*t);
%      x = sum(x,2) + 0.001*randn(size(t));
%      bandpass(x,[100,200],Fs)
%
%   % EXAMPLE 2:
%      % Filter white noise with a bandpass filter with passband
%      % frequencies of [0.3*pi, 0.7*pi] rad/sample.
%      x = randn(1000,1);
%      bandpass(x,[0.3, 0.7])
%
%   % EXAMPLE 3:
%      % Filter white noise sampled at 1 kHz with a bandpass filter with
%      % passband frequencies of [150, 350] Hz. Use different steepness values.
%      % Plot the spectra of the filtered signals as well as the responses
%      % of the resulting filters. 
%      Fs = 1000;
%      x = randn(2000,1);
%      [y1, D1] = bandpass(x,[150,350],Fs,'Steepness',0.5);
%      [y2, D2] = bandpass(x,[150,350],Fs,'Steepness',0.8);
%      [y3, D3] = bandpass(x,[150,350],Fs,'Steepness',0.95);
%      pspectrum([y1 y2 y3], Fs)
%      legend('Steepness = 0.5','Steepness = 0.8','Steepness = 0.95')
%      fvt = fvtool(D1,D2,D3);
%      legend(fvt,'Steepness = 0.5','Steepness = 0.8','Steepness = 0.95')
%
%   See also LOWPASS, HIGHPASS, BANDSTOP, FILTER, DESIGNFILT, DIGITALFILTER

%   Copyright 2017-2018 The MathWorks, Inc.

narginchk(1,9);
nargoutchk(0,2);

opts = signal.internal.filteringfcns.parseAndValidateInputs(x,'bandpass',varargin);

% Design filter - depending on passband and stopband values, the filter
% design might be a lowpass or a high pass design.
if opts.WpassNormalized(2) >= 1
    % If Wpass(1) >= 1 the case will be handled by the
    % highpass function.
    
    if opts.WpassNormalized(1) < 1
        % If allstop filter, let the highpass filter warn
        warning(message('signal:internal:filteringfcns:ForcedHighpassDesign'));    
    end
    
    [y,D] = performHighpassFiltering(x,opts);    
    opts.FilterObject = D;
    
else
    % Design bandpass filter and filter the data
    opts = designFilter(opts);
    if opts.IsSinglePrecision
        opts.FilterObject = single(opts.FilterObject);
    end
    y = signal.internal.filteringfcns.filterData(x,opts);
end

if nargout > 0
    varargout{1} = y;
    if nargout > 1
        varargout{2} = opts.FilterObject;
    end
else
    % Plot input and output data
    signal.internal.filteringfcns.conveniencePlot(x,y,opts);
end

%--------------------------------------------------------------------------
function [y,D] = performHighpassFiltering(x,opts)

if opts.IsTimetable
    [y,D] = highpass(x,opts.Wpass(1),'Steepness',opts.Steepness(1),...
        'StopbandAttenuation',opts.StopbandAttenuation);
else
    if opts.IsNormalizedFreq
        [y,D] = highpass(x,opts.Wpass(1),'Steepness',opts.Steepness(1),...
            'StopbandAttenuation',opts.StopbandAttenuation);
    else
        [y,D] = highpass(x,opts.Wpass(1),opts.Fs,'Steepness',opts.Steepness(1),...
            'StopbandAttenuation',opts.StopbandAttenuation);
    end
end

%--------------------------------------------------------------------------
function opts = designFilter(opts)

opts.IsFIR = true;
Fs = opts.Fs;
Wpass = opts.Wpass;
WpassNormalized = opts.WpassNormalized;
Apass = opts.PassbandRipple;
Astop = opts.StopbandAttenuation;

% All pass filter if signal length is <=6
if opts.SignalLength <= 6
    d = dfilt.dffir(1);
    opts.FilterObject = digitalFilter(d);
    warning(message('signal:internal:filteringfcns:AllPassBecauseSignalIsTooShort',num2str(6)));
    return;
end

% Compute Tw and Wstop
if numel(opts.TwPercentage) == 1
    % Equal tw on both bands, chose min Tw
    TwPercentage = opts.TwPercentage;        
    Tw1 = TwPercentage * WpassNormalized(1);
    Tw2 = TwPercentage * (1 - WpassNormalized(2));
    Tw = min(Tw1,Tw2);
    Tw1 = Tw;
    Tw2 = Tw;        
else
    % Different tw on each band is allowed
    TwPercentage1 = opts.TwPercentage(1);
    TwPercentage2 = opts.TwPercentage(2);    
    Tw1 = TwPercentage1 * WpassNormalized(1);
    Tw2 = TwPercentage2 * (1 - WpassNormalized(2));    
end

WstopNormalized = [0 0];
WstopNormalized(1) = WpassNormalized(1) - Tw1;
WstopNormalized(2) = WpassNormalized(2) + Tw2;
Wstop = WstopNormalized * (Fs/2);

opts.Wstop = Wstop;
opts.WstopNormalized = WstopNormalized;

% Try to design an FIR filter, if order too large for input signal length,
% then try an IIR filter.

% Calculate the required min FIR order from the parameters
F = [Wstop(1) Wpass(1) Wpass(2) Wstop(2)];
A = [opts.StopbandAttenuationLinear opts.PassbandRippleLinear opts.StopbandAttenuationLinear];
NreqFir = kaiserord(F, [0 1 0], A, Fs);

impRespType = signal.internal.filteringfcns.selectImpulseResponse(NreqFir, opts);    

if strcmp(impRespType,'iir')
    % IIR design
    
    opts.IsFIR = false;
    
    % Get the min order of an elliptical IIR filter that will meet the
    % specs and see if signal length is > 3*order otherwise, truncate order
    N = getIIRMinOrder(WpassNormalized,WstopNormalized,Apass,Astop);
    
    if opts.SignalLength <= 3*N
        N = max(2,floor(opts.SignalLength/3));
        
        if N > 2 && 3*N == opts.SignalLength
            N = N-1;
        end
        % Order must be even 
        if isodd(N)
            N = max(2,N-1);
        end
                
        params = {'bandpassiir', 'FilterOrder', N,...
            'PassbandFrequency1', Wpass(1), 'PassbandFrequency2', Wpass(2),...
            'StopbandAttenuation1', Astop, 'PassbandRipple', Apass,...
            'StopbandAttenuation2', Astop, 'DesignMethod', 'ellip'};

        warning(message('signal:internal:filteringfcns:SignalLengthForIIR'));
        
    else
        params = {'bandpassiir', 'StopbandFrequency1', Wstop(1),...
            'PassbandFrequency1', Wpass(1), 'PassbandFrequency2', Wpass(2),...
            'StopbandFrequency2', Wstop(2), 'StopbandAttenuation1', Astop,...
            'PassbandRipple', Apass, 'StopbandAttenuation2', Astop,...
            'DesignMethod', 'ellip'};
    end
else
    % FIR design
    params = {'bandpassfir', 'StopbandFrequency1', Wstop(1),...
        'PassbandFrequency1', Wpass(1), 'PassbandFrequency2', Wpass(2),...
        'StopbandFrequency2', Wstop(2), 'StopbandAttenuation1',Astop,...
        'PassbandRipple', Apass, 'StopbandAttenuation2', Astop,...
        'DesignMethod', 'kaiserwin', 'MinOrder', 'Even'};
end

if ~opts.IsNormalizedFreq
    params = [params {'SampleRate',Fs}];
end
opts.FilterObject = designfilt(params{:});

%--------------------------------------------------------------------------
function N = getIIRMinOrder(WpassNormalized,WstopNormalized,Apass, Astop)
% Compute analog frequencies
%   WpassNormalized, WstopNormalized are passband and stopband normalized
%   frequencies Apass, and Astop are ripple and attenuation in linear units

% Analog frequencies
c = sin(pi*(WpassNormalized(1)+WpassNormalized(2)))/(sin(pi*WpassNormalized(1))+sin(pi*WpassNormalized(2)));

aWpass = abs((c-cos(pi*WpassNormalized(2)))/sin(pi*WpassNormalized(2)));
ws1 = (c-cos(pi*WstopNormalized(1)))/sin(pi*WstopNormalized(1));
ws2 = (c-cos(pi*WstopNormalized(2)))/sin(pi*WstopNormalized(2));
aWstop = min(abs([ws1,ws2]));

[N, ~] = signal.internal.filteringfcns.getMinIIREllipOrder(aWpass,aWstop,Apass,Astop);

N = 2*N;


