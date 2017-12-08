function [FullMap, FullMask] = LinkImages(Results, setup,max_step)

    M = setup.M;
    N = setup.N;
    T = setup.K;
    width = 30;

h=waitbar(1, 'Linking Images...(it takes several minutes.)');

for t=2:T  %loop over all images of stack
   
    previous = Results{t-1}.mu;
    current = Results{t}.mu;
    
    m = size(previous, 1);
    n = size(current, 1);
    distanceMap = ones(m, n)*10000;
    
    % In this next step, we create a MxN matrix with centroid positions in the current frame
    % marked with the number in which they are listed by cntrd.m
    after_current = zeros(M, N);
    %current(j, 1)=x position, current(j, 2)=y position
    for j=1:n,                                                                    
        after_current(round(current(j, 1)), round(current(j, 2))) = j;
    end

    
    % In this next step, a region of size (2xwidth)x(2xwidth) is drawn
    % around each centroid position in the previous frame
    
    for i=1:m %loop over all spots detected in previous frame
        Temp=[round(previous(i, 1)), round(previous(i, 2))];
        regionR = max(1, Temp(1)-width):min(M, Temp(1)+width);
        regionC = max(1, Temp(2)-width):min(N, Temp(2)+width);
        smallRegion = after_current(regionR, regionC);           %cuts out region in current frame
        %R = row, C = column
        %looks, if there are spots in small region in current image
        [R, C] = find(smallRegion>0); %find coordinates of current spots in small region                            
        Val = zeros(length(R), 1);    %lenght(R)=number of present spots in current image
        for v =1:length(R),
            Val(v) = smallRegion(R(v), C(v));  % find number of current centroids in small region
        end
        if length(R) == 0,
            continue;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Y =  value of min, I =index for cell containing min
        % (current(Val, :) coordinates of current spots found in smallRegion
        % previous(i, :) coordinates of initial spot in previous frame
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Now the distances between the initial spot in previous frame and 
        % the spots of the current frame which are present in smallRegion
        % are calculated, and the minimum distance Y is chosen. Val(Y) is
        % the number of the chosen spot.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Temp_sum=sum((current(Val, :)-repmat(previous(i, :), length(Val), 1)).^2, 2);
        spot_distances=sqrt(Temp_sum);
        [Y, I] = min(spot_distances);
        
        
        %i=spot in previous frame
        %distanceMap connects now the spot in the previous frame with the
        %closest spot in the current frame, entries of distanceMap
        %represent distances
        if Y(1)<=distanceMap(i, Val(I(1)))
            distanceMap(i, Val(I(1))) = Y(1);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now two spots in the current frame are linked to the spots in the
    % previous frame, which are in closest distance to them.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mask = zeros(m, n);
    
    
    for row=1:m %loop over all spots detected in previous frame
        
        [V, I] = min(distanceMap(row, :));  %choose the minimum
                                            %I number of spot in current image   
        
        if mask(row, I(1)) == 1,            %two spots already connected
            continue;
        end
        
        [V, J] = min(distanceMap(:, I(1)));
        
        if V(1) >= max_step,                %distance between spots is too big
                                            %spots wont be linked
            continue;
        end
        
        if length(find(J == row))>0,        % connect two points.
            mask(row, I(1)) = 1;
        end
    end

    
    FullMask{t} = mask;
    FullMap{t}  = distanceMap.*mask;
    waitbar(t/T, h);
end
close(h);



