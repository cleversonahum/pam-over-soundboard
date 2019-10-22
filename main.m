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
addpath('functions');


%% Global Variables
Fs=44100; %sampling frequency in Hz
S=1000; %number of symbols per frame
L=20; %oversampling factor
wc=pi/2; %carrier frequency: 0.5*pi rad (or Fs/4 Hz)
M=4; %number of symbols in alphabet
b=log2(M); %num of bits per symbol
% n_bits=b*S; %total number of bits to be transmitted
n_bits = 10500;
rolloff=0.5; %roll-off factor for sqrt raised cosine
delay_symbols=3; %delay at symbol rate

%%%%%%%%%%%%%%REMOVE IT AFTER%%%%%%%%%%%%%%%%%%%%%%%
% Generating bits to be streamed
temp=rand(n_bits,1); %random numbers ~[0,1]
tx_bitstream=temp>0.5; %bits: 0 or 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Flag to Enable Channel
en_channel = 1;


%% Transmitter

% Modulating bitstream to M-PAM symbols
[symbols, power] = bin2pam(tx_bitstream, M);
[normPreambledSymbols, txPreamble] = insertPreamble(symbols,power,S);

% Upsampling symbols in according to L
upsampled_symbols = upsample(normPreambledSymbols, L);
upsampled_txPreamble = upsample(txPreamble, L);

% Convolving the signal with the pulse shape (Raised Cosine)
pulse_signal = pulseShape(upsampled_symbols,L,rolloff, delay_symbols);

%Upconversion to 0.5*pi or 11.025 kHz
x_signal = upconversion(pulse_signal,11025, Fs);

%% Channel

% Channel Taps. To see the frequency behavior from this channel run:
% freqz(ht)
ht = [0.2 0.9 0.3];
SNR = 3; % in dBW

if en_channel == 1
    % Channel Model ( y = H*x + n), where H is the channel, x is the
    % transmitted signal and n is the AWGN noise
    r_channel = conv(x_signal, ht_bandpass);
    r_power = 10*log10(mean(r_channel.^2)); % in dBW
    y_signal = awgn(r_channel,SNR,r_power);
else
    y_signal = x_signal;
end 


%% Receiver

%Downconversion
rx_signal = upconversion(y_signal,11025, Fs);

%Matched Filter
rx_signal_filt = matchedFilter(rx_signal, L,rolloff, delay_symbols);


% Symbol synchronization on the receiver side
% Furthemore, this function implements the downsampling to Rsym
[c,lags] = xcorr(rx_signal_filt,upsampled_txPreamble);
plot(lags,c);
%     threshold = max(abs(c))*0.9;
normRxSymbols = timeSync(rx_signal_filt, S, upsampled_txPreamble,L);
normalizedEnergy = normalizeEnergy(txPreamble, power);
rxSymbols = normRxSymbols/normalizedEnergy;

% Demodulating M-PAM symbols to bitstream
rx_bitstream = pam2bin(symbols,M);
BER = berEstimation(rx_bitstream, tx_bitstream);



