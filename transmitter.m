% Script to trasmitter


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
output_audio = './transmit_audio.wav';
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
                                

%% Transmitter

% Reading Image and Source coding functions
comp_tx_bitstream = sourceCoding(img_props.filename);

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
x_signal = upconversion(pulse_signal,Fc, Fs);

% Saving for audiofile
audiowrite(output_audio, x_signal, Fs);