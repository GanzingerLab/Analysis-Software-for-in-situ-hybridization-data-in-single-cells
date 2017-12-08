function [n_out]=create_mask_4backgound(image,spots,n)

        [H,W] = size(image);
        for i = 1:length(x)
           x_i=x(i);
           y_i=y(i);
           r_i=r(i)-0.5;
           plot(x_i + r_i*cos(2*pi/40*(0:40)), y_i + r_i*sin(2*pi/40*(0:40)),'r','LineWidth',2);
           hold on
        end
        %Change figure size and define its position on the screen
        screen_size = get(0,'screensize'); %get screen value
        position = [0.1516    0.05    2*(W/(H+W))*0.7023    2*(H/(H+W))*0.7910].*[screen_size(3:4) screen_size(3:4)];
        figure(n),imagesc(image); set(gcf,'Position',position), colormap('gray');hold on; %grid off;  %set gcf current figure handle
        pause(1)
        %%plot local maxima found by d_peaks on filtered image
        plot(spots(:,1),spots(:,2),'gx'); 
        hold on
        plot_circle(spots(:,1),spots(:,2),spots(:,4)); 
        
        n_out=n+1;