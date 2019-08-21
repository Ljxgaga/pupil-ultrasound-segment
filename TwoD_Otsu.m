function XX = TwoD_Otsu(XXX)
%% 2-D Otsu

[fx,fy] = gradient(XXX);
Gra = sqrt(fx.^2+fy.^2);

Histogram = zeros(256,256);
[m,n] = size(XXX);

filter = fspecial('average',[3,3]);
Img_aver = imfilter(XXX,filter);


for i = 1:m
    for j = 1:n
        value = round(Img_aver(i,j))+1;
        grad = round(Gra(i,j))+1;
        Histogram(value,grad) = Histogram(value,grad) + 1;
    end
end

Histogram = Histogram ./ (m*n);

Fgi = 0.0;    %前景区域均值向量i分量
Fgj = 0.0;    %前景区域均值向量j分量
Bgi = 0.0;    %背景区域均值向量i分量
Bgj = 0.0;    %背景区域均值向量j分量
Pai = 0.0;    %全局均值向量i分量 panorama(全景)
Paj = 0.0;    %全局均值向量j分量
w0 = 0.0;     %前景区域联合概率密度
w1 = 0.0;     %背景区域联合概率密度
num1 = 0.0;   %遍历过程中前景区i分量的值
num2 = 0.0;   %遍历过程中前景区j分量的值
num3 = 0.0;   %遍历过程中背景区i分量的值
num4 = 0.0;   %遍历过程中背景区j分量的值
Threshold_s = 0; %阈值s
Threshold_t = 0; %阈值t
temp = 0.0;   %存储矩阵迹的最大值


for i = 1:256
    for j = 1:256
        Pai = Pai + i*Histogram(i,j);   %全局均值向量i分量计算
        Paj = Paj + j*Histogram(i,j);   %全局均值向量j分量计算
        
        w0 = w0 + Histogram(i,j);        %前景的概率
        num1 = num1 + i*Histogram(i,j);    %遍历过程中前景区i分量的值
        num2 = num2 + j*Histogram(i,j);    %遍历过程中前景区j分量的值
        
        w1 = 1 - w0;                  %背景的概率
        num3 = Pai - num1;            %遍历过程中背景区i分量的值
        num4 = Paj - num2;            %遍历过程中背景区j分量的值
        
        Fgi = num1 / w0;
        Fgj = num2 / w1;
        Bgi = num3 / w0;
        Bgj = num4 / w1;
        TrMax = ((w0*Pai - num1)*(w0*Pai - num1) + (w0*Paj - num2)*(w0*Paj - num2)) / (w0*w1);
        if (TrMax > temp)
            temp = TrMax;
            Threshold_s = i;
            Threshold_t = j;
        end
        
        T = Threshold_s;
        
    end
end

    xx = XXX;
     xx(xx>T) = 0;
     xx(xx~=0) = 1;
     
     XX = imfill(xx);
     
end