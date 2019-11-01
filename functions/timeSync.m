function [ rxSymbols, nFrames, preambleMatrix ] = timeSync(preambledSymbols, ...
                                                            frameSize, ...
                                                            txPreamble, ...
                                                            upFactor)
%timeSync Summary of this function:
%   Goal: Given the number of samples per frame, this function synchronizes
%   in time the received signal
%   Input:
%   - preambledSymbols: the received signal that needs symbol synchronization.
%   - txPreamble: the preambles transmitted by the transmitter.
%   - frameSize: how much samples to each frame.
%   - upFactor: the oversampling factor from the preambledSymbols.
%   Output:
%   - preambledSignal: the normalized signal with a preamble in each frame.
%   - txPreamble: the preamble signal in symbols
%   - preambleMatrix: The matrix with all the received preambles in the
%   receiver. Obs: This preambled is upsampled yet.
    preambleSize = length(txPreamble)/upFactor;
   
    % Find the the position that starts the preamble in each frame
    [c,lags] = xcorr(preambledSymbols,txPreamble);
    threshold = max(abs(c))*0.8;
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
    previousLastLag = lastLag;
    lagsRange = find(lags >= detectedLags(previousLastLag + 1) & ...
                     lags <= detectedLags(end));
    framesLag(j) = lags(find(abs(c(lagsRange)) == ...
                        max(abs(c(lagsRange))))+lagsRange(1)-1);
    framesLag = [ framesLag(1:j-1)' nonzeros(framesLag(j:end))];
    
    % Read the symbols from each frame
    nFrames = length(framesLag);
    symbols = zeros((frameSize+preambleSize)*nFrames*upFactor,1);
    preambleMatrix = zeros(nFrames, preambleSize);
    for i = 1:nFrames
        if (i == nFrames)
            final = length(preambledSymbols((framesLag(i)+1+upFactor*preambleSize):end));
%             final = length(preambledSymbols((framesLag(i)+1+upFactor*preambleSize):(end)));
            symbols((1+(i-1)*frameSize*upFactor):((i-1)*frameSize*upFactor + final)) = ...
            preambledSymbols((framesLag(i)+1+upFactor*preambleSize):end);
%             preambledSymbols((framesLag(i)+1+upFactor*preambleSize):(end));
        else
            symbols((1+(i-1)*frameSize*upFactor):(i*(frameSize)*upFactor+1-upFactor)) = ...
            preambledSymbols(framesLag(i)+1+upFactor*preambleSize:...
                             (framesLag(i)+1+upFactor*preambleSize+upFactor*(frameSize-1)));

        end 
        preambleMatrix(i,1:preambleSize) = ...
            preambledSymbols(framesLag(i):upFactor:framesLag(i)+upFactor*preambleSize-1);
    end
    
    % Downsampling the signal
    symbols2 = downsample(symbols, upFactor);
    rxSymbols = nonzeros(symbols2);
    



end

