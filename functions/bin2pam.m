function [symbols] = bin2pam(bitstream, M)
    % Function which takes bitsream vector and convert them to a vector
    % with M-PAM representation
    %
    % bitstream: vector with bits
    % M: Constellation order
    
    const=-(M-1):2:M-1;
    symbo_indices_tx = ak_sliceBitStream(bitstream, log2(M));
    symbols=const(symbo_indices_tx+1);
end