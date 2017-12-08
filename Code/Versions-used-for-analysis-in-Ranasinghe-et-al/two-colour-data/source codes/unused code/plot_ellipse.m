function plot_ellipse(x,y,r1,r2,SNR,SNR_1,exitflag,area)
for i = 1:length(x)
    x_i=x(i);
    y_i=y(i);
    r1_i=r1(i);
    r2_i=r2(i);
    SNR_i=SNR(i);
    SNR_1_i=SNR_1(i);
    exitflag_i=exitflag(i);
    area_i=area(i);
 
    
plot(x_i + r1_i*cos(2*pi/40*(0:40)), y_i + r2_i*sin(2*pi/40*(0:40)),'r','LineWidth',2);
%text(x_i,y_i+4,strcat(num2str(SNR_i),'__',num2str(SNR_1_i)),'LineWidth',2,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left')

hold on
end
hold off