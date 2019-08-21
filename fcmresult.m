function [img_new_dil] = fcmresult(XXX)
 img = double(XXX);
    average = mean(img(img~=0));
    data = img(:);
    [center,U,obj_fcn] = fcm(data,3);
    [~,label] = max(U); %找到所属的类
    %变化到图像的大小
    
    img_new = reshape(label,size(img));
    figure,imshow(img_new,[]);
    
       Value = [];
    for i = 1:3
        img_new_1 = img_new;
        img_new_1(img_new_1~=i) = 0;
        img_new_1(img_new_1~=0) = 1;
        Clustering = uint8(img_new_1).*uint8(XXX);
        ValueMean = mean(Clustering(Clustering~=0));
        Value = [Value;i,ValueMean];
    end
    
    Value = sortrows(Value,2);
    Value_min = Value(1,1);
    img_new_2 = img_new;
        img_new_2(img_new_2~=Value_min) = 0;
        img_new_2(img_new_2~=0) = 1;
        
        se = strel('disk',15);
        img_new_ero = imerode(img_new_2,se);
     
        
         [B,L] = bwboundaries(img_new_ero,'noholes');
    stats = regionprops(L,'Area','Centroid');
%     threshold = 0.94;% 循环处理每个边界，length(B)是闭合图形的个数,即检测到的陶粒对象个数  
    clear roundness
for k = 1:length(B)  % 获取边界坐标'  
    
    boundary = B{k};  % 计算周长  
    delta_sq = diff(boundary).^2;  
    perimeter = sum(sqrt(sum(delta_sq,2)));  % 对标记为K的对象获取面积  
    area = stats(k).Area;  % 圆度计算公式4*PI*A/P^2  
    metric = 4*pi*area/perimeter^2;  % 结果显示  
    roundness(k,:) = [perimeter, area, metric ];

end  
        
    L = bwlabel(img_new_ero);%标记连通区域
    count = find(roundness(:,2)>150);
    c = find(roundness(count,3)==max(max(roundness(count,3))));
    L(L~=count(c)) = 0;
    L(L~=0) = 1;
    img_new_ero = L;
        
    img_new_dil = imdilate(img_new_ero,se);
end