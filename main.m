% PAM Transmission simulation where channel is simulated

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
en_channel = 0; % Flag to Enable Channel
channel_code_type = 'conv'; % 'conv' or 'linear'
channel_code_tblen = 98192; % Needed when using Convolutional channel...
                                % decoding, length of uncoded symbols
                                

%% Transmitter

% Reading Image and Source coding functions
comp_tx_bitstream = sourceCoding('images/5.1.09.tiff');

% Channel Coding
coded_tx_bitstream = channelCoding(comp_tx_bitstream, channel_code_type);

% Modulating bitstream to M-PAM symbols
[symbols, power] = bin2pam(coded_sig, M);
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
SNR = 30; % in dBW

if en_channel == 1
    load('channel.mat');
    % Channel Model ( y = H*x + n), where H is the channel, x is the
    % transmitted signal and n is the AWGN noise
    r_channel = conv(x_signal, htx);
    r_power = 10*log10(mean(r_channel.^2)); % in dBW
    y_signal = awgn(r_channel,SNR,r_power);
else
    y_signal = x_signal;
end 


%% Receiver

%Downconversion
rx_signal = downconversion(1.5*y_signal,11025, Fs);

%Matched Filter
rx_signal_filt = matchedFilter(rx_signal, L,rolloff, delay_symbols);

% Symbol synchronization on the receiver side
% Furthemore, this function implements the downsampling to Rsym
[c,lags] = xcorr(rx_signal_filt,upsampled_txPreamble);
plot(lags,c);
norm_rx_symbols = timeSync(rx_signal_filt, S, upsampled_txPreamble,L);
normalized_energy = normalizeEnergy(txPreamble, power);
rx_symbols = norm_rx_symbols/normalized_energy;

% Demodulating M-PAM symbols to bitstream
rx_bitstream = pam2bin(rx_symbols,M);
BER = berEstimation(rx_bitstream, coded_tx_bitstream);

% Channel Decoding
decoded_rx_bitstream = channelDecoding(rx_bitstream, channel_code_type,...
                                       channel_code_tblen);

% Source Decoding and recovering image
img = sourceDecoding(decoded_rx_bitstream);



