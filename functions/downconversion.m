function [ downconvertedSignal ] = downconversion( signal, frequency, Fs)
%upconversion Summary of this function goes here
%   This function translate a  signal in DC to a band pass frequency
 
    n = 0:length(signal)-1;
    downconvertedSignal = signal .* cos(2*pi*frequency*(n/Fs));


end

