function [out,out_2,msk_total]=cntrd_rcp(im,im_original,mx,sz,interactive)

% OUT:  a N x 4 array containing, x, y and brightness for each centroid 
%           out(:,1) is the x-coordinates
%           out(:,2) is the y-coordinates
%           out(:,3) is the max_brightness
%           out(:,4) is the sqare of the radius of gyration

% OUT_2:  a N x 5 array containing, mean intensity of spot, std of intensity
% of spot, mean intensity of local background, std of intensity
% of local background,SNR=(spot-back)/(sqrt(std_spot^2+std_back^2));
%           out_2(:,1) is the max intensity of spot
%           out_2(:,2) is the std of intensity of spot
%           out_2(:,3) is the mean intensity of local background
%           out_2(:,4) std of intensity of local background
%           out_2(:,5) SNR=(spot-back)/(sqrt(3*std_back^2));


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


for i=1:nmx
    %create a small working array around each candidate location, and apply the window function
    tmp=msk.*im((mx(i,2)-r+1:mx(i,2)+r),(mx(i,1)-r+1:mx(i,1)+r));
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
    rg=(sum(sum(tmp.*dst2))/norm);

    %concatenate it up
    pts=[pts,[mx(i,1)+xavg-r,mx(i,2)+yavg-r,max_brightness,rg]'];
    
    %OPTIONAL plot things up if you're in interactive mode
    if interactive==1
     imagesc(tmp)
     axis image
     hold on;
     plot(xavg,yavg,'x')
     plot(xavg,yavg,'o')
     plot(r,r,'.')
     hold off
     title(['brightness ',num2str(norm),' size ',num2str(sqrt(rg))])
     pause(1)
    end

    
end
out=pts';

%create mask_total with new coordinates which defines the areas in which objects have been found
[M,N]=size(im);
msk_total=ones(M,N);
for i=1:nmx
    [x_cor_back]=round(out(i,2))-4;
    [y_cor_back]=round(out(i,1))-4;
    clear tmp*
    tmp4mask=double(im_original((x_cor_back:x_cor_back+8),(y_cor_back:y_cor_back+8)));
    x = -4:4;
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



out_2=[];
%calculate spot intensity and background intensity of raw data
%use mask for spot (9x9) and background (15x15) detection
%Use Gauss-Fitting Function and output optim fit-parameters as out_3

im_original_zero=double(im_original).*msk_total;
for i=1:nmx
    [x_cor]=round(out(i,2))-4;
    [y_cor]=round(out(i,1))-4;
    [x_cor_back]=round(out(i,2))-7;
    [y_cor_back]=round(out(i,1))-7;
    
    if x_cor_back > 0 && y_cor_back > 0
    

    %calculate mean spot intensity and standard deviation
    clear tmp*
    tmp=double(im_original((x_cor:x_cor+8),(y_cor:y_cor+8)));
    %select circular region around center of tmp
    x = -4:4;
    y = x;
    [X Y] = meshgrid(x,y);
    radius=(out(i,4));
    
    tmp=tmp(X.^2+Y.^2<radius^2);
    tmp=tmp(tmp>0);
    
    spot_mean=mean(tmp(:));
    spot=max(tmp(:));
    std_spot=std(tmp(:));
    %same for the background
        %same for the background
        %if x_cor_back+14 < N && x_cor_back+14 < M
    tmp_background=im_original_zero((x_cor_back:x_cor_back+14),(y_cor_back:y_cor_back+14));
    tmp_back=tmp_background(tmp_background>0);
        %end
            
    if isempty(tmp_back)==1
      back=0;
      SNR=(spot-back)/0.1;
      std_back=0;
    else
    back=mean(tmp_back);
    std_back=std(tmp_back);
    %SNR (Cheezum 2001)
    %SNR=(spot-back)/(sqrt(std_spot^2+std_back^2));
    %SNR Changed, Problem: STD of a Gaussian-shaped spot is higher than the
    %Noise, because obviously, the variation of the Gaussian Shape from the
    %mean is high, the factor 3 is arbitrary, since it is just a threshold
    %method, it is not so important
    SNR=(spot-back)/(sqrt(std_spot^2+std_back^2));
    end
    else
        spot = 0;
        std_spot = 0;
        back = 0;
        std_back = 0;
        SNR = 0;
    end
        
    %concatenate it up
    out_2=[out_2 ,[spot,std_spot,back,std_back,SNR]'];

end
out_2=out_2';  










    




