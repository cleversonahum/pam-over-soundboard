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

% Global Variables
Fs=44100; %sampling frequency in Hz
S=1000; %number of symbols per frame
L=2; %oversampling factor
wc=pi/2; %carrier frequency: 0.5*pi rad (or Fs/4 Hz)
M=4; %number of symbols in alphabet
b=log2(M); %num of bits per symbol
n_bits=b*S; %total number of bits to be transmitted
rolloff=0.1; %roll-off factor for sqrt raised cosine
delay_symbols=6; %delay at symbol rate

%%%%%%%%%%%%%%REMOVE IT AFTER%%%%%%%%%%%%%%%%%%%%%%%
% Generating bits to be streamed
temp=rand(n_bits,1); %random numbers ~[0,1]
tx_bitstream=temp>0.5; %bits: 0 or 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modulating bitstream to M-PAM symbols
symbols = bin2pam(tx_bitstream, M);

% Upsampling symbols in according to L
upsampled_symbols = upsample(symbols, L);

% Convolving the signal with the pulse shape (Raised Cosine)
pulse_signal = pulseShape(upsampled_symbols,L,rolloff, delay_symbols);

signal = matchedFilter(pulse_signal, L,rolloff, delay_symbols);

% Downsampling symbols in according to L
% downsampled_symbols = downsample(upsampled_symbols, L);

% Demodulating M-PAM symbols to bitstream
% rx_bitstream = pam2bin(symbols,M);


