function [Results,xyaSNRma,Area,MeanInt4area,Perimeter4area,Perimeter4circle] = spotdetection_XLspots(image,parameters,fig_name,type,s4waitbar,bg4ori)


if parameters.fret == 1
    if strcmp(type,'r')== 1
        imageavg = sum(image(:,:,2:10),3)./9;
        clear image
        image = imageavg;
    end
elseif strcmp(type,'b')== 1
        imageavg = sum(image(:,:,2:10),3)./9;
        clear image
        image = imageavg;
end
   
    
   [~,~,T] = size(image);
%     
%         setup.M = H;
%         setup.N = W;
%         setup.K = T;
%         setup.fbs=FBS;     
    

    
        h=waitbar(0, s4waitbar);
    
        
    for t=1:T,
        im=image(:,:,t);

if t == 1,
[param,filtered_image,spot_boundaries,Area,MeanInt4area,Perimeter4area,Perimeter4circle]=automatic_detection_XLspots(im,parameters,fig_name,type,t,bg4ori);
else
[param,filtered_image,spot_boundaries]=automatic_detection_XLspots(im,parameters,fig_name,type,t,bg4ori);
end
            if isempty(param),                      %no spots are found
                Results{t}.spots = [];
                xyaSNRma{t} = [];
            else
                Results{t}.spots = spot_boundaries;
                xyaSNRma{t} = [param(:,1),param(:, 2),param(:,3),param(:,4)];
            end
            
            waitbar(t/T, h);
    end
    close(h);
