function [Results, xyaSNRma, Gaussian_param_threshold,SNR_Gauss_threshold,Gauss_param,c_peaks_threshold,output,failedfits] = spotdetection_rcp(image,dye,parameters,fig_name,type)


[~,~,T] = size(image);


for t=1:T,
    im=image(:,:,t);
    
    
    [SNR_threshold,c_peaks_threshold,Gauss_param,Gaussian_param_threshold,SNR_Gauss_threshold,~,~,~,~,output,failedfits]=automatic_detection_rcp(im,dye,parameters,fig_name,type);
    
    if isempty(Gaussian_param_threshold),                         %no spots are found
        Results.mu = [];
        Results.amplitude = eps;
        xyaSNRma = [];
    else
        Results.mu = Gaussian_param_threshold(:, 2:-1:1);      %This gives peak positions (x,y) --> (y,x)
        Results.amplitude = Gaussian_param_threshold(:,3);
        Results.SNR = SNR_Gauss_threshold(:,5);                %SNR of spot
        Results.mean_amplitude = SNR_Gauss_threshold(:,1);     %mean brigthness of spot
        Results.amplitude_back = SNR_Gauss_threshold(:,6);
        %xyaSNRma contains: x, y, fitted amplitude, SNR, mean amplitude background
        % corrected, area of 2D Gauss, dye intensity for illumination
        % correction, window x, window y, R2 gauss fit, b/a
    % xyaSNRma = [Gaussian_param_threshold(:, 2:-1:1),Gaussian_param_threshold(:, 3),SNR_Gauss_threshold(:,5),SNR_Gauss_threshold(:,6),Gaussian_param_threshold(:,9),SNR_Gauss_threshold(:,7),Gaussian_param_threshold(:, 10),Gaussian_param_threshold(:, 11),Gaussian_param_threshold(:, 14),Gaussian_param_threshold(:,13)];
    xyaSNRma = [Gaussian_param_threshold(:, 2:-1:1),Gaussian_param_threshold(:, 3),SNR_Gauss_threshold(:,5),SNR_Gauss_threshold(:,6),Gaussian_param_threshold(:,9),SNR_Gauss_threshold(:,7),Gaussian_param_threshold(:, 10),Gaussian_param_threshold(:, 11),Gaussian_param_threshold(:, 14)];
    end
    
    
end

