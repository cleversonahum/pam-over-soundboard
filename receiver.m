% Script to Receiver

addpath('functions');


%% Global Variables
Fs=44100; %sampling frequency in Hz
Fc=4410; % carrier frequency in Hz
S=1000; %number of symbols per frame
L=20; %oversampling factor
wc=pi/2; %carrier frequency: 0.5*pi rad (or Fs/4 Hz)
M=4; %number of symbols in alphabet
b=log2(M); %num of bits per symbol
% n_bits=b*S; %total number of bits to be transmitted
n_bits = 10500;
rolloff=0.5; %roll-off factor for sqrt raised cosine
delay_symbols=3; %delay at symbol rate
en_channel = 1; % Flag to Enable Channel
channel_code_type = 'conv'; % 'conv' or 'linear'
img_name = 'images/5.1.10.tiff';
input_audio = './transmit_audio.wav';
img_number = 9; % 9, 10, 11, 12, 13 or 14

switch img_number
    case 9
        img_props.filename = 'images/5.1.09.tiff';
        img_props.source_size = 98192;
    case 10
        img_props.filename = 'images/5.1.10.tiff';
        img_props.source_size = 170036;
    case 11
        img_props.filename = 'images/5.1.11.tiff';
        img_props.source_size = 98462;
    case 12
        img_props.filename = 'images/5.1.12.tiff';
        img_props.source_size = 125322;
    case 13
        img_props.filename = 'images/5.1.13.tiff';
        img_props.source_size = 217301;
    case 14
        img_props.filename = 'images/5.1.14.tiff';
        img_props.source_size = 141780;
    otherwise
        disp('Choose a valid image (9, 10, 11, 12, 13 or 14)')
        return
        
end

%% Receiver

% Reading audio received
y_signal = audioread(input_audio);
y_signal = y_signal(:)';

%Downconversion
rx_signal = downconversion(y_signal,4410, Fs);
% rx_signal = y_signal;

%Matched Filter
rx_signal_filt = matchedFilter(rx_signal, L,rolloff, delay_symbols);

% Symbol synchronization on the receiver side
% Furthemore, this function implements the downsampling to Rsym
txPreamble = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 ...
                  +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1];
upsampled_txPreamble = upsample(txPreamble, L);
[c,lags] = xcorr(rx_signal_filt,upsampled_txPreamble);
plot(lags,c);
[rx_symbols, n_frames, rx_up_preamble] = timeSync(rx_signal_filt, S, ...
                                                  upsampled_txPreamble,L);

matrixLength = size(rx_up_preamble);
for j = 1:matrixLength(1)
    gain_adjustment = mean(rx_up_preamble(j,1:end)./(2.2361*txPreamble));
    rx_symbols((j-1)*S+1:S*j) = rx_symbols((j-1)*S+1:S*j)/gain_adjustment;
end

% Demodulating M-PAM symbols to cbitstream
rx_bitstream = pam2bin(rx_symbols,M);

% Channel Decoding
channel_code_tblen = n_frames*S;
decoded_rx_bitstream = channelDecoding(rx_bitstream(1:n_frames*S*log2(M)),...
                                       channel_code_type,...
                                       channel_code_tblen);
%BER = berEstimation(decoded_rx_bitstream, tx_bitstream);


% Source Decoding and recovering image
img = sourceDecoding(decoded_rx_bitstream(1:img_props.source_size));

% Calculating PSNR
ori_img = imread(img_name);
psnr_value = psnr(double(img), double(ori_img));