function [ rxSymbols ] = timeSync( preambledSymbols, frameSize, txPreamble, upFactor)
%timeSync Summary of this function:
%   Goal: Given the number of samples per frame, this function synchronizes
%   in time the received signal
%   Input:
%   - preambledSymbols: the received signal that needs symbol synchronization.
%   - txPreamble: the preambles transmitted by the transmitter.
%   - frameSize: how much samples to each frame.
%   Output:
%   - preambledSignal: the normalized signal with a preamble in each frame.
%   - txPreamble: the preamble signal in symbols
    preambleSize = length(txPreamble)/upFactor;
   
    [c,lags] = xcorr(preambledSymbols,txPreamble);
    threshold = max(abs(c))*0.9;
    framesLag = lags(find(abs(c)>threshold));
    
    nFrames = length(framesLag);
    symbols = zeros(frameSize*nFrames*upFactor,1);
    for i = 1:nFrames
        if (i == nFrames)
            final = length(preambledSymbols((framesLag(i)+1+upFactor*preambleSize):end));
            symbols((1+(i-1)*frameSize*upFactor):((i-1)*frameSize*upFactor + final)) = ...
            preambledSymbols((framesLag(i)+1+upFactor*preambleSize):end);
        else
            symbols((1+(i-1)*frameSize*upFactor):(i*(frameSize)*upFactor+1-upFactor)) = ...
            preambledSymbols(framesLag(i)+1+upFactor*preambleSize:...
                             (framesLag(i)+1+upFactor*preambleSize+upFactor*(frameSize-1)));
        end 
    end
    
    symbols = downsample(symbols, upFactor);   
    rxSymbols = nonzeros(symbols);
    



end

