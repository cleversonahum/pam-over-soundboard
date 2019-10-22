function [ decoded_sig ] = channelDecoding( coded_sig, type, tblen)
    % Channel Decoding receives an coded bitstream and decodes it
    %
    % coded_sig: output from channel coding
    % type: 'conv' or 'linear'
    
    if nargin < 2
        type = 'conv'; %default type
    end
    
    if(strcmp(type,'conv')) % Convolutional Encoder
        K=3;
        G1=7;
        G2=5;
        trel=poly2trellis(K,[G1 G2]);
        decoded_sig=vitdec(coded_sig,trel,tblen,'trunc','hard');
        
    elseif(strcmp(type,'linear')) % Hamming Encoder
        decoded_sig = decode(coded_sig,7,4,'hamming/binary');
        
    else
        disp('Choose a valid option for channel decoder');
    end


end

