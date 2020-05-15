function mat_get = mat_gets(img_src_in,h,w,win_size)
win_size_c = ceil(win_size/2);
mat_get = img_src_in(h - win_size_c + 1:h + win_size_c - 1, w - win_size_c + 1:w + win_size_c - 1);

end