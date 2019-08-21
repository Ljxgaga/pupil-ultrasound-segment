%显示代轮廓的图像。将原图和轮廓叠加为rgb图像，轮廓用绿色表示
function newim = createim( im,x_con,y_con)
newim( :, :, 1 ) = im;
newim( :, :, 3 ) = im;


tempim = im;
for i=1:length(x_con)
tempim( x_con(i),y_con(i) ) = 255;
end


newim( :, :, 2 ) = tempim;


newim = uint8( newim );

end

