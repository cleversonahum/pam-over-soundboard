function [ coded_sig ] = channelCoding( comp_sig, type )
    % Channel coding receives an bitstream, adds redundancy and coding
    %
    % comp_sig: output from source coding
    % type: 'conv' or 'linear'
    
    if nargin < 2
        type = 'conv'; %default type
    end
    
    if(strcmp(type,'conv')) % Convolutional Encoder
        K=3;
        G1=7;
        G2=5;
        trel=poly2trellis(K,[G1 G2]);
        coded_sig=convenc(comp_sig,trel);
    else
        disp('Not implemented yet');
    end


end

