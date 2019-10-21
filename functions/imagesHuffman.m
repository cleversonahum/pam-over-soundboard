function [ syms, p ] = imagesHuffman( images_path )
    % Read images and process the probabilities for each value to generate
    % a huffman tree
    %
    % images_path: path to image files
       
    images = dir([images_path filesep '*.tiff']);
    dct_imgs = [];
    for i = 1:length(images)
       dct_img = uint8(dct(single(imread([images_path filesep...
           images(i).name])))); % DCT value from one image
       dct_imgs = [dct_imgs; dct_img(:)];
    end
    dct_imgs = sort(dct_imgs);
    syms = unique(dct_imgs);
    freq = histc(dct_imgs, syms);
    p = freq/sum(freq);
end

