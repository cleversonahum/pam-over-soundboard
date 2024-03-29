function [signal] = matchedFilter(shaped_signal, L, rolloff, delayInSymbols)
% Apply Matched filted considering a raised cosine pulse shape to
% the signal in transmitter
%
% signal = signal to be shaped by the raise cosine pulse
% L = upsamling factor
% rolloff = rolloff factor for raised cosine
% delayInSymbols = Delay in symbols for raised cosine

    htx=ak_rcosine(1,L,'fir/sqrt',rolloff,delayInSymbols); %sqrt raised cosine
    hrx=conj(fliplr(htx)); %matched filter
    signal = conv(shaped_signal, hrx);
end