clear;
clc;
close all;

[img, src, hdr_rgb, bayer, suffix, height, width, depth] = file_open(928, 1440);
global input_dw;         % input image data width
global op_dw;            % operation data width in tone mapping process
global win_size;         % bi-lateral wimdow size
global bayer_fmt;        % RGGB format
global max_clip;         
global min_clip;         
global blc_val;

input_dw = 20;
op_dw = input_dw - 12;
win_size = 5;
bayer_fmt = 1;
max_clip = 99.9;
min_clip = 0;
dg_gain = 1;

r_gain = 800 / 431;
g_gain = 1;
b_gain = 750 / 412;
blc_val = 256;
s = 0.5;
ecmTM_en = 1;
[height, width, depth] = size(hdr_rgb);
% ================================= %
%              blc
% ================================= %
% bayer = blc(bayer, bater_fmt, blc_val, blc_val, blc_val, 0, (2^input_dw)-1);

% ================================= %
%          awb gain
% ================================= %
% bayer = awb_gain(bayer, bayer_fmt, r_gain, g_gain, b_gain, 0, (2^input_dw-1));

% ================================= %
%            dg gain
% ================================= %
% bayer = dg_gain * bayer;
% bayer(bayer > (2^input_dw - 1)) = 2^input_dw - 1;

% ================================= %
%          parameter set
% ================================= %
if (strcmp(suffix, 'raw') || strcmp(suffix, 'cmt'))
    fprintf('input HDR max pixel value = %d, input HDR min pixel value %d\n',max(max(hdr)), min(mim(hdr)));
    hdr = bayer2y(bayer, bayer_fmt, 1, 1, 1);
    hdr = tm_anti_flare(hdr, 3*10^5);
    img_hist((hdr/2^input_dw - 1)*256);
elseif (strcmp(suffix, 'hdr'))
    hdr_rgb = mat2gray(hdr_rgb/(2^input_dw - 1) * 256);
    figure;imshow(hdr_rgb);title('ori hdr');
    figure;imshow(hdr_rgb .* 256);title('hdr linear conpress');
    hdr_rgb = hdr_rgb.* (2^input_dw - 1);
    hdr = (hdr_rgb(:,:,1) + hdr_rgb(:,:,2) + hdr_rgb(:,:,3))/3;
    hdr = floor(hdr);
    figure;imshow(hdr/(2^input_dw - 1));title('hdr gray');
%     gray = mat2gray(hdr)*256;
%     img_hist(gray);
elseif (strcmp(suffix, 'mat'))
    hdr = ((360*hdr_rgb(:,:,1) + 601*hdr_rgb(:,:,2) + 117*hdr_rgb(:,:,3))/1024);
elseif (strcmp(suffix, 'bmp'))
    hdr = ((360*hdr_rgb(:,:,1) + 601*hdr_rgb(:,:,2) + 117*hdr_rgb(:,:,3))/1024);
else 
    hdr = ((360*hdr_rgb(:,:,1) + 601*hdr_rgb(:,:,2) + 117*hdr_rgb(:,:,3))/1024);
end

fprintf('gray HDR max pixel value = %d, grat HDR min pixel value = %d\n', max(max(hdr)), min(min(hdr)));
hdr_rgb_o = zeros(height, width, depth);

%=========================================================%
%  photographic tone mapping from Gemso and Reinhard'et   %
%=========================================================%
if (ecmTM_en)
    [displayGrayImg, s] = ecmTM(hdr);
    fprintf('input Display max pixel value = %d, input Display min pixel value = %d\n', max(max(displayGrayImg)), min(min(displayGrayImg)));
    displayGrayImg = mat2gray(displayGrayImg);
    figure;imshow(displayGrayImg);title('displayGrayImg');
    if (strcmp(suffix, 'raw') || strcmp(suffix, 'cmt'))
        bayer_o = floor((((bayer + 1)./(hdr + 1)).^s).*displayGrayImg);
    else
        hdr_rgb_o(:,:,1) = ((hdr_rgb(:,:,1)./(hdr+1)).^s).*displayGrayImg.*(2^input_dw - 1);
        hdr_rgb_o(:,:,2) = ((hdr_rgb(:,:,2)./(hdr+1)).^s).*displayGrayImg.*(2^input_dw - 1);
        hdr_rgb_o(:,:,3) = ((hdr_rgb(:,:,3)./(hdr+1)).^s).*displayGrayImg.*(2^input_dw - 1);
        figure;imshow(uint8(hdr_rgb_o/(2^(input_dw - 8))));title('image after tone mapping');
%         figure;imshow(mat2gray(hdr_rgb_o/(2^(input_dw - 8)))*256);title('image after tonr mapping');
    end
end
