function [ ber ] = berEstimation( rxBitstream, txBitstream )
%berEstimation Summary of this function goes here
%   Estimate the BER
%   Input:
%   - rxBitstream: the received bitstream.
%   - txBitstream: the transmitted bitstream.
%   Output:
%   - ber: the BER in percentage.

   errors = logical(rxBitstream) ~= logical(txBitstream);
   ber = sum(errors)/length(rxBitstream);

end

