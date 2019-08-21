function [region_ROI_inside] = find_ROI(I)

I_bw = I;
I_bw(I~=0) = 1;
L = bwlabel(I_bw,4);
STATS = regionprops(L);
num = length(STATS);

if num~=0
for i = 1: num
    L1 = L;
    L1(L1~=i) = 0;
    L1(L1~=0) = 1;
    region = I.*uint8(L1);
    region_ROI{i,1} = region;
    H{i,1} = imhist(region(region~=0));
    h(i,1) =  length(find(region>200))/length(find(region>0));
end

count = find(h>0&h<0.1);
if isempty(count) == 1
    region_ROI_inside = I;
else
    c = find(h==max(h(count)));
    region_ROI_inside = region_ROI{c,1};
end
end

end