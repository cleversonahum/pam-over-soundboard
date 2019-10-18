% Steps to make the transmission description

% TRANSMISSION/RECEPTION
% 1 - convert image to binary representation / from binary to image representation
% 2 - convert binary representation to M-PAM symbols / from M-PAM symbols to binary
% 3 - Upsampling (consider baud rate) / Downsampling
% 4 - from upsampled symbols to frames with preambles / from frames to upsampled symbols without preable, sync
% 5 - convolution with shaping pulse (maybe use filter) / matched filter, signal gain, Automatic gain control
% 6 - upconversion / downconversion
% 7 - from symbols to audio / from audio to symbols

% Observation: consider relation between BW, symbol rate and Fs. Equalizer