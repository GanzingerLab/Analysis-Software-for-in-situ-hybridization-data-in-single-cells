%this function filters the image and applys SNR threshold to decide which
%spots represent real particles

function [SNR_threshold,c_peaks_threshold,Gauss_param,Gaussian_param_threshold,SNR_Gauss_threshold,filtered_image,d_peaks,c_peaks,SNR_Gauss,output,failedfits]=automatic_detection_rcp(image,dye,parameters,save_dir,type)

global n
%5 parameters that determine detection
p_mean_in_spot=parameters.mean_in_spot;
p_convergence=parameters.convergence;
p_skewness=parameters.skewness;
p_size=parameters.size;
p_SNR=parameters.SNR;
inithreshold=parameters.initialthreshold;
if strcmp(type,'b') == 1;
    inithreshold = parameters.initialthresholdblue;
end
pkfnd_sz = parameters.pkfnd_sz;
cntrd_sz = parameters.cntrd_sz;


%apply bpass
filtered_image = bpass(image,parameters.lnoise,parameters.lobject);
% filtered_image = normalise_image(filtered_image);

% get background value to define threshold
region4background = 20;
temp4Background = [filtered_image(1:region4background, :); filtered_image(size(filtered_image, 1)-region4background:size(filtered_image, 1), :)];
Background = temp4Background(find(temp4Background>0));
median4BN = median(reshape(Background, numel(Background), 1));
iqr4BN = iqr(reshape(Background, numel(Background), 1));


Background2 = Background(find(Background<median4BN));
%Background2 = Background(find(Background<(median4BN+(2*iqr4BN))));


std4BN2 = std(reshape(Background2, numel(Background2), 1));
mean4BN2 = mean(reshape(Background2, numel(Background2), 1));
threshold = mean4BN2 + inithreshold*std4BN2;

%find centroid
d_peaks=pkfnd(filtered_image, threshold, pkfnd_sz);
if size(d_peaks,1)>0
    %here the first argument defines the image to which cntrd is applied and should always be the filtered image
    %the second argument of cntrd_laura defines the image for which the SNR
    %is calculated, if its the raw data, the SNR of the raw data is
    %calculated
    
    [c_peaks,SNR,~]=cntrd_rcp(filtered_image,filtered_image,d_peaks, cntrd_sz, 0);
    
    %     %apply SNR threshold before Gauss Fitting
    %     SNR_threshold=zeros(length(SNR),5);
    %     c_peaks_threshold=zeros(length(SNR),4);
    if size(c_peaks,1)>0
        
                    std_bg=mean(SNR(:,4));
                    bg=mean(SNR(:,3));
                    
                jj=1;
                for j=1:size(SNR,1)
                    
                    maxint=SNR(j,1);
                    
                    if maxint > bg+parameters.cntrd_threshold*std_bg
                        SNR_threshold(jj,:)=SNR(j,:);
                        c_peaks_threshold(jj,:)=c_peaks(j,:);
                        jj=jj+1;
                    end
                end
                SNR_threshold = SNR_threshold(1:jj-1,:);
                c_peaks_threshold = c_peaks_threshold(1:jj-1,:);
         plot_ellipse_on_image_cpeaks(filtered_image,c_peaks_threshold,SNR_threshold);
         saveas(gcf,strcat(save_dir,num2str(n),'_postcntrd_',type,'.tif'), 'tif')
           
     %  SNR_threshold = SNR;
     %  c_peaks_threshold = c_peaks;
   %    size(c_peaks,1) 
    %   size(c_peaks_threshold,1)

        
        %Gauss-Fitting for all spots in c_peaks_threshold
        %filter image differently for Gauss fit
        filtered_image_Gauss = bpass(image,parameters.lnoiseg,parameters.lobjectg);
        
        [Gauss_param,SNR_Gauss,output,failedfits]=post_cntrd_Gauss_rcp_newfit(filtered_image_Gauss,image,dye,c_peaks_threshold,parameters);
        plot_ellipse_on_image(filtered_image,Gauss_param,SNR_Gauss);
        saveas(gcf,strcat(save_dir,num2str(n),'_postGaussFit_',type,'.tif'), 'tif')
%        size(SNR_Gauss)
%        pause
%         SNR_Gauss_threshold = SNR_Gauss;
%        Gaussian_param_threshold = Gaussian_param;
%         
        %Gauss_param contain
        % [ x y amplitude s_x s_y ratio_ellipse fval exitflag area_ellipse]
        if size(Gauss_param)>0
%            apply 4 param thresholds with Gaussian Fitting
            SNR_Gauss_threshold=zeros(size(SNR_Gauss,1),7);
            Gaussian_param_threshold=zeros(size(SNR_Gauss,1),14);
            jj=1;
            for j=1:size(Gauss_param,1)
                p1=SNR_Gauss(j,5);
                p2=Gauss_param(j,8);
                p3=Gauss_param(j,6);
                p4=Gauss_param(j,9);
                p5=SNR_Gauss(j,1);
                p6=Gauss_param(j,4);
                p7=Gauss_param(j,5);
                %p1 > p_SNR &&
                if  p2 == p_convergence && p5 > p_mean_in_spot && p3 < p_skewness && p6 > p_size && p7 > p_size  && p6 < parameters.maxsizercp && p7 < parameters.maxsizercp
                    SNR_Gauss_threshold(jj,:)=SNR_Gauss(j,:);
                    Gaussian_param_threshold(jj,:)=Gauss_param(j,:);
                    jj=jj+1;
                end
            end
            SNR_Gauss_threshold = SNR_Gauss_threshold(1:jj-1,:);
            Gaussian_param_threshold = Gaussian_param_threshold(1:jj-1,:);
            
    % optional plot of SNR on images
            plot_ellipse_on_image(filtered_image,Gaussian_param_threshold,SNR_Gauss_threshold);
   % pause
            saveas(gcf,strcat(save_dir,num2str(n),'_final_',type,'.tif'), 'tif')
            
         
            close all
            
            
        else
            SNR_threshold = [];
            c_peaks_threshold = [];
            Gauss_param  = [];
            Gaussian_param_threshold = [];
            SNR_Gauss_threshold = [];
            c_peaks = [];
        end
    else
        c_peaks_threshold = [];
        SNR_threshold = [];
        
        Gauss_param  = [];
        SNR_Gauss = [];
        Gaussian_param_threshold = [];
        SNR_Gauss_threshold = [];
        
    end
    
else
    c_peaks = [];
    SNR_threshold = [];
    c_peaks_threshold = [];
    
    Gauss_param  = [];
    SNR_Gauss = [];
    Gaussian_param_threshold = [];
    SNR_Gauss_threshold = [];
    
end
end
