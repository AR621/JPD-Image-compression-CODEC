%% All* I see is green
function out_img = YCbCr_converter(image, convert_to, D)
    % All the (shared) vars
    
    D = 1; % <- as in ITU-R BT.601-7 takes value of either 1 or 4
    if convert_to
        out_img = RGB2YCC(image, D);
    else
        out_img = YCC2RGB(image);
    end
        fprintf("YCbCr converter done.\n")
    function YCCedIMG = RGB2YCC(in_img, D)
            DIM = size(in_img);
            Ey = nan(DIM(1), DIM(2)); Ecb = nan(DIM(1), DIM(2)); Ecr = nan(DIM(1), DIM(2)); % Analogs
            YCCedIMG = nan(DIM(1), DIM(2), DIM(3));
            in_img = double(in_img)./255;
            for x = 1:DIM(1)
                for y = 1:DIM(2)
                    % Analog
                    Ey(x,y)  = ( + (0.299 * in_img(x,y,1)) + (0.587 * in_img(x,y,2)) + (0.114 * in_img(x,y,3)));
                    Ecr(x,y) = ( + (0.701 * in_img(x,y,1)) - (0.587 * in_img(x,y,2)) - (0.114 * in_img(x,y,3))) / (2 - 2 * 0.299);
                    Ecb(x,y) = ( - (0.299 * in_img(x,y,1)) - (0.587 * in_img(x,y,2)) + (0.886 * in_img(x,y,3))) / (2 - 2 * 0.114);
                end
            end
            % Analog to digital
            Y = round((219 * Ey + 16) * D) / D; Cb = round((224 * Ecb + 128) * D) / D; Cr = round((224 * Ecr + 128) * D) / D;
            YCCedIMG(:,:,1) = Y(:,:); YCCedIMG(:,:,2) = Cb(:,:); YCCedIMG(:,:,3) = Cr(:,:);
            YCCedIMG = uint8(YCCedIMG);
    end
    % degreening
    function RGBedIMG = YCC2RGB(in_img)
            DIM = size(in_img);
            R = nan(DIM(1), DIM(2));    Y  = double(in_img(:,:,1));
            G = nan(DIM(1), DIM(2));    Cb = double(in_img(:,:,2));
            B = nan(DIM(1), DIM(2));    Cr = double(in_img(:,:,3));
            Ynormalizer = 255/219; % <-- spans out reRGBed image into range from 0 to 255
            RBnormalizer = 255/224;
            RGBedIMG = nan(DIM(1), DIM(2), DIM(3));
            for x = 1:DIM(1)
                for y = 1:DIM(2)
                    R(x,y) = (round((Y(x,y) - 16) * Ynormalizer + 0                                                  * RBnormalizer  + (2 - 2 * 0.299) * (Cr(x,y) - 128)                    * RBnormalizer));
                    G(x,y) = (round((Y(x,y) - 16) * Ynormalizer - (0.114/0.587) * (2 - 2 * 0.114) * (Cb(x,y) - 128)  * RBnormalizer  - (0.299/0.587) * (2 - 2 * 0.299) * (Cr(x,y) - 128)    * RBnormalizer));
                    B(x,y) = (round((Y(x,y) - 16) * Ynormalizer + (2 - 2 * 0.114) * (Cb(x,y) - 128)                  * RBnormalizer  + 0                                                    * RBnormalizer));
                end
            end
            RGBedIMG(:,:,1) = R(:,:); RGBedIMG(:,:,2) = G(:,:); RGBedIMG(:,:,3) = B(:,:);
            RGBedIMG = uint8(RGBedIMG);
            imwrite(RGBedIMG, "decompressed_image.jpg");
    end
% *Most of what I see
end