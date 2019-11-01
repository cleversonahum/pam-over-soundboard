function [ normalizedEnergy ] = normalizeEnergy(power1,power2)
%normalizedEnergy Summary of this function goes here
%   This function normalizes the energy from the signal1 to the same energy
%   from the signal2
%   Input:
%   - power1: the power as reference in the normalization.
%   - power2: the power to be normalized.
%   Output:
%   - normalizedEnergy: the normalized energy from power1  in relation 
%                       to power2W
    normalizedEnergy = power2/power1;

end

