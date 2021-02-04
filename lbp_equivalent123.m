

%% 清工作空间
clear,clc;

%% 图像路径及获取图像
path = 'C:\Users\Administrator\Pictures\lena.jpg'; % 图像路径
I = imread(path);                                  % image size 200x200x3

%% 图像大小变化
I = imresize(I,[100,100], 'nearest');  % image size 100x100x3
[m, n, h] = size(I);        % 获取图像size
if h == 3
   I = rgb2gray(I);         % 彩色图像灰度化
end

lbpI = lbp_equivalent(I);   % 等价模式

%% 计算lbp特征的直方图特征向量
width = 20;     % 分块分割宽度
height = 20;    % 分块分割高度
grid_num_x = m / width;     % x方向分割块数
grid_num_y = n / height;    % y方向分割块数
numPatterns = 59;           % 模式种类数

lbpH_result = zeros(grid_num_x*grid_num_y,...
        numPatterns);   % 初始化lbpH特征化向量数组，grid_num_x*grid_num_y分割块数，numPatterns模式种类数
lbpHRowIndex = 1;       % 下标索引

for i = 1:grid_num_x    % 分割图像进行直方图归一化处理
   for j = 1:grid_num_y
       src_cell = lbpI(((i-1)*height+1):i*height, ((j-1)*width+1):j*width);     % 原始lbp特征图分割区域
       hist_cell = getLocalRegionLBP(src_cell, 0, (numPatterns-1));             % lbp特征图像块直方图处理
       lbpH_result(lbpHRowIndex, :) = hist_cell;                                % 将直方图放入lbpH特征化向量数组中
       lbpHRowIndex = lbpHRowIndex + 1;                                         % 下标索引增加
   end
end

lbpH = reshape(lbpH_result', 1, grid_num_x*grid_num_y*numPatterns);              % lbpH特征化向量数组转一维向量



function lbpI = lbp_equivalent(I)
[m n] = size(I);
lbpI = uint8(zeros([m n]));
table = lbp59table();
for i = 2:m-1
    for j = 2:n-1
        neighbor = [I(i-1,j-1) I(i-1,j) I(i-1,j+1) I(i,j+1) I(i+1,j+1) I(i+1,j) I(i+1,j-1) I(i,j-1)] > I(i,j);
        pixel = 0;
        for k = 1:8
            pixel = pixel + neighbor(1,k) * bitshift(1,8-k);
        end
        lbpI(i,j) = uint8(table(pixel+1));
    end
end
end

%跳跃点
function count = getHopcount(i)
i = uint8(i);
bits = zeros([1 8]);
for k=1:8
    bits(k) = mod(i,2);
    i = bitshift(i,-1);
end
bits = bits(end:-1:1);
bits_circ = circshift(bits,[0 1]);
res = xor(bits_circ,bits);
count = sum(res);
end

% lbp表
function table = lbp59table()
table = zeros([1 256]);
temp = 1;
for i=0:255
    if getHopcount(i)<=2
        table(i+1) = temp;
        temp = temp + 1;
    end
end
end

%% 函数：计算lbp特征图像块直方图 
function histFreq = getLocalRegionLBP(lbpI_cell, minValue, maxValue)
    [mm, nn] = size(lbpI_cell);                             % 获取图像size
    lbpI_src = reshape(lbpI_cell', 1, mm*nn);               % 二维数组转一维数
    lbpI_src = double(lbpI_src);                            % uint8转double类型，便于后续直方图处理
    bins = maxValue - minValue + 1;                         % 计算bin的数目
    [histFreq, histXout] = hist(lbpI_src, bins, minValue:(maxValue+1));              % 直方图，返回统计数，数据中心
    binWidth = histXout(2) - histXout(1);                   % bin间隔
    %histFreq = histFreq / binWidth / sum(histFreq);         % 归一化直方图统计值
    
    a = histFreq.*histFreq;
    b = sum(a);
    histFreq = bsxfun(@rdivide, histFreq, sqrt(sum(histFreq.*histFreq)));   % 用L2标准化每个lbp块直方图
    
%     histFreq = histFreq / norm(histFreq);         % 归一化直方图统计值
%     figure;
%     bar(histXout, histFreq); % bar图绘制
end

