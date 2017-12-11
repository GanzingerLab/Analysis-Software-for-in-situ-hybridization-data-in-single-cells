% PURPOSE: Calculates intensities for dual-colour FISH experiments with
% using wide-field images of single labelled bacteria
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% published in:
% "Single-cell epitranscriptomics using methylation-sensitive hybridization
% probes"
%
% This code can analyse single data sets or a series of datasets. For multiple data
% data sets, the folders containing the individual data sets have to be named with 
% number (e.g. 1) and contain one folder named 0.5 - the data is normalised to this  
% data set.
% Data accepted are single .tiff images with separate images for different
% colours and their name needs to start with a running index (number) to indicate file pairs
% and contain either the letter 'B' or 'R' indicating the channel.
% The letter code for the colour can be changed in function "get_tiffs" line 10 and 11.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% initialisation
clear all;
close all;
addpath('./source codes');

%% open dialogue for manual input of parameters and add general parameters
[parameters] = parameter_setup;
[parameters] = parameter_setup_auto(parameters);

%% ask whether multiple dataset are to be analysed
qstring = 'Run Batch version?';
choice = questdlg(qstring,'Mode of Program',...
    'Yes','No','Yes');
switch choice
    case 'Yes'
        isbatch = 1;
        
        prompt={'path:'};
        defans = {'C:\Users\DataToAnalyse'};     
        info = inputdlg(prompt,'Please enter full path to data directory',1,defans);
        path = info{1};
        
    case 'No'
        isbatch = 0;
    
end

%% prompt for offset values if fixed offset correction is desired
if parameters.offsetcorr == 2
    prompt={'offset (y)'...
        'offset (x)'};
    setup.defans={'-1'...
        '28'};
    info = inputdlg(prompt, 'Fixed offset values:', 1, setup.defans,'on');
    parameters.offset = [str2double(info{1}) str2double(info{2})];
end


%% extract number of folders to be analysed and their individual paths
% (or set number to 1 if single dataset is analysed and prompt for path)
if isbatch == 1
        [folders2analyse,root_directory] = getfolderstoanalyse_vs6(path);
        number_of_samples = length(folders2analyse);
       
   
else
    folders2analyse = 1;
    number_of_samples = 1; %both variables are the same because no 
    % normalisation is required for single sample 
    stacks_directory = uigetdir('');
    %this variable can also be set to a fixed path so it does not require
    %GUI input; e.g. stacks_directory = 'C:\Users\DataToAnalyse';
end

%% initialise variables changing over for loop
global n n2;
glassorcell = 1;
all_bluevector = [];
total_mean=[];
total_stdev = [];
batchsave = [];


%% looping over all datasets to be anlysed  
for n2=1:number_of_samples
    
        
    %% create saving directory for the given dataset and path to current folder
    if iscell(folders2analyse) == 1
        
            stacks_directory = strcat(root_directory,'\',folders2analyse{n2});
            [save_name,fig_name,batchsave]= make_directory_gui(parameters.exp_name,folders2analyse{n2},batchsave,parameters.loc4dir);
            
    else
        
        [save_name,fig_name]= make_directory_gui(parameters.exp_name,cell(1,1),batchsave,parameters.loc4dir);
        
    end
    

    [red_files,blue_files] = get_tiffs(parameters,stacks_directory);
   
    Lstack = length(red_files);
    
    %% calculate offset if GUI was set accordingly; use the mean value derived from previous measurements if calculation fails
    % (separate step from the subsequent image manipulations (extra for loop over all images)
    
    if parameters.offsetcorr == 1
        [parameters,offset_temp,offset_turn_temp] = calculate_offsets(parameters,stacks_directory,red_files,blue_files,Lstack);
    end
    
    
    
    
    %inialise variables before loop
    blue = cell(Lstack,1);
    red = cell(Lstack,1);
    Results_blue = cell(Lstack,1);
    Results_red = cell(Lstack,1);
    xyAI_red = cell(Lstack,1);
    xyAI_blue = cell(Lstack,1);
    start_point_cell = zeros(Lstack,1);
    red_spot_index = ones(Lstack,1)*-1;
    blue_spot_index = ones(Lstack,1)*-1;
    coloc_spots = cell(Lstack,1);
    coloc_pos = cell(Lstack,1);
    all_blueintAND = [];
    all_redintAND = [];
    
  %% looping over the individual images of the dataset n2:
    
    for n = 1:Lstack,
        
        %% read in image data (automatic selection) and correct channel offset if required
        
        if  ~isempty(red_files{n})
            
            % display file index for analysed file in the command line
            disp(strcat('Analysing File ',num2str(n), ' of ',num2str(Lstack)))
            
            %read in image data from tiff files (single image data)
            [both_colours_red] = read_data(stacks_directory,red_files{n});
            [both_colours_blue] = read_data(stacks_directory,blue_files{n});
            
            nImage = 1;
            
            close all;
            
            % this step crops the image to the region to be analysed - this
            % will probably need to be customised!
            
            [red_temp,~] = select_region_fullchip(both_colours_red,parameters.image_width,nImage);
            [~,blue_temp] = select_region_fullchip(both_colours_blue,parameters.image_width,nImage);
            
            %if there is no offset correction between the two channels, x_start = 15; x_end = 250; y_start = 30; y_end = 480 for all images
            %otherwise, offset correction is applied in this step to obtain
            %the same coordinates in both channels 
            
            [red{n},blue{n},results{n}.x_start3, results{n}.x_end3, results{n}.y_start3, results{n}.y_end3, start_point_cell(n)] = select_region_auto_shiftcorr_optionalBAC(red_temp,blue_temp,nImage,parameters,n);
            %variables "red" and "blue" are cell arrays, cell i contains
            %blue or red image i as a matrix, offset corrected and cropped

            % since the index goes by the index number of the image files, and files may be deleted to bad data 
            % quality, entries can be empty, in this case an empty matrix is added 
            if isempty(red{n})
                
                red_files{n} = [];
                blue_files{n} = [];
            end
            
        end
        
        
        
        %% detect cells in both channels (blue, red) and collect information
        
        if  ~isempty(red_files{n})
 
            if parameters.or == 1
               %generate mask / identify cells from both channels and overlay them ("OR" criterion for cell selection)   
                [mask] = createBinaryMask(red{n},blue{n},parameters);
            
            
            elseif parameters.or == 2
               %generate mask / identify cells from red channel only (signal from blue channel ignored for cell selection) 
                [mask] = createBinaryMaskRedOnly(red{n},blue{n},parameters);
            end
            
            % in both cases ("OR" and "REDONLY"), the following function
            % extracts information for each cell (mask element)
            % xyAI_(blue/red) is 1xLstack cell containing each a 5xi matrix
            % where i is the number of cells identified in the current
            % image n; in the matrix
            % (:,1-2) is the xy position, (:,3) is the area (pixel),(:,4) intensity and (:,5) intensity corrected
            % for local background
            % cells whose areas are below the size threshold are discarded
            % in this step
            
            if parameters.or == 1 || parameters.or == 2 
               
                if parameters.sizethresboolean == 1
                    [xyAI_red{n}]  = extract_int_per_cell_SingleThres(red{n},parameters,fig_name,'r',mask);
                    [xyAI_blue{n}]  = extract_int_per_cell_SingleThres(blue{n},parameters,fig_name,'b',mask);
                else
            % cells whose areas are larger than a second size threshold are also discarded                    
                    [xyAI_red{n}]  = extract_int_per_cell(red{n},parameters,fig_name,'r',mask);
                    [xyAI_blue{n}]  = extract_int_per_cell(blue{n},parameters,fig_name,'b',mask,xyAI_red{n});
               
                end
                
            else
            % generate mask / identify cells from each channel individually and collect data -> at later stage, cells are only 
            % kept if they appear in both channels ("AND" criterion for cell selection) 
            % extract cell information as for OR criterion
            
                if parameters.sizethresboolean == 1
                
                    [xyAI_red{n}]  = extract_int_per_cell_SingleThres(red{n},parameters,fig_name,'r');
                    [xyAI_blue{n}]  = extract_int_per_cell_SingleThres(blue{n},parameters,fig_name,'b');
                else
                    
                    [xyAI_red{n}]  = extract_int_per_cell(red{n},parameters,fig_name,'r');
                    [xyAI_blue{n}]  = extract_int_per_cell(blue{n},parameters,fig_name,'b'); 
                end
            end
         
            
        %% COLOCALISATION - find cells that are present in both channels:
            
            % get number of cells detected for each channel, waste is the 
            % dimension in which the coordinates etc per spot are listed (always 5)
            
            resred = xyAI_red{n}(:,1:2);
            resblue = xyAI_blue{n}(:,1:2);
            if isempty(resred)
                number_of_spots{n}.red = 0;
            elseif resred(1,1) ~= 0
                number_of_spots_1 = size(resred);
                number_of_spots{n}.red = number_of_spots_1(1);
            else
                number_of_spots{n}.red = 0;
            end
            if  isempty(resblue)
                number_of_spots{n}.blue = 0;
            elseif resblue(1,1) ~= 0
                number_of_spots_1 = size(resblue);
                number_of_spots{n}.blue = number_of_spots_1(1);
            else
                number_of_spots{n}.blue = 0;
            end
            
            % calculate distances and find colocalised spots, output the
            % total count and the positions of the colocalised spots
            
            if number_of_spots{n}.red ~= 0 && number_of_spots{n}.blue ~= 0
                [coloc_spots{n},coloc_pos{n}] = get_spot_distances(resred,resblue,parameters,number_of_spots{n});
            else
                coloc_spots{n} = ones(parameters.maxD,1)*-1;
                coloc_pos{n} = cell(parameters.maxD,1);
            end
            % collect counted cells for current images in a matrix format
            red_spot_index(n) = number_of_spots{n}.red;
            blue_spot_index(n) = number_of_spots{n}.blue;
            
            % extract intensities for colocalised spots (separate vectors for red and blue) so that every row of
            % the vector corresponds to a specific cell; the background
            % corrected intensity is used as a default
            [redintAND, blueintAND] = int4colocBACS(coloc_pos{n}{parameters.coloc_bin},xyAI_red{n},xyAI_blue{n});
            
            
            % concartenate vectors to create one intensity vector for all
            % images analysed in a sample
            
            all_blueintAND = [all_blueintAND;blueintAND];
            all_redintAND = [all_redintAND;redintAND];         
        end
        close all;
    end
    
    
    %% create colocalisation statistics (only interesting for "AND" criterion
   
    [total_coloc_events,coloc_events,coloc_mean,coloc_std,coincidence_blue, coincidence_red] = form_histogram_coloc(coloc_spots,parameters,Lstack,red_spot_index,blue_spot_index);
    
    %save colocalisation statistics in text file if desired
    %csvwrite(strcat(save_name,'_colocalisation_events_total','.dat'),total_coloc_events);
    %csvwrite(strcat(save_name,'_colocalisation_events_individual','.dat'),coloc_events);
    
    plot_histogram(parameters.distance_bin,coloc_mean,coloc_std,'blue',parameters.exp_name,save_name,parameters.maxD);
    plot_histogram(parameters.distance_bin,coloc_mean,coloc_std,'red',parameters.exp_name,save_name,parameters.maxD);
    
    save_histogram(save_name,parameters.distance_bin,coloc_mean,coloc_std,'blue')
    save_histogram(save_name,parameters.distance_bin,coloc_mean,coloc_std,'red')
    
    %% create histograms of all intensities for the individual channels
    if sum(total_coloc_events) ~= 0
        
        plot_save_histogram_int(all_blueintAND,'blue',parameters.exp_name,save_name);
  %      plot_save_histogram_int(all_redintAND,'red',parameters.exp_name,save_name);
        
    end
    
    %save workspace for this sample:
    save(strcat(save_name,'workspace.mat'));
    

    
    
%% create and plot histgrams of the ratios of the two channels (red/red+blue)
    % information is saved both in matrices / variables (fit results) and
    % plots (.fig files)
    
        if parameters.or == 0
            [ampli_gof{n2},ampli_fitres{n2},lnZ_AND_ampli{n2}, all_red_ampli_collected{n2},all_blue_ampli_collected{n2},lnZ_hist_counts{n2},lnZ_hist_freq{n2}] = plot_ratio_histgrams(all_blueintAND,all_redintAND,'lnZ',' not norm',save_name,'AND');
        else
            [ampli_gof{n2},ampli_fitres{n2},lnZ_AND_ampli{n2}, all_red_ampli_collected{n2},all_blue_ampli_collected{n2},lnZ_hist_counts{n2},lnZ_hist_freq{n2}] = plot_ratio_histgrams(all_blueintAND,all_redintAND,'lnZ',' not norm',save_name,'OR');
        end
        
    % ...apply sum thresholding to non-normalised histogram (if set in the GUI):
    %    [gof_SUM{n2},fitres_SUM{n2},lnZ_SUM{n2}] = plot_ratio_histgrams_sum(all_blueintAND,all_redintAND,'lnZ',' not norm',save_name,parameters.sumthres,'SUM');
        
        
    
    
    
    %% save some information extracted from the data in the form of text files:    
    
    plot_save_histogram_int( all_red_ampli_collected{n2},'red_after',parameters.exp_name,save_name);
        
    dlmwrite(strcat(save_name,'_intensities_for_blue.txt'),all_blue_ampli_collected{n2});
    dlmwrite(strcat(save_name,'_intensities_for_red.txt'),all_red_ampli_collected{n2});
    %dlmwrite(strcat(save_name,'_sum_LnZ.txt'),lnZ_SUM{n2});
    dlmwrite(strcat(save_name,'_numbers_of_red_spots.txt'),red_spot_index);
    dlmwrite(strcat(save_name,'_numbers_of_blue_spots.txt'),blue_spot_index);
    
   % collect information for sample if multiple samples are analysed to be able 
   % to access the information easily for all samples in one variable/file
   
    if isbatch == 1
        collect_n(n2) = total_coloc_events(parameters.coloc_bin);
        collect_frames(n2) = Lstack;
        collect_n_red(n2) = sum(red_spot_index);
        collect_n_blue(n2) = sum(blue_spot_index);
        
        label{n2} = folders2analyse{n2};
             
    end
    
    %make scatterplot of red versus blue intensities - some entries might
    %be discarded when the ratio is calculated so the intensities plotted here are only 
    %that are part of the ratio histograms
    
    figure;scatterhist(all_red_ampli_collected{n2},all_blue_ampli_collected{n2});
     xlabel('red');
     ylabel('green');
    saveas(gcf,strcat(save_name,'_Scatterplot','.fig'), 'fig');
        
end

%% Scatter plot of means and std from Gaussian fits across samples in batch mode
% comparison of the distributions obtained in different experiments and
% statistical assessment whether they can be assumed to be different
%
% export of ratios (log(ratios)) and amplitudes collected in an excel
% sheet, grouped by sample

if isbatch == 1 
    [all_means_ampli,all_std_ampli] = collect_fit_parameters('_fitparameters',ampli_gof,ampli_fitres,folders2analyse,'amplitude',save_name);
    %[all_means_sum,all_std_sum] = collect_fit_parameters('_fitparameters_sum',gof_SUM,fitres_SUM,folders2analyse,'sum',save_name);
    
    save_more_parameters(folders2analyse,save_name,collect_n, collect_frames, collect_n_blue, collect_n_red);  
    excel_export_bacs2(folders2analyse,lnZ_AND_ampli,all_red_ampli_collected,all_blue_ampli_collected,lnZ_hist_counts,lnZ_hist_freq,save_name);
end

%save the workspace again after all samples have been analysed and batch
%calculations are done
save(strcat(save_name,'workspace.mat'));
