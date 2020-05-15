function[img, src, hdr_rgb, bayer, suffix, height, width, depth] = file_open(height, width)
[f,p]=uigetfile('*.*','Ñ¡ÔñÍ¼ÏñÎÄ¼þ');
if f
    suffix = strsplit(f, '.');
    suffix = suffix(2);
    if strcmp(suffix, 'hdr')
        hdr_rgb = hdrread(strcat(p,f));
        src = hdr_rgb;
        img = hdr_rgb;
        [height, width, depth] = size(hdr_rgb);
        bayer = zeros(height, width);
    end
end
end