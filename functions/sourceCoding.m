function [ comp_sig ] = sourceCoding( image_path )
    % Source Coding receives an image and compress it using DCT and Huffman
    %
    % image_path: filename (including all path to the image)
    
    [syms, p] = imagesHuffman('images'); % Defining huffman requirements
    dict = huffmandict(syms, p); % Huffman Dictionary
    sig = uint8(dct2(single(imread(image_path))));
    comp_sig = huffmanenco(sig(:),dict);

end

