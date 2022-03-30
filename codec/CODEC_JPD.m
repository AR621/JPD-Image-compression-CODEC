function CODEC_JPD
    %% Gui
    figure(1)
    p = gcf;

    sliderT = uicontrol(p, Style="slider");
    sliderT.Value = 0.5;
    sliderT.Callback = @updateUI;

    sliderN = uicontrol(p, Style="slider", Position=[100 20 60 20]);
    sliderN.Value = .5;

    T = sliderT.Value * 200;
    n = sliderN.Value * 500;

    textT = uicontrol(p, "Style","text",Position=[10 45 80 15]);
    textT.String = "T = " + T;

    textN = uicontrol(p, "Style","text",Position=[90 45 80 15]);
    textN.String = "n = " + n;

    textS = uicontrol(p, "Style","text",Position=[90 115 80 15]);
    textS.String = "Scaling";

    textI = uicontrol(p, "Style","text",Position=[10 115 80 15]);
    textI.String = "Image";

    textMain = uicontrol(p, "Style","text", Position=[50 300 250 50]);
    textMain.String = "JPD image converter by Patryk Dolaciński";

    sliderN.Callback = @updateUI;

    startButton = uicontrol(p, Style="pushbutton", Position=[200 20 100 30]);
    startButton.String = "Start compression";

    scalePopup = uicontrol(p, "Style","popupmenu", Position=[90 95 80 15]);
    scalePopup.String = {'0.25', '0.50', '0.75', '1'};

    imagePopup = uicontrol(p, "Style","popupmenu", Position=[10 95 80 15]);
    imagePopup.String = {'tiger' 'Wiosna-winniczka'};

    startButton.Callback = @convertAndCompare;
    %% Vars
    D = 1;
    wn = 'bior4.4';
    function updateUI(~, ~)
        figure(1)
        T = sliderT.Value * 200;
        n = sliderN.Value * 500;
        textN.String = "n = " + n;
        textT.String = "T = " + T;
    end
    %% COMPRESSION
    function convertAndCompare(src, ~)
    T = sliderT.Value * 200;
    n = sliderN.Value * 500;
%     scale = 0.75;
    val = scalePopup.Value;
    scale = (scalePopup.String{val});
    scale = str2double(scale);
    img = imagePopup.Value;
    in_img_file_name = imagePopup.String{img};
    %% LOAD
%     in_img_file_name = "Wiosna-winniczka";
    %s = dir(in_img_file_name + ".jpg").bytes;
    in_img = imread(in_img_file_name + ".jpg");
    in_img = imresize(in_img,scale);
    imwrite(in_img, in_img_file_name + "TMP.jpg");
    s = dir(in_img_file_name + "TMP.jpg").bytes;
    SIZES = s; DISCS = "Initial image size";
    
    out_img1 = YCbCr_converter(in_img, true, D);
    % s = dir("YCbCr_image.jpg").bytes; d = "after conversion to YCbCr";
    % SIZES = [SIZES s]; DISCS = [DISCS d];
    
    [C, S] = waveletTransform(out_img1, T, wn, n);
    Ctmp = C;
    Stmp = S;
    [~, dictionary] = koder(C, S);
    s = dir("compressedIMG.jpd").bytes; d = "compressed image size";
    SIZES = [SIZES s]; DISCS = [DISCS d];
    %% DECOMPRESSION
    [C, S] = dekoder(dictionary);
    
    % inverse waves
    waveletedIMG = waverec2(C, S, wn);
    waveletedIMG = uint8(waveletedIMG);
    fprintf("Inverse wavelet transform complete.\n")
    % Convert back to RGB
    decompressedImage = YCbCr_converter(waveletedIMG, false, D);
    s = dir("decompressed_image.jpg").bytes; d = "Size after decompression";
    SIZES = [SIZES s]; DISCS = [DISCS d];
    fprintf("Decompression complete!")
    
    
    %% Showtime
    % figure
    % subplot(311)
    % imshow(out_img1(:,:,1),[0 255])
    % title("Y")
    % subplot(312)
    % imshow(out_img1(:,:,2),[0 255])
    % title("Cb")
    % subplot(313)
    % imshow(out_img1(:,:,3),[0 255])
    % title("Cr")
    % figure
    % imshow(out_img1/255)
    % 
    
    % figure
    % imshow(out_img2/255)
    % 
    % figure
    % subplot(321)
    % imshow(in_img(:,:,1))
    % subplot(322)
    % imshow(out_img1(:,:,1))
    % subplot(323)
    % imshow(in_img(:,:,2))
    % subplot(324)
    % imshow(out_img1(:,:,2))
    % subplot(325)
    % imshow(in_img(:,:,3))
    % subplot(326)
    % imshow(out_img1(:,:,3))
    
    % figure
    % subplot(121)
    % imshow(in_img)
    % subplot(122)
    % imshow(re_img1/255)
    
    %% YCbCr lighshow
    
    figure(3)
    subplot(4,3,1)
    imshow(in_img(:,:,1)); title("Red")
    subplot(4,3,2)
    imshow(out_img1(:,:,3)); title("Cr")
    subplot(4,3,3)
    imshow(decompressedImage(:,:,1)); title("re Red")
    subplot(4,3,4)
    imshow(in_img(:,:,2)); title("Green")
    subplot(4,3,5)
    imshow(out_img1(:,:,1)); title("Y")
    subplot(4,3,6)
    imshow(decompressedImage(:,:,2)); title("re Green")
    subplot(4,3,7)
    imshow(in_img(:,:,3)); title("Blue")
    subplot(4,3,8)
    imshow(out_img1(:,:,2)); title("Cb")
    subplot(4,3,9)
    imshow(decompressedImage(:,:,3)); title("re Blue")
    subplot(4,3,10)
    imshow(in_img); title("full RGB")
    subplot(4,3,11)
    imshow(out_img1); title("full YCbCr")
    subplot(4,3,12)
    imshow(decompressedImage); title("full reRGB")
    sgtitle("RGB to YCbCr to RGB process showdown")
    
    
    
    %% Final comparison
    
    MSE = immse(in_img, decompressedImage);
    figure(2)
    sgtitle("image before and after compression; Mean Squared Error:" + MSE)
    subplot(221)
    imshow(in_img)
    title("Original image")
    subplot(222)
    imshow(decompressedImage)
    title("Decompressed image")
    subplot(223)
    imshow(sum(in_img-decompressedImage,3))
    title("Difference betweeen images")
    
    subplot(224)
    for s = 1:size(SIZES,2)
        bar(s,SIZES(1,s))
        hold on
    end
    hold off
    legend(DISCS)
    title("Image size in byte's")
    end
end