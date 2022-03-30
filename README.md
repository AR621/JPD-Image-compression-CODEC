# JPD-Image-compression-CODEC
My own (lossy) image compression format written in MATLAB

# Idea behind this compression format

## Encoding
1. RGB to YCbCr color conversion
2. Wavelet transform - biorthogonal 4.4 wavelet transform
3. Tresholding and quantization
4. transforming three image matrices and dimension info into one dimensional vector for encoding
5. counting zeros and changing them for "nx" notation where n is the number of zeros counted (*)
6. Huffman encoding of the transformed vector
7. storage
## Decoding
1. Huffman decoding
2. Transforming one dimensional vector back into dimension info and Y, Cb, Cr matrices
3. Reverse wavelet transform
4. YCbCr to RGB color conversion

(*) this step is done here since wavelet transform usually leaves way more zeros in our vector than any other values, this step allows us to further reduce the size of compressed image 

# Example results
## YCbCr conversion to and back to rgb example:

![webpage example image](
https://github.com/AR621/JPD-Image-compression-CODEC/blob/main/results/YCbCr_tigro.PNG?raw=true  "YCbCr example")

## compression results

### higher quality - smaller compression:
![webpage example image](
https://github.com/AR621/JPD-Image-compression-CODEC/blob/main/results/tiger_T80_n100.PNG?raw=true  "result example 1")

![webpage example image](
https://github.com/AR621/JPD-Image-compression-CODEC/blob/main/results/wiosna_0.75_T45_n71.PNG  "result example 3")

### lower quality - bigger compression:

![webpage example image](
https://github.com/AR621/JPD-Image-compression-CODEC/blob/main/results/tiger_lowest.PNG?raw=true  "result example 2")

![webpage example image](
https://github.com/AR621/JPD-Image-compression-CODEC/blob/main/results/wiosna_0.25.PNG  "result example 4")
