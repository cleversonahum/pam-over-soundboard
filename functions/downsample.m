function [downsampled] = upsample(upsampled_symbols, L)
    % Upsample the signal
    %
    % symbols: vector to be upsampled
    % L: downsampled factor
    
    downsampled=upsampled_symbols(1:L:end); %complete upsampling operation
end