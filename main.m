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

%%%%%%%%%%%%%%REMOVE IT AFTER%%%%%%%%%%%%%%%%%%%%%%%
% Generating bits to be streamed
temp=rand(n_bits,1); %random numbers ~[0,1]
tx_bitstream=temp>0.5; %bits: 0 or 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                

%% Transmitter

% Reading Image and Source coding functions
comp_tx_bitstream = sourceCoding('images/5.1.09.tiff');

%Add zeroPadding in the last frame
temp=rand(ceil(length(comp_tx_bitstream)/(log2(M)*S))*log2(M)*S - ...
               length(comp_tx_bitstream),1); %random numbers ~[0,1]
padding=temp>0.5; %bits: 0 or 1
tx_bitstream = [comp_tx_bitstream ; padding];

% Channel Coding
coded_tx_bitstream = channelCoding(tx_bitstream, channel_code_type);

% Modulating bitstream to M-PAM symbols
[symbols, power_payload] = bin2pam(coded_tx_bitstream, M);
[normPreambledSymbols, txPreamble] = insertPreamble(symbols,power_payload,S);


% Upsampling symbols in according to L
upsampled_symbols = upsample(normPreambledSymbols, L);
upsampled_txPreamble = upsample(txPreamble, L);

% Convolving the signal with the pulse shape (Raised Cosine)
pulse_signal = pulseShape(upsampled_symbols,L,rolloff, delay_symbols);

%Upconversion to 0.5*pi or 11.025 kHz
% x_signal = upconversion(sqrt(2)*pulse_signal,4410, Fs);
x_signal = pulse_signal;

%% Channel

% Channel Taps. To see the frequency behavior from this channel run:
% freqz(ht)
ht = [0.2 0.9 0.3];
SNR = 5; % in dBW

if en_channel == 1
    ht_ls = firls(10,[0 0.2 0.4 0.6 0.8 1],[0.75 0.5 0.3 0.2 0.05 0.001]);
    % Channel Model ( y = H*x + n), where H is the channel, x is the
    % transmitted signal and n is the AWGN noise
    r_channel = conv(x_signal, ht_ls);
    r_power = 10*log10(mean(r_channel.^2)); % in dBW
    y_signal = awgn(r_channel,SNR,r_power);
else
    y_signal = x_signal;
end 


%% Receiver

%Downconversion
% rx_signal = downconversion(y_signal,4410, Fs);
rx_signal = y_signal;

%Matched Filter
rx_signal_filt = matchedFilter(rx_signal, L,rolloff, delay_symbols);

% Symbol synchronization on the receiver side
% Furthemore, this function implements the downsampling to Rsym
[c,lags] = xcorr(rx_signal_filt,upsampled_txPreamble);
plot(lags,c);
[rx_symbols, n_frames] = timeSync(rx_signal_filt, S, upsampled_txPreamble,L);

% Demodulating M-PAM symbols to cbitstream
[rx_bitstream, rx_demod_ind ] = pam2bin(rx_symbols,M);

% Channel Decoding
channel_code_tblen = n_frames*S;
decoded_rx_bitstream = channelDecoding(rx_bitstream(1:n_frames*S*log2(M)),...
                                       channel_code_type,...
                                       channel_code_tblen);
BER = berEstimation(decoded_rx_bitstream, tx_bitstream);


% Source Decoding and recovering image
img = sourceDecoding(decoded_rx_bitstream);



