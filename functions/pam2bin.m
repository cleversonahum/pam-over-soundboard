function [ bitstream ] = pam2bin( symbols, M )
    % Function which takes a vector in M-PAM representation and convert 
    % them to a vector with binary representation
    %
    % symbols: vector with symbols
    % M: Constellation order

    symbol_indices_rx=ak_pamdemod(symbols,M);
    bitstream = ak_unsliceBitStream(symbol_indices_rx, log2(M));
end

