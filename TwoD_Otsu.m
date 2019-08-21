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

Fgi = 0.0;    %ǰ�������ֵ����i����
Fgj = 0.0;    %ǰ�������ֵ����j����
Bgi = 0.0;    %���������ֵ����i����
Bgj = 0.0;    %���������ֵ����j����
Pai = 0.0;    %ȫ�־�ֵ����i���� panorama(ȫ��)
Paj = 0.0;    %ȫ�־�ֵ����j����
w0 = 0.0;     %ǰ���������ϸ����ܶ�
w1 = 0.0;     %�����������ϸ����ܶ�
num1 = 0.0;   %����������ǰ����i������ֵ
num2 = 0.0;   %����������ǰ����j������ֵ
num3 = 0.0;   %���������б�����i������ֵ
num4 = 0.0;   %���������б�����j������ֵ
Threshold_s = 0; %��ֵs
Threshold_t = 0; %��ֵt
temp = 0.0;   %�洢���󼣵����ֵ


for i = 1:256
    for j = 1:256
        Pai = Pai + i*Histogram(i,j);   %ȫ�־�ֵ����i��������
        Paj = Paj + j*Histogram(i,j);   %ȫ�־�ֵ����j��������
        
        w0 = w0 + Histogram(i,j);        %ǰ���ĸ���
        num1 = num1 + i*Histogram(i,j);    %����������ǰ����i������ֵ
        num2 = num2 + j*Histogram(i,j);    %����������ǰ����j������ֵ
        
        w1 = 1 - w0;                  %�����ĸ���
        num3 = Pai - num1;            %���������б�����i������ֵ
        num4 = Paj - num2;            %���������б�����j������ֵ
        
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