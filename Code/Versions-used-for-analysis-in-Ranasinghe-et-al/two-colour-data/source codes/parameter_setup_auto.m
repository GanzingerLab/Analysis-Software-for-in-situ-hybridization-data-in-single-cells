function [parameters] = parameter_setup_auto(parameters)

switch parameters.objective
    case 1 %'20x NA0.5'     
        parameters.pixel_size = 321;
        parameters.cntrd_threshold = 5;
        parameters.lobjectg = 8;
        parameters.lnoiseg = 0.5;
        parameters.sigma0 = 1.36;
        parameters.emptypx = 50;
        %parameters.sizethres = 10;
        %parameters.sizethres_upperlimit = 100;
    case 2 %'20x NA0.75'
        parameters.pixel_size = 321;
        parameters.cntrd_threshold = 5;
        parameters.lobjectg = 7;
        parameters.lnoiseg = 0.5;
        parameters.sigma0 = 0.91;
        parameters.emptypx = 50;
        %parameters.sizethres = 10;
    case 3 %'40x NA0.95'
        parameters.pixel_size = 161;
        parameters.cntrd_threshold = 5;
        parameters.lobjectg = 11;
        parameters.lnoiseg = 0.5;
        parameters.sigma0 = 1.43;
        parameters.emptypx = 200;
        %parameters.sizethres = 50
        %parameters.sizethres_upperlimit = 500;
    case 4 %'60x NA0.95'
        parameters.pixel_size = 107;
        parameters.cntrd_threshold = 5;
        parameters.lobjectg = 15;
        parameters.lnoiseg = 0.5;
        parameters.sigma0 = 2.15;
        parameters.emptypx = 450;
        %parameters.sizethres = 75;
    case 5 %'60x NA1.4'
        parameters.pixel_size = 107;
        parameters.cntrd_threshold = 5;
        parameters.lobjectg = 14;
        parameters.lnoiseg = 0.5;
        parameters.sigma0 = 1.46;
        parameters.emptypx = 450;
        %parameters.sizethres = 90;
        %parameters.sizethres_upperlimit = 500;
end   


parameters.initialthreshold = 6;
parameters.initialthresholdblue = 5;

parameters.fret = 0;
parameters.image_width = 256;
parameters.file_type= '.tif';
parameters.lobject = 9;  %lobject defined in parameter_setup! (parameter for bpass function to cancel out the long wavelength noise)
parameters.lnoise = 1;   %defines parameter for bpass function to cancel out the short wavelength noise

parameters.distance_bin = 100;  %bin (dist) of colocalisation histogram
parameters.maxD = 15;           %number of bins of colocalisation histogram
parameters.coloc_criterion =3*parameters.pixel_size;
parameters.coloc_bin = round(parameters.coloc_criterion/parameters.distance_bin);

%approx. size of spots to be detected (uneven number required, center pixel
%+ r) for intial spot detection and centroid fit
parameters.pkfnd_sz = ceil(963/parameters.pixel_size);
parameters.cntrd_sz = ceil(963/parameters.pixel_size);

%Parameters for Gauss Fit
parameters.mean_in_spot=0.0;
parameters.convergence=3;     
parameters.skewness=1.3;
parameters.size=ceil(214/parameters.pixel_size); 
%parameters.size=0; 
%parameters.maxsizercp=ceil(749/parameters.pixel_size);
parameters.maxsizercp=1766/parameters.pixel_size;

end