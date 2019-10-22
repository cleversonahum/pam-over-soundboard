function [ comp_sig ] = sourceCoding( image_path )
    % Source Coding receives an image and compress it using DCT and Huffman
    %
    % image_path: filename (including all path to the image)
    
    [syms, p] = imagesHuffman('images'); % Defining huffman requirements
    dict = huffmandict(syms, p); % Huffman Dictionary
    dct_img = dct2(single(imread(image_path))); % DCT value from one image
    dct_img(abs(dct_img)<20) = 0; % Discarding high frequencies with low values
    dct_img = round(dct_img); % Round values (avoiding fractional)
    dct_img = int16(dct_img); % Converting to uint16 representation
    comp_sig = huffmanenco(dct_img(:),dict); % Encoding signal in huffman representation

end

