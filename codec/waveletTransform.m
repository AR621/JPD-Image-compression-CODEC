%% We shall sail together
function [C, S] = waveletTransform(in_img, T, wn, quantizationNlevel)
    fprintf("Wavelet transform starting.\n")
    [C, S] = waveletify(in_img, T, wn, quantizationNlevel);
    function [C, S] = waveletify(in_img, T, wn, quantizationNlevel)
        dwtmode('per');
        level = 8; 
        DIM = size(in_img);
        waveletedIMG = nan(DIM(1), DIM(2), DIM(3));
        [C, S] = wavedec2(in_img, level, wn);
        C(abs(C) < T) = 0; % HARD THR
        C = quantization(C, quantizationNlevel);

        function quanted = quantization(signal, n)
            Q = 2^n;
            scale = (max(signal) - min(signal))/Q;
            signal = signal / scale;            % scale for quantz
            signal = round(signal);             % quantization
            quanted = round(signal * scale, 3); % rescale after quantz
        end
    end
end
