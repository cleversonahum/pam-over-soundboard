function [ syms, p ] = imagesHuffman( images_path )
    % Read images and process the probabilities for each value to generate
    % a huffman tree
    %
    % images_path: path to image files
       
    images = dir([images_path filesep '*.tiff']);
    dct_imgs = [];
    for i = 1:length(images)
       dct_img = dct2(single(imread([images_path filesep...
           images(i).name]))); % DCT value from one image
       dct_img(abs(dct_img)<20) = 0; % Discarding high frequencies with low values
       dct_img = round(dct_img); % Round values (avoiding fractional)
       dct_img = int16(dct_img); % Converting to uint16 representation
       dct_imgs = [dct_imgs; dct_img(:)];
    end
    dct_imgs = sort(dct_imgs);
    syms = unique(dct_imgs);
    freq = histc(dct_imgs, syms);
    p = freq/sum(freq);
end

