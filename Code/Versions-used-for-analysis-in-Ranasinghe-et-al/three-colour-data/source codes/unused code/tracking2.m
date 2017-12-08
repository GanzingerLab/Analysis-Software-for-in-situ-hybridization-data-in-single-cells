function tracking2(Results,xyaSNRma,save_name,param,sizeim)

% Results=Results_blue{1,1};
%xyaSNRma=xyaSNRma_blue{1,1};

T = length(Results);

width = 30;
M = sizeim(1);
N = sizeim(2);
h=waitbar(1, 'Linking Images...(it takes several minutes.)');

for t=2:T
 
    after = zeros(M, N);
    
    previous = Results{t-1}.mu;
    current = Results{t}.mu;
    
    m = size(previous, 1);
    n = size(current, 1);
    distanceMap = ones(m, n)*10000;
    
    % In this next step, we create a MxN matrix with centroid positions in the current frame
    % marked with the number in which they are listed by cntrd.m
    
    for j=1:n,                                                                    
        after(round(current(j, 1)), round(current(j, 2))) = j;
    end

    % In this next step, a region of size (2xwidth)x(2xwidth) is drawn
    % around each centroid position in the previous frame
    
    for i=1:m,
        mu=[round(previous(i, 1)), round(previous(i, 2))];
        regionR = max(1, mu(1)-width):min(M, mu(1)+width);
        regionC = max(1, mu(2)-width):min(N, mu(2)+width);
        smallRegion = after(regionR, regionC);
        [R, C] = find(smallRegion>0);   %R = row, C = column
        Val = zeros(length(R), 1);
        for v =1:length(R),
            Val(v) = smallRegion(R(v), C(v));       % find positions of current centroids in small region
        end
        if length(R) == 0,
            continue;
        end
        [Y, I] = min(sqrt(sum((current(Val, :)-repmat(previous(i, :), length(Val), 1)).^2, 2)));    % Y =  value of min, I =index for cell containing min
        if Y(1)<=distanceMap(i, Val(I(1))),
            distanceMap(i, Val(I(1))) = Y(1);
        end
    end
    
    mask = zeros(m, n);
        
    for row=1:m,
        [V, I] = min(distanceMap(row, :), [], 2);
        if mask(row, I(1)) == 1,
            continue;
        end
        [V, J] = min(distanceMap(:, I(1)), [], 1);
        
        if V(1) >= param.max_step,
            continue;
        end
        
        if length(find(J == row))>0, % connect two points.
            mask(row, I(1)) = 1;
        end
    end

    FullMask{t} = mask;
    FullMap{t} = distanceMap.*mask;
    waitbar(t/T, h);
end
close(h);
    
MakeFormat4Results(Results,FullMask,0,save_name,xyaSNRma);
    
    