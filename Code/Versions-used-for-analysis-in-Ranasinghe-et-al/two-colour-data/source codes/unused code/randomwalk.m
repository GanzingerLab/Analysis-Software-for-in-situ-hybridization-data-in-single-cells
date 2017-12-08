function [matrix]=randomwalk(nspots,nimage,sizematrix)

% nspots = 3;
% nimage = 5;
% sizematrix = 20;

matrix = zeros (sizematrix,sizematrix,nimage);


x = ceil(sizematrix.*rand(nspots,1));
y = ceil(sizematrix.*rand(nspots,1));

for i=1:nspots
    xtemp=x(i);
    ytemp=y(i);
    matrix(xtemp,ytemp,1)=1;
end

    xtemp=x(i);
    ytemp=y(i);

for i=1:nspots                %loop over spots

    xtemp=x(i);
    ytemp=y(i);
    
    for n=2:nimage

    if xtemp > 0 && ytemp > 0
        r = rand;
    if r < 0.5
        xtemp = xtemp + 1;
    else
        xtemp = xtemp - 1;
    end
        r = rand;
    if r < 0.5
        ytemp = ytemp + 1;
    else
        ytemp = ytemp - 1;
    end

    if xtemp<sizematrix && xtemp>1 && ytemp<sizematrix && ytemp>1
    matrix(xtemp,ytemp,n)=1;
    else
        xtemp=0; ytemp=0;
    end
    end

    end
    
    
    
end
    
%matrix    
    
    



