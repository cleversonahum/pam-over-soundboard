function [upsampled] = upsample(symbols, L)
    % Upsample the signal
    %
    % symbols: vector to be upsampled
    % L: upsampling factor
    
    upsampled=zeros(1,length(symbols)*L); %pre-allocate space
    upsampled(1:L:end)=symbols; %complete upsampling operation
end