function plot_spots_on_image(image,spots)
        
      [H,W] = size(image);
        %Change figure size and define its position on the screen
        screen_size = get(0,'screensize'); %get screen value
        %position = [0.1516    0.01    2*(W/(H+W))*0.7023    2*(H/(H+W))*0.7910].*[screen_size(3:4) screen_size(3:4)];
        figure,imagesc(image); %set(gcf,'Position',position), 
        colormap('jet');
        axis image
        hold on; %grid off;  %set gcf current figure handle
        %%plot local maxima found by d_peaks on filtered image
        plot(spots(:,1),spots(:,2),'gx'); 
        hold on
        plot_circle(spots(:,1),spots(:,2),spots(:,4)); 
        hold off
   