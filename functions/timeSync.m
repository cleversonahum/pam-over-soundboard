function [ rxSymbols ] = timeSync( preambledSymbols, frameSize, ...
                                   txPreamble, upFactor, mf_delay)
%timeSync Summary of this function:
%   Goal: Given the number of samples per frame, this function synchronizes
%   in time the received signal
%   Input:
%   - preambledSymbols: the received signal that needs symbol synchronization.
%   - txPreamble: the preambles transmitted by the transmitter.
%   - frameSize: how much samples to each frame.
%   - upFactor: the oversampling factor from the preambledSymbols.
%   - mf_delay: the delay in symbols that the matched filter adds.
%   Output:
%   - preambledSignal: the normalized signal with a preamble in each frame.
%   - txPreamble: the preamble signal in symbols
    preambleSize = length(txPreamble)/upFactor;
   
    % Find the the position that starts the preamble in each frame
    [c,lags] = xcorr(preambledSymbols,txPreamble);
    threshold = max(abs(c))*0.9;
    detectedLags = lags(find(abs(c)>threshold));
    framesLag = zeros(length(detectedLags),1);
    lastLag = 1;
    j = 1;
    for i = 1:length(detectedLags)-1
        if (detectedLags(i+1) - detectedLags(i) > frameSize*upFactor)
            previousLastLag = lastLag;
            lastLag = i;
            if(lastLag == previousLastLag)
                lagsRange = find(lags >= detectedLags(previousLastLag) & ...
                                 lags <= detectedLags(lastLag));
            else
                lagsRange = find(lags >= detectedLags(previousLastLag+1) & ...
                                 lags <= detectedLags(lastLag));
            end
            framesLag(j) = lags(find(abs(c(lagsRange)) == ...
                                max(abs(c(lagsRange))))+lagsRange(1)-1);
            j = j + 1;
        end
    end 
    lagsRange = find(lags >= detectedLags(lastLag + 1) & ...
                     lags <= detectedLags(end));
    framesLag(j) = lags(find(abs(c(lagsRange)) == ...
                        max(abs(c(lagsRange))))+lagsRange(1)-1);
    framesLag = [ framesLag(1:j-1)' nonzeros(framesLag(j:end))];
    
    % Read the symbols from each frame
    nFrames = length(framesLag);
    symbols = zeros(frameSize*nFrames*upFactor,1);
    for i = 1:nFrames
        if (i == nFrames)
            final = length(preambledSymbols((framesLag(i)+1+upFactor*preambleSize):(end-2*mf_delay*upFactor)));
            symbols((1+(i-1)*frameSize*upFactor):((i-1)*frameSize*upFactor + final)) = ...
            preambledSymbols((framesLag(i)+1+upFactor*preambleSize):(end-2*mf_delay*upFactor));
        else
            symbols((1+(i-1)*frameSize*upFactor):(i*(frameSize)*upFactor+1-upFactor)) = ...
            preambledSymbols(framesLag(i)+1+upFactor*preambleSize:...
                             (framesLag(i)+1+upFactor*preambleSize+upFactor*(frameSize-1)));
        end 
    end
    
    % Downsampling the signal
    symbols = downsample(symbols, upFactor);   
    rxSymbols = nonzeros(symbols);
    



end

