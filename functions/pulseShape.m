function [shaped_signal] = pulseShape(signal, L, rolloff, delay_symbols)
% Apply the raised cosine pulse shape to the signal
%
% signal = signal to be shaped by the raise cosine pulse
% L = upsamling factor
% rolloff = rolloff factor for raised cosine
% delayInSymbols = Delay in symbols for raised cosine

    htx=ak_rcosine(1,L,'fir/sqrt',rolloff,delay_symbols); %sqrt raised cosine
    shaped_signal = conv(htx,signal);
end