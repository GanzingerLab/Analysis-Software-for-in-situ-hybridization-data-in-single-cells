function plot_save_histogram_int(ints,type,exp_name,save_name)

rect_matched = [34 524 560 420];

if strcmp(type,'blue') == 1,
    figure_index =  1;
else
    figure_index = 2;
end


switch figure_index
    case 1
        figure
        colour = 'b';
        monoint = ints./19;
        fName = strcat(save_name,'_histogram_int_green.dat');
    case 2
        colour = 'r';
        monoint = ints./40;
        fName = strcat(save_name,'_histogram_int_red.dat');

%     case 3
%         hold off
%         figure(2)
%         colour = 'b';
%     case 4
%         colour = 'r';
end


set(gcf,'position',rect_matched);

x_axis_limit = 20;
bins = 1:1:20;
%bar(distances,mean);


y = histc(monoint,bins);
y2 = y./sum(y);
hold on
bar(bins,y2,colour);
axis([0, x_axis_limit, 0, 1]);
xlabel('Apparent Oligomer Size');
ylabel('Frequency');
title(strcat('Oligomer Distribution from Int for ',exp_name));


switch figure_index
    case 1
        saveas(gcf, [strcat(save_name,'_histogram_int_green.fig')]);    
    case 2
        saveas(gcf, [strcat(save_name,'_histogram_int_red.fig')]);
%     case 3
%         saveas(gcf, [strcat(results,'\', exp_name,'_histogram_shuffled_green.fig')]);    
%     case 4
%         saveas(gcf, [strcat(results,'\', exp_name,'_histogram_shuffled_red.fig')]);
end



    file_output = fopen(fName,'w');

    for n=1:length(y2),
        fprintf(file_output, '%d\t %f\n',bins(n),y2(n));
    end

    fclose(file_output);

