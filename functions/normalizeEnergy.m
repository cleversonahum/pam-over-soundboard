function [ normalizedEnergy ] = normalizeEnergy( signal1,powerVal )
%normalizedEnergy Summary of this function goes here
%   This function normalizes the energy from the signal1 to the same energy
%   from the signal2
%   Input:
%   - signal1: the signal as reference in the normalization.
%   - powerVal: the reference power in the energy normalization.
%   Output:
%   - normalizedEnergy: the normalized signal in relation 
%                       to powerVal
    normalizedEnergy = sqrt(mean(abs(signal1).^2)/powerVal);

end

