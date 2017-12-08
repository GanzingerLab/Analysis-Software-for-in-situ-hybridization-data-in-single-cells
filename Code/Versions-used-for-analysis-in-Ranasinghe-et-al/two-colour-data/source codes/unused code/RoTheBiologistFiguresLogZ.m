function [xyAreaInt] = RoTheBiologistFiguresLogZ(varargin)

global n

I = varargin{1};
parameters = varargin{2};
save_dir = varargin{3};
logZ = varargin{4};

figure(1)
imagesc(I), truesize;
pause

if nargin == 5
    BW =  varargin{5};
else
    
    %create binary image with a threshold suitable to differentiate between
    %bacteria and background (bacteria = 1, bg =0)
    If = bpass(I,0,25);
    
    BW =(If>(mean((If(:))+parameters.binary_thres*std(If(:)))));
end
figure(2)
imagesc(BW), truesize;
pause

% trace objects (bacteria) as continuous regions of 1's in binary image
L = bwlabel(BW);
RGB = label2rgb(L,'jet','w','shuffle');
[B,~] = bwboundaries(BW,'noholes');
figure(3)
imagesc(RGB)
pause

% collect information on these regions
STATS = regionprops(L,I,'Area','MeanIntensity','Centroid','PixelIdxList');

aINT = cat(1, STATS.MeanIntensity);
aAREA = cat(1, STATS.Area);
aPOS = cat(1, STATS.Centroid);

% calculate local bg from region (+/- 3px from the edge of the detected region (bacteria))

for i=1:max(L(:))
    cur_bac = STATS(i).PixelIdxList;
    
    [r, c] = ind2sub(size(BW),cur_bac);
    
    temp_l = [r, c-3];
    temp_r = [r, c+3];
    
    temp_l = temp_l(temp_l(:,2)>0,:);
    temp_l = temp_l(temp_l(:,2)<size(BW,2),:);
    
    temp_r = temp_r(temp_r(:,2)>0,:);
    temp_r = temp_r(temp_r(:,2)<size(BW,2),:);
    
    shiftleft = sub2ind(size(BW),temp_l(:,1),temp_l(:,2));
    shiftright = sub2ind(size(BW),temp_r(:,1),temp_r(:,2));
    
    for ii=1:length(cur_bac)
        shiftleft(shiftleft==cur_bac(ii))=[];
        shiftright(shiftright==cur_bac(ii))=[];
    end
    
    bacBG(i) = mean(I([shiftleft; shiftright]));
end

aINTsubBG = aINT - bacBG';

xyAreaInt = [aPOS aAREA aINT aINTsubBG];
tokeep = find(xyAreaInt(:,3)>parameters.sizethres);
xyAreaInt = xyAreaInt(tokeep,:);


count = 1;
B2 = cell(1,length(tokeep));
 for i=1:length(tokeep)
 B2{count} = B{tokeep(i)};

 count = count +1;
 end
figure(4), imagesc(BW); hold on; truesize; colormap('jet');
colors=['b' 'g' 'r' 'c' 'm' 'y'];

for k=1:length(B2)
    boundary = B2{k};
    cidx = mod(k,length(colors))+1;
    plot(boundary(:,2), boundary(:,1),...
         colors(cidx),'LineWidth',1.5);
    %randomize text position for better visibility
    rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
    col = boundary(rndRow,2); row = boundary(rndRow,1);
    %h = text(col+1, row-1, num2str(L(row,col)));
    h = text(col+5, row-5, num2str(logZ(k)));
    if logZ(k)>-1
    set(h,'Color','magenta',...
        'FontSize',10,'FontWeight','bold');
    else
     set(h,'Color','y',...
        'FontSize',10,'FontWeight','bold');   
    end
end

hold off
pause
%saveas(gcf,strcat(save_dir,num2str(n),'_final_',type,'.tif'), 'tif');
close all
