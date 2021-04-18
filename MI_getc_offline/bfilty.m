function ts = bfilty(ts,ord,cutfreq,sf,ftype)
%BFILTY Butterwoth time series filtering
%   timeSeries = bfilt(timeSeries,order,cutfreq,sf,ftype)
% 
%   timeSeries = a column time series or a matrix.
%
%   sf = sampling frequency in Hz
%
%   ftype = 's' for band stop
%           'h' high pass
%           'l' low pass
%           'b' band pass
%
%   ftype can be appended with 's','r','z' (e.g. 'hz') to pad vectors
%   either by replicating the edges symmetrically, with the last value and
%   with 0
%
%   order = the order of the filter (1~Gaussian inf~ideal) 
% 
n0 = size(ts,1);
padN = floor(n0/4);	% Padding with 4*sigma pixels.
ts = ts([padN:-1:1 1:n0 n0:-1:(n0-padN+1)],:);
cutfreq = cutfreq/sf;
[n,m]=size(ts);
xx = [0:ceil(n/2-1), ceil(-n/2):-1]' / n;
g = 1./(1+(xx./cutfreq(end)).^(2*ord));
if (ftype =='h'), g = 1-g; end
if (ftype =='b') || (ftype =='s')
	g1 = 1./(1+(xx./cutfreq(1)).^(2*ord));
	g = g - g1;
    if (ftype =='s')
        g = 1 - g;
    end
end
g = repmat(g,1,m);
fx = fft(ts);
ts = real(ifft(fx.*g));
ts = ts((1:n0)+padN,:);	% get back to original size