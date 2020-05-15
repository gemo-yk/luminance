function[] = img_hist(gray)
[height, width] = size(gray);
max_val = int64(max(max(gray)));
x = 0:1:max_val;
y = zeros(1, max_val + 1);

for i = 1:1:height
    for j = 1:1:width
        indx = int64(gray(i, j)) + 1;
        y(indx) = y(indx) + 1;
    end
end
figure;bar(x, y);
end