function plot_save_histogram_int(ints,type,exp_name,save_name)

rect_matched = [34 524 560 420];

if strcmp(type,'blue') == 1,
    figure_index =  1;
elseif strcmp(type,'red') == 1,
    figure_index = 2;
elseif strcmp(type,'red_after') == 1,
    figure_index = 3;
else
    figure_index = 4;
end


switch figure_index
    case 1
        figure
        colour = 'b';
        monoint = ints;
        fName = strcat(save_name,'_histogram_int_green.dat');
    case 2
        figure
        colour = 'r';
        monoint = ints;
        fName = strcat(save_name,'_histogram_int_red.dat');

    case 3
         figure
         colour = 'r';
          monoint = ints;
        fName = strcat(save_name,'_histogram_int_red_after.dat');
     case 4
         figure
         colour = 'g';
         monoint = ints;
        fName = strcat(save_name,'_histogram_int_FRET.dat');
end


set(gcf,'position',rect_matched);

x_axis_limit = ceil(max(monoint));
bins = sshist(monoint);
%bar(distances,mean);

if ~isempty(monoint)
[y xout] = hist(monoint,bins);
y2 = y./sum(y);
hold on
bar(xout,y2,colour);
axis([0, x_axis_limit, 0, max(y2)]);
xlabel('Intensity');
ylabel('Frequency');
title(strcat('Oligomer Distribution from Int ',exp_name));


switch figure_index
    case 1
        saveas(gcf, [strcat(save_name,'_histogram_int_green.fig')]);    
    case 2
        saveas(gcf, [strcat(save_name,'_histogram_int_red.fig')]);
    case 3
        saveas(gcf, [strcat(save_name,'_histogram_int_red_after.fig')]);    
    case 4
        saveas(gcf, [strcat(save_name,'_histogram_int_FRET.fig')]);
end



    file_output = fopen(fName,'w');

    for n=1:length(y2),
        fprintf(file_output, '%d\t %f\n',xout(n),y2(n));
    end

    fclose(file_output);
end
