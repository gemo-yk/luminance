function [cliped_num] = clip(max, min, num)
if num >= max
    cliped_num = max;
elseif num < min
    cliped_num = min;
else
    cliped_num = num;
end
end