function[displayImg, satu] = ecmTM(hdr)
global input_dw;
global op_dw;
global win_size;
global max_clip;
global min_clip;
global blc_val;

alpha = 0.5;
betha = 0;
thet = 1;
expN = 1;
key = 1;
[height, width] = size(hdr);
displayImg = zeros(height, width);
N = height * width;

%===========================================%
% emc conbined by photographic tone mapping
% from Renhard'et
%===========================================%

% hdr_op = round(hdr./(2^(input_dw - op_dw)) + 1);
% luminanceWorld_mean = exp(sum(sum(log(hdr_op)))/N);
% luminanceWorld_mean = luminanceWorld_mean*(2^(input_dw - op_dw));
% key = key/luminanceWorld_mean;
% key = key^(alpha-1)*thet;

zone = (sum(sum(log2(hdr + 1))))/N;
luminanceWorld_mean = 2^zone;
hdr_max = max(max(hdr));
hdr_min = min(min(hdr));
log2_hdr = log2(hdr+1);
hdr_almost_min = prctile(log2_hdr(:), 0.04);
hdr_almost_max = prctile(log2_hdr(:), 99.96);
hdr_range = hdr_almost_max - hdr_almost_min;
hdr_max_log2 = log2(hdr_max+1);
hdr_min_log2 = log2(hdr_min+1);
thet = floor(12/(4^((2 * zone - hdr_almost_min - hdr_almost_max)/(hdr_almost_max - hdr_almost_min))));
thet = floor(6309.94*0.62^zone + 4.17);

key = floor((1/key)*256);
key = floor(luminanceWorld_mean * key * thet / 256)
lw = clip(2^input_dw-1,0, hdr_max * 2);
hdr = hdr - min(min(hdr));

x = -1:0.001:1;
y1 = (12./4.^(x));
y2 = (12./6.^(x));
y3 = (12./8.^(x));

figure;plot(x,y1,'r',x,y2,'g', x, y3, 'b');title('compress curve show')

% bi_lateral_tm_c(round(hdr./(2^(input_dw - op_dw))+1), 6, 1000, 7);
luminanceBLF = bi_lateral_tm_c(hdr, 1, 2, win_size, 2^(input_dw - op_dw));
% luminanceBLF = luminanceBLF/(2^input_dw-1);
% luminanceBLF = (mat_clip3(luminanceBLF.^alpha.*1, 0, 1)) * key + betha;
luminanceBLF = luminanceBLF/((2^input_dw) - 1);
luminanceBLF = luminanceBLF.^alpha.*1;
luminanceBLF(luminanceBLF > 1) = 1;
luminanceBLF(luminanceBLF < 0) = 0;
luminanceBLF = luminanceBLF * key + betha;
luminanceBLF(luminanceBLF <32) = 32;
figure;imshow(mat2gray(luminanceBLF));title('luminanceBLF show');

x = 1:100:2^(input_dw);
y1 = x./(x + min(min(luminanceBLF)));
y2 = x./(x + mean(mean(luminanceBLF)));
y3 = x./(x + max(max(luminanceBLF)));

figure;plot(x, y1, 'r', x, y2, 'g', x, y3, 'b');axis([-inf, inf, 0, 1]);
title('compress curve show');

luminance = hdr + 1;
displayImg = (luminance.^expN)./((luminanceBLF.^expN) + (luminance.^expN));

luminance_pl = hdr + 2;
displayImg_pl = (luminance_pl.^expN)./((luminanceBLF.^expN)+(luminance_pl.^expN));
constrast = log(displayImg_pl./displayImg)./log(luminance_pl./luminance);

satu = ((1 + 1.6774).*constrast.^0.9925)./(1+1.6774.*constrast.^0.9925);
satu(satu > 1) = 1;
satu(satu < 0.2) = 0.2;
satu = satu.* 0.6;
displayImg = floor(displayImg.* 65535);

lwt = floor((clip(1, 0, (lw/((2^input_dw)-1))^alpha * 1))* key + betha) + 1;
scale_f = floor(((lw + lwt)/lw)*4096);
displayImg = floor(displayImg.* scale_f./(4096*16));

figure;imshow((mat2gray(displayImg)));title('gray after tone mapping, before HA');
figure;imshow(mat2gray(displayImg)*255);title('gray after tone mapping, before HA');
figure;imshow((uint8(displayImg)/16));title('gray after tone mapping, before HA');




