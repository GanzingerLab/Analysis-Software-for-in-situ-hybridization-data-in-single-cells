function [jump] = get_jump(time,x,y,parameters)

for i=1:length(x)-1
    
    if time(i)-time(i+1)==1
        
        jump(i) = sqrt(((x(i) - x(i+1)).^2 + (y(i) - y(i+1)).^2).*(parameters.pixel_size*1000).^2);
        
    else
        time(i) = 0;
    end
end
    
