function [ img_props ] = imgProps( img_number )
    % Function that generate image properties in according to image chosen
    % a huffman tree
    %
    % images_number: Image number chosen
       
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
end