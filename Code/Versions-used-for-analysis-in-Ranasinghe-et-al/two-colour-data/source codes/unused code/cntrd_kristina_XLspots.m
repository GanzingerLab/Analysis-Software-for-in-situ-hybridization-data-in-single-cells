function [out,spot_boundaries,msk_total,Area,MeanInt4area,Perimeter4area,Perimeter4circle]=cntrd_kristina_XLspots(im,im_original,mx,sz,interactive,bg4ori,t)

% OUT:  a N x 4 array containing, x, y and brightness for each centroid
%           out(:,1) is the x-coordinates
%           out(:,2) is the y-coordinates
%           out(:,3) is the max_brightness
%           out(:,4) is the sqare of the radius of gyration
%
% out=cntrd(im,mx,sz,interactive)
%
% PURPOSE:  calculates the centroid of bright spots to sub-pixel accuracy.
%  Inspired by Grier & Crocker's feature for IDL, but greatly simplified and optimized
%  for matlab
%
% INPUT:
% im: image to process, particle should be bright spots on dark background with little noise
%   ofen an bandpass filtered brightfield image or a nice fluorescent image
%
% mx: locations of local maxima to pixel-level accuracy from pkfnd.m
%
% sz: diamter of the window over which to average to calculate the centroid.
%     should be big enough
%     to capture the whole particle but not so big that it captures others.
%     if initial guess of center (from pkfnd) is far from the centroid, the
%     window will need to be larger than the particle size.  RECCOMMENDED
%     size is the long lengthscale used in bpass plus 2.
%
%
% interactive:  OPTIONAL INPUT set this variable to one and it will show you the image used to calculate
%    each centroid, the pixel-level peak and the centroid
%
% NOTE:
%  - if pkfnd, and cntrd return more then one location per particle then
%  you should try to filter your input more carefully.  If you still get
%  more than one peak for particle, use the optional sz parameter in pkfnd
%  - If you want sub-pixel accuracy, you need to have a lot of pixels in your window (sz>>1).
%    To check for pixel bias, plot a histogram of the fractional parts of the resulting locations
%  - It is HIGHLY recommended to run in interactive mode to adjust the parameters before you
%    analyze a bunch of images.
%
% OUTPUT:  a N x 4 array containing, x, y and brightness for each feature
%           out(:,1) is the x-coordinates
%           out(:,2) is the y-coordinates
%           out(:,3) is the max_brightness
%           out(:,4) is the sqare of the radius of gyration
%
% CREATED: Eric R. Dufresne, Yale University, Feb 4 2005
%  5/2005 inputs diamter instead of radius
%  Modifications:
%  D.B. (6/05) Added code from imdist/dist to make this stand alone.
%  ERD (6/05) Increased frame of reject locations around edge to 1.5*sz
%  ERD 6/2005  By popular demand, 1. altered input to be formatted in x,y
%  space instead of row, column space  2. added forth column of output,
%  rg^2
%  ERD 8/05  Outputs had been shifted by [0.5,0.5] pixels.  No more!
%  ERD 8/24/05  Woops!  That last one was a red herring.  The real problem
%  is the "ringing" from the output of bpass.  I fixed bpass (see note),
%  and no longer need this kludge.  Also, made it quite nice if mx=[];
%  ERD 6/06  Added size and brightness output ot interactive mode.  Also
%   fixed bug in calculation of rg^2
%  JWM 6/07  Small corrections to documentation


% if nargin==3
%    interactive=0;
% end

% if sz/2 == floor(sz/2)
% warning('sz must be odd, like bpass');
% end
%
% if isempty(mx)
%     warning('there were no positions inputted into cntrd. check your pkfnd theshold')
%     out=[];
%     return;
% end

r=(sz+1)/2;
%create mask - window around trial location over which to calculate the centroid
m = 2*r;
x = 0:(m-1) ;
cent = (m-1)/2;
x2 = (x-cent).^2;
dst=zeros(m,m);
for i=1:m
    dst(i,:)=sqrt((i-1-cent)^2+x2);
end


ind=find(dst < r);

msk=zeros([2*r,2*r]);
msk(ind)=1.0;
%msk=circshift(msk,[-r,-r]);

dst2=msk.*(dst.^2);
ndst2=sum(sum(dst2));

[nr,nc]=size(im);
%remove all potential locations within distance sz from edges of image
ind=find(mx(:,2) > 1.5*sz & mx(:,2) < nr-1.5*sz);
mx=mx(ind,:);
ind=find(mx(:,1) > 1.5*sz & mx(:,1) < nc-1.5*sz);
mx=mx(ind,:);

[nmx,crap] = size(mx);

%inside of the window, assign an x and y coordinate for each pixel
xl=zeros(2*r,2*r);
for i=1:2*r
    xl(i,:)=(1:2*r);
end
yl=xl';

pts=[];
%loop through all of the candidate positions
if t == 1
figure
imagesc(im_original); colormap 'Hot'; hold on;
end
for i=1:nmx
    %create a small working array around each candidate location, and apply the window function
    tmp=msk.*im_original((mx(i,2)-r+1:mx(i,2)+r),(mx(i,1)-r+1:mx(i,1)+r));
    %calculate the total brightness
    norm=sum(sum(tmp));
    %calculate the maximum brightness
    max_brightness=max(max(tmp));
    %calculate the weigthed average x location
    xavg=sum(sum(tmp.*xl))./norm;
    %calculate the weighted average y location
    yavg=sum(sum(tmp.*yl))./norm;
    %calculate the radius of gyration^2
    %rg=(sum(sum(tmp.*dst2))/ndst2);
    %rg=(sum(sum(tmp.*dst2))/norm);
    
    %concatenate it up
    pts=[pts,[mx(i,1)+xavg-r,mx(i,2)+yavg-r,max_brightness-bg4ori,0]'];
    
    %OPTIONAL plot things up if you're in interactive mode
    %if interactive==1
    
   if t == 1 
    plot(mx(i,1)+xavg-r,mx(i,2)+yavg-r,'x')
    plot(mx(i,1)+xavg-r,mx(i,2)+yavg-r,'o')
    text(mx(i,1)+xavg-r,mx(i,2)+yavg-r,strcat('\leftarrow',num2str(i)),...
        'HorizontalAlignment','left','color','w')
    %plot(r,r,'.')
    
    %title(['brightness ',num2str(norm),' size ',num2str(sqrt(rg))])
    end
    
    
end
hold off;
out=pts';

%create mask_total with new coordinates which defines the areas in which objects have been found
[M,N]=size(im);
msk_total=ones(M,N);
for i=1:nmx
    [x_cor_back]=round(out(i,2))-5;
    [y_cor_back]=round(out(i,1))-5;
    clear tmp*
    tmp4mask=double(im_original((x_cor_back:x_cor_back+10),(y_cor_back:y_cor_back+10)));
    x = -5:5;
    y = x;
    [X Y] = meshgrid(x,y);
    radius=(out(i,4));
    tmp4mask(X.^2+Y.^2<radius^2)=10;
    [x1,y1]=find(tmp4mask==10);
    x1=x1+x_cor_back-1;
    y1=y1+y_cor_back-1;
    msk_total(x1,y1)=-1;
end
%figure,imagesc(im)
%figure,imagesc(msk_total)




%calculate spot intensity and background intensity of raw data
%use mask for spot (6x6) detection


%im_original_zero=double(im_original).*msk_total;
spot_boundaries = cell(nmx,3);
Area = ones(nmx,1);
MeanInt4area = ones(nmx,1);
Perimeter4area = ones(nmx,1);
Perimeter4circle = ones(nmx,1);

for i=1:nmx
    count=0;
    asc = 3;
    asi = 6;
    la = 0;
    
    while la == 0
        [x_cor]=round(out(i,2))-asc;
        [y_cor]=round(out(i,1))-asc;
        
        if x_cor > 0 && y_cor > 0
            
            clear tmp* rim*
            tmp=double(im_original((x_cor:x_cor+asi),(y_cor:y_cor+asi)));
            
            %correct for background - this does not take any contributions from
            %surrounding fluorophores into account!
            
            tmp = tmp - bg4ori;
%            figure
%            imagesc(tmp)
%            pause
            
            % create binary spot image by thresholding it to Imax/2
            Imax = max(max(tmp));
            for ii=1:asi+1
                for iii=1:asi+1
                    if tmp(ii,iii) > Imax/2
                        tmp2(ii,iii) = 1;
                    else
                        tmp2(ii,iii) = 0;
                    end
                end
            end
            
             
    %        imagesc(tmp2);
   %         pause
            
            % check whether window size is appropiate for spot size and change
            % accordingly
            
            rim(1,:) = tmp2(asi+1,:);
            rim(2,:) = tmp2(1,:);
            rim2(1,:) = tmp2(2:end-1,1)';
            rim2(2,:) = tmp2(2:end-1,asi+1)';
            
            if sum(sum(rim)) + sum(sum(rim2)) <=(((asi+1)*4)-4)/3
                la = 1;
            else
                count = count+1;
                asc = asc+count;
                asi = asi+(count*2);
            end
        end
    end
    
    % trace spots and get area, mean intensity and the Extrema as a measure
    % for spot shape
    
    [B,L,N] = bwboundaries(tmp2);
    stats = regionprops(L,tmp,'Area','MeanIntensity','Perimeter');
    allAreas = ones(1,N);
    for k =1:N,
        allAreas(k) = stats(k).Area;
    end
    
    [~,num4maxarea] = max(allAreas);
    spot_boundaries{i,1} = B;
    spot_boundaries{i,2} = L;
    spot_boundaries{i,3} = stats(num4maxarea);
    
    Area(i) = stats(num4maxarea).Area;
    MeanInt4area(i) = stats(num4maxarea).MeanIntensity;
    out(i,4) = stats(num4maxarea).MeanIntensity;
    Perimeter4area(i) = stats(num4maxarea).Perimeter;
    Perimeter4circle(i) = 2*sqrt(pi*Area(i));
    
    
%    plot regions and their number (taken from matlab help):
if t == 1
    figure
    imagesc(tmp2); hold on;
    colors=['b' 'g' 'r' 'c' 'm' 'y'];
    for k=1:length(B),
        boundary = B{k};
        cidx = mod(k,length(colors))+1;
        plot(boundary(:,2), boundary(:,1),colors(cidx),'LineWidth',2);
        %randomize text position for better visibility
        rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
        col = boundary(rndRow,2); row = boundary(rndRow,1);
        h = text(col+1, row-1, num2str(L(row,col)));
        set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');
    end
    
    hold off; 
   
end
end

%discard spots for further intensity analysis whose shape is too irregular
 peri_ratio = Perimeter4area ./Perimeter4circle;
 out(find(peri_ratio>1.5),:) = [];













