function [ preambledSignal, txPreamble ] = insertPreamble( signal, ...
                                           powerSignal,frameSize)
%insertPreamble Summary of this function:
%   Goal: Given the number of samples per frame, this function inserts a
%   preamble in every frame.
%   Input:
%   - signal: the signal that wants to insert the preambles.
%   - preambleSize: how much symbols the preamble needs to have
%   - frameSize: how much samples to each frame.
%   Output:
%   - preambledSignal: the normalized signal with a preamble in each frame.
%   - txPreamble: the preamble signal in symbols

    lenSignal = length(signal);
    %Barker Code for Preamble:
    %URL: https://en.wikipedia.org/wiki/Barker_code
    nFrames = ceil(length(signal)/frameSize);
    txPreamble = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1];
    powerPreamble = mean(abs(txPreamble).^2);
    normalizedEnergy = normalizeEnergy(powerPreamble, powerSignal);
    txPreambleNorm = sqrt(normalizedEnergy)*txPreamble;
    zeroPaddingSymbols = zeros(1,nFrames*frameSize - length(signal));
    signal = [signal zeroPaddingSymbols];
    normSignal = signal;
    preambleSize = length(txPreamble);

    preambledSignal = zeros(1,nFrames*length(txPreamble) + length(signal));
    frameInit = 1:(frameSize + length(txPreamble)):length(preambledSignal);
    frameFinal = (preambleSize + frameSize):(preambleSize + frameSize):length(preambledSignal);
    if (mod(lenSignal,frameSize) ~= 0)
        frameFinal = [frameFinal length(preambledSignal)];
    end
    
    
    for i= 1:nFrames
        if(i < floor(lenSignal/frameSize + 1))
            preambledSignal(frameInit(i):frameFinal(i)) = ...
                [txPreambleNorm normSignal((1+(i-1)*frameSize):(i*frameSize))];
        else
            preambledSignal(frameInit(i):frameFinal(i)) = ...
                [txPreambleNorm normSignal((1+(i-1)*frameSize):end)];
        end
    end
    

end

