function [setup,I_cell,T_cell,save_dir_cell] = main2colourvideo 


addpath('./Automatic deterministic batch tracking source codes 2');

global setup;                   %all variables here are global variables

clc; clear all; close all;

stack_directory = uigetdir();   %choose directory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the stack files for tracking and set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[exp_name,minLength,threshold_level,max_step,file_type,subbg,withvideo,FBS,keyword] = input_parameters;

parameters.exp_name = exp_name;
parameters.minLength = minLength;                      %defines minimal length of tracks
parameters.threshold_level = threshold_level;          %defines threshold level, threshold value is given as
                                                       %mean4BN + threshold_level*std4BN
parameters.max_step = max_step;                        %defines maximal length at which 2 spots are linked
parameters.file_type = file_type;
parameters.subbg = subbg;                              %subtract background
parameters.withvideo = withvideo;
parameters.keyword = keyword;

[stack_files] = get_stacks1(stack_directory,file_type,keyword);

bpass_lobject = 3;  %3
pkfnd_sz = 5;  %5
cntrd_sz = 7;  %7
region4background =30;

parameters.bpass_lobject = bpass_lobject;
parameters.pkfnd_sz = pkfnd_sz;
parameters.cntrd_sz = cntrd_sz;
parameters.region4background = region4background;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for stack_count=1:length(stack_files)   %%%
    

    
    clear Tracks info4Tracks Results newY_cell
    
    counter = strcat('Analysing File ',num2str(stack_count), ' of ',num2str(length(stack_files)))

    fName = stack_files{stack_count};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now we read in the Images and create a directory to save the       %
    % results (save_dir = strcat('Results\',exp_name,'\',directory);)    %
    % I is a 3d matrix, (image_height, image_weight, nImage)             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    [I, setup.directory,save_dir] = getFluorescentImages_batch1(stack_directory,fName,exp_name);

    
%     if randomwalk is required    
%     I = [];
%     I = randomwalk(20,60,100);
%     I=I*100;
    
    
    [H,W,T] = size(I);
    
    %%%average images, if subbg == 1
    if subbg ==1,
        [I_averaged] = average_video(I,H,W,T,favg);
    else
          I_averaged = I;
    end

    setup.M = H;
    setup.N = W;
    setup.K = T;
    setup.fbs=FBS;                                  %FBS for avi video file
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now we gonna find the spots in the different images                %
    % - filter images                                                    %
    % - calculate background to set threshhold value for spot_finder     %
    % - save x, y position, brightness and sigma of the spots in         %
    %   cell 'Results'                                                   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    h=waitbar(0, 'Finding spots...');

    for t=1:T,
        Y = I_averaged(:,:,t);  %notation I_averaged only makes sense when
                                %average subtraction is on
        
        % filter by spatial filter..
        newY = bpass(Y, 1, bpass_lobject);
        newY_cell(:,:,t) = newY;

        
        
        % get background value to define threshold
        temp4Background = [newY(1:region4background, :); newY(size(newY, 1)-region4background:size(newY, 1), :)];
        Background = temp4Background(find(temp4Background>0));
        std4BN = std(reshape(Background, prod(size(Background)), 1));
        mean4BN = mean(reshape(Background, prod(size(Background)), 1));
        setup.threshold = mean4BN + threshold_level*std4BN;
        threshold = setup.threshold;
        d_peaks=pkfnd(newY, threshold, pkfnd_sz);
        c_peaks=cntrd(newY, d_peaks, cntrd_sz, 0);

        if length(c_peaks) == 0,                   %no spots are found
            Results{t}.mu = [1, 1];
            Results{t}.amplitude = eps;
            Results{t}.Sigma = eps;
        else
            Results{t}.mu = c_peaks(:, 2:-1:1);    %This gives peak positions but swaps around the coordinates (x,y) --> (y,x)
            Results{t}.amplitude = c_peaks(:, 3);
            Results{t}.Sigma = c_peaks(:, 4).^2;
        end
        waitbar(t/T, h);
    end


    close(h);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now we gonna link the images                                       %
    % setup contains (height, weight, nImage and threshold value which   %
    % was used for the spot finder)                                      %
    % Output are (n,m) matrixes, where n is the number of spots in the 
    % previous image, m the number of spots in the current image. An entry
    % ~= 0 means, that the 2 respective spots are linked. Each spot in the
    % current image is linked to its nearest neighbor in the previous image 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   
    [fullMap, fullMask] = LinkImages(Results,setup,max_step);
    %Results = [ peak positions (y,x), the amplitude, sigma]
    %max_step defines maximal length at which 2 spots are linked
    %fullMap,fullMask (n,m) matrixes
    %fullMask contains values 0,1
    %fullMap contains distances
    [Tracks, info4Track] = produceTracks(Results, fullMap, fullMask);
         %output, cell Tracks with the spot number in the respective frames
         %info4track.len is length of the track
         %info4track.finishTime(nTrack) defines the frame in which track
         %finishes
    save_tracks(Tracks, info4Track, Results, minLength, save_dir); 
    close all;
        
    I_cell{stack_count}=I;
    T_cell{stack_count}=T;
    save_dir_cell{stack_count}=save_dir;
end

    save_parameters(parameters,setup);