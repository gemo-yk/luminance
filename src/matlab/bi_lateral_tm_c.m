function img_filtered = bi_lateral_tm_c(img_src,pos_sd,lum_sd,win_size, op_dw)
% clc;
% clear;
% close all;
% [img_src,rgb,bayer,suffix,height,width,depth] = file_open(0,0);
% pos_sd = 2;   % pos_sd = position weight standard deviation
% lum_sd = 90;  % lum_sd = luminance weight standard deviation 
% win_size = 3;

% -------------------------------------------- %
%                info                     
% -------------------------------------------- %
[height,width,depth] = size(img_src);
img_filtered = zeros(height,width,depth);
win_size_c = ceil(win_size/2);
pos_wei = zeros(win_size,win_size);
lum_wei = zeros(win_size,win_size);
for n=1:1:win_size
    for m=1:1:win_size
        pos_wei(n,m) = exp((-((win_size_c-n)^2) - ((win_size_c-m)^2))/(2*(pos_sd^2)));
    end
end

pos_wei = fix(pos_wei*4096); %U1Q12
% -------------------------------------------- %
%                 bi lateral                     
% -------------------------------------------- %
for d=1:1:depth
    img_src_in = img_src(:,:,d);
    for h=1:1:height
        for w=1:1:width
            if ((h>=win_size_c && h<=height-win_size_c+1)&&(w>=win_size_c && w<=width-win_size_c+1))
                win_mat_ = mat_gets(img_src_in,h,w,win_size);
                win_mat = (win_mat_ / op_dw);
                for n=1:1:win_size
                    for m=1:1:win_size
                        lum_wei(n,m) = exp((-((win_mat(n,m)-win_mat(win_size_c,win_size_c))^2))/(2*(lum_sd^2)));
                    end
                end
                lum_wei = floor(lum_wei*4096); %U1Q12
                wei = pos_wei.*lum_wei; %U1Q24
                wei = floor(wei/4096); %U1Q12
                img_filtered(h,w,d) = (sum(sum(win_mat_.*wei))/(sum(sum(wei))));
            else
                img_filtered(h,w,d) = img_src_in(h,w);
            end
        end
    end
figure;imshow(img_filtered);title('bi-lateral filter show');

end

