function plot_circle(x,y,r)
for i = 1:length(x)
    x_i=x(i);
    y_i=y(i);
    r_i=r(i);
plot(x_i + r_i*cos(2*pi/40*(0:40)), y_i + r_i*sin(2*pi/40*(0:40)),'r','LineWidth',2);
hold on
end
hold off