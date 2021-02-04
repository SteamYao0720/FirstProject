

%% �幤���ռ�
clear,clc;

%% ͼ��·������ȡͼ��
path = 'C:\Users\Administrator\Pictures\lena.jpg'; % ͼ��·��
I = imread(path);                                  % image size 200x200x3

%% ͼ���С�仯
I = imresize(I,[100,100], 'nearest');  % image size 100x100x3
[m, n, h] = size(I);        % ��ȡͼ��size
if h == 3
   I = rgb2gray(I);         % ��ɫͼ��ҶȻ�
end

lbpI = lbp_equivalent(I);   % �ȼ�ģʽ

%% ����lbp������ֱ��ͼ��������
width = 20;     % �ֿ�ָ���
height = 20;    % �ֿ�ָ�߶�
grid_num_x = m / width;     % x����ָ����
grid_num_y = n / height;    % y����ָ����
numPatterns = 59;           % ģʽ������

lbpH_result = zeros(grid_num_x*grid_num_y,...
        numPatterns);   % ��ʼ��lbpH�������������飬grid_num_x*grid_num_y�ָ������numPatternsģʽ������
lbpHRowIndex = 1;       % �±�����

for i = 1:grid_num_x    % �ָ�ͼ�����ֱ��ͼ��һ������
   for j = 1:grid_num_y
       src_cell = lbpI(((i-1)*height+1):i*height, ((j-1)*width+1):j*width);     % ԭʼlbp����ͼ�ָ�����
       hist_cell = getLocalRegionLBP(src_cell, 0, (numPatterns-1));             % lbp����ͼ���ֱ��ͼ����
       lbpH_result(lbpHRowIndex, :) = hist_cell;                                % ��ֱ��ͼ����lbpH����������������
       lbpHRowIndex = lbpHRowIndex + 1;                                         % �±���������
   end
end

lbpH = reshape(lbpH_result', 1, grid_num_x*grid_num_y*numPatterns);              % lbpH��������������תһά����



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

%��Ծ��
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

% lbp��
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

%% ����������lbp����ͼ���ֱ��ͼ 
function histFreq = getLocalRegionLBP(lbpI_cell, minValue, maxValue)
    [mm, nn] = size(lbpI_cell);                             % ��ȡͼ��size
    lbpI_src = reshape(lbpI_cell', 1, mm*nn);               % ��ά����תһά��
    lbpI_src = double(lbpI_src);                            % uint8תdouble���ͣ����ں���ֱ��ͼ����
    bins = maxValue - minValue + 1;                         % ����bin����Ŀ
    [histFreq, histXout] = hist(lbpI_src, bins, minValue:(maxValue+1));              % ֱ��ͼ������ͳ��������������
    binWidth = histXout(2) - histXout(1);                   % bin���
    %histFreq = histFreq / binWidth / sum(histFreq);         % ��һ��ֱ��ͼͳ��ֵ
    
    a = histFreq.*histFreq;
    b = sum(a);
    histFreq = bsxfun(@rdivide, histFreq, sqrt(sum(histFreq.*histFreq)));   % ��L2��׼��ÿ��lbp��ֱ��ͼ
    
%     histFreq = histFreq / norm(histFreq);         % ��һ��ֱ��ͼͳ��ֵ
%     figure;
%     bar(histXout, histFreq); % barͼ����
end

