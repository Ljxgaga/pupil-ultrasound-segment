function varargout = gui_0(varargin)
% GUI_0 MATLAB code for gui_0.fig
%      GUI_0, by itself, creates a new GUI_0 or raises the existing
%      singleton*.
%
%      H = GUI_0 returns the handle to a new GUI_0 or the handle to
%      the existing singleton*.
%
%      GUI_0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_0.M with the given input arguments.
%
%      GUI_0('Property','Value',...) creates a new GUI_0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_0

% Last Modified by GUIDE v2.5 04-Jul-2019 13:42:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_0_OpeningFcn, ...
    'gui_OutputFcn',  @gui_0_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before gui_0 is made visible.
function gui_0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_0 (see VARARGIN)

% Choose default command line output for gui_0
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes gui_0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_0_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uigetfile('.bmp','选择测试图像');
pathfile=fullfile(pathname, filename);  %获得图片路径
M=imread(pathfile);     %将图片读入矩阵
axes(handles.axes1);
imshow(M);    %绘制图片
handles.pathname=pathname;
handles.filename = filename;
guidata(hObject,handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rmdir ('train','s')
mkdir 'train/positive'
mkdir 'train/negative'
pathname_test = handles.pathname;
filename_test = handles.filename;
Path_positive = fullfile(pathname_test,'image\positive\');
img_positive = dir(strcat(Path_positive,'*.bmp'));
for i = 1:length(img_positive);
    name = img_positive(i).name;
    picture = imread([Path_positive,name]);
    picture = imresize(picture,[50,50]);
    judge = ismember(name,{filename_test});
    if judge == 0
        imwrite(picture,[pathname_test,'\train\positive\',img_positive(i).name]);
    end
end
Path_negative = fullfile(pathname_test,'image\negative\');
img_negative = dir(strcat(Path_negative,'*.bmp'));
for i = 1:length(img_negative);
    name = img_negative(i).name;
    picture = imread([Path_negative,name]);
    picture = imresize(picture,[50,50]);
    imwrite(picture,[pathname_test,'\train\negative\',img_negative(i).name]);
end

img_Train = imageDatastore('./train', 'IncludeSubfolders', true, 'labelsource', 'foldernames');
tbl = countEachLabel(img_Train);

image1 = readimage(img_Train,1);
[features, visualization] = extractHOGFeatures(image1,'CellSize',[10 10]);
% f = hog(image1);

numImages = length(img_Train.Files);
featuresTrain = zeros(numImages,size(features,2),'single'); % featuresTrain为单精度
for i = 1:numImages
    imageTrain = readimage(img_Train,i);
    featuresTrain(i,:) = extractHOGFeatures(imageTrain,'CellSize',[10 10]);
end

trainLabels = img_Train.Labels;

classifer = fitcsvm(featuresTrain,trainLabels);
handles.classifer = classifer;
guidata(hObject,handles);
msgbox('Training is finished!');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
classifer = handles.classifer;
pathname_test = handles.pathname;
filename_test = handles.filename;
testImage = imread([pathname_test,filename_test]);

[m,n] = size(testImage);
imax = 1+(m-50)/10; jmax = 1+(n-50)/10;
for i = 1:imax
    for j = 1:jmax
        Block{i,j} = testImage([1+10*(i-1):50+10*(i-1)],[1+10*(j-1):50+10*(j-1)]);
        featureTest{i,j} =  extractHOGFeatures(Block{i,j},'CellSize',[10 10]);
        [predictIndex,score] = predict(classifer,featureTest{i,j});
        if predictIndex == 'negative'
            predict_Test(i,j) = 0;
        else
            predict_Test(i,j) = 1;
        end
        predict_score{i,j} = score;
    end
end
%     scaleTestImage = imresize(testImage,imageSize);
[x,y] = find(predict_Test == 1);
mark = zeros(m,n);
for i = 1:length(x)
    mark([1+10*(x(i)-1):50+10*(x(i)-1)],[1+10*(y(i)-1):50+10*(y(i)-1)]) = 1;
end

img_R = testImage.*uint8(mark);
img_ROI_inside = find_ROI(img_R);
[x1,y1] = find(img_ROI_inside~=0);
img_ROI = testImage(min(x1):max(x1),min(y1):max(y1));
axes(handles.axes2);
imshow(img_ROI);
handles.img_ROI = img_ROI;
guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('This area contains pupil.');


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname_test = handles.pathname;
filename_test = handles.filename;
testImage = imread([pathname_test,filename_test]);
h=imrect(handles.axes1);%鼠标变成十字，用来选取感兴趣区域
pos=getPosition(h);

imCp = imcrop( testImage, pos );
axes(handles.axes2);
imshow(imCp);
handles.img_ROI = imCp;
guidata(hObject,handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = handles.img_ROI;
I = imresize(I,2,'nearest');
[height,width] = size(I);

r = 8;% 滤波半径
a = 2;% 全局方差
b = 0.1;% 局部方差
imgn = bfilt_gray(I,r,a,b); %%双边滤波

f = imgn;
m = 0.5;
g = 1./(1 + (m./((f) + eps)).^2);
XXX = g*255;  %%对比度拉伸

XX = TwoD_Otsu(XXX);

se = strel('disk',15);
XX1 = imerode(XX,se);


[B,L] = bwboundaries(XX1,'noholes');
stats = regionprops(L,'Area','Centroid');
clear roundness
for k = 1:length(B)  % 获取边界坐标'
    
    boundary = B{k};  % 计算周长
    delta_sq = diff(boundary).^2;
    perimeter = sum(sqrt(sum(delta_sq,2)));  % 对标记为K的对象获取面积
    area = stats(k).Area;  % 圆度计算公式4*PI*A/P^2
    metric = 4*pi*area/perimeter^2;  % 结果显示
    roundness(k,:) = [perimeter, area, metric ];
end

count = find(roundness(:,2)>100);
c = find(roundness(count,3)==max(max(roundness(count,3))));
L(L~=count(c)) = 0;
L(L~=0) = 1;


XX2 = imdilate(L,se);
contour = bwperim(XX2);
contour(:,1) = 0;contour(:,width) = 0;contour(1,:) = 0;contour(height,:) = 0;
[x_new,y_new] = find(contour~=0);

y_center = y_new(round(length(y_new)/2));
num = find(y_new==y_center);
d = [];

for i = 1:length(num)
    x = x_new(num(1));
    dif = abs(x_new(num(i)) - x);
    d = [d,dif];
end

l = find(d>10);
lzero = isempty(l);
if lzero == 0
    Img_biaoji_new = createim(I,x_new,y_new);
else
    X = XXX.*XX2;
    f = fcmresult(X);
    contour = bwperim(f);
    [x_con,y_con] = find(contour~=0);
    Img_biaoji_new = createim(I,x_con,y_con);
end

axes(handles.axes3);
imshow(Img_biaoji_new);
