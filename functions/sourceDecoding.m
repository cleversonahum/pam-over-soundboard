function [ sig ] = sourceDecoding( comp_sig )
    % Source Decoding receives data encoded with huffman and recovers the
    % image
    %
    % comp_sig: Signal compressed with Huffman
    
    [syms, p] = imagesHuffman('images'); % Defining huffman requirements
    dict = huffmandict(syms, p); % Huffman Dictionary
    sig = huffmandeco(double(comp_sig), dict); % Decoding the signal
    sig = reshape(sig, [256,256]); % Reshape signal to image dimensions
    sig = uint8(idct2(single(sig)));  % to image domain  

end

