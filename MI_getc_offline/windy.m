function [windows_N , window2sec] = windy(signal_length , window_sz , overlap_sz , Fs)
%MATLAB R2019b
%
%Calculating number of needed windows and creating a vector of time as
%function of windows.
%
%signal_length - recording number of sampels.
%window_sz - window size.
%overlap_sz - overlap size.
%Fs - Sampling rate.
%
%window_N - number of total windows that will be used.
%window2minutes - vector that transform the window time jumps into minutes
%scale.
%
%--------------------------------------------------------------------------------

%Number of windows.
windows_N = floor((signal_length - window_sz)/(window_sz-overlap_sz))+1;

%Adjusting the window size to seconds.
window2sec = window_sz/(2*Fs) : (window_sz - overlap_sz) / Fs : signal_length/Fs...
    - window_sz/(Fs*2);