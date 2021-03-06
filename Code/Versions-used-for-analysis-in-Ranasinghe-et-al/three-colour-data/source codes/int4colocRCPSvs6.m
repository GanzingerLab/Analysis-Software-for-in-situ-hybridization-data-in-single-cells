function [redint, blueint,redint_ma, blueint_ma, dyeint4blue, dyeint4red] = int4colocRCPSvs6(pos,sp_red,sp_blue,sp_redOR,sp_blueOR,ORcrit)
%pos = coloc_pos{n,n4}{3,1};
%sp = spots{n,n4};

allindex = [];
allindex_blue = [];

    if ~isempty(pos) == 1
        
        for i = 1:size(pos,1)
            index1 = find(pos(i,3)== sp_red(:,1));
            index2 = find(pos(i,4)== sp_red(:,2));
            index3 = find(pos(i,1)== sp_blue(:,1));
            index4 = find(pos(i,2)== sp_blue(:,2));
            
            for ii = 1:length(index1)
                for iii = 1:length(index2)
                    if index1(ii)==index2(iii)
                        allindex = [allindex index1(ii)];
                    end
                end
            end
            for ii = 1:length(index3)
                for iii = 1:length(index4)
                    if index3(ii)==index4(iii)
                        allindex_blue = [allindex_blue index3(ii)];
                    end
                end
            end
        end
        
        
        redint = sp_red(allindex,3);
        redint_ma = sp_red(allindex,5);
        blueint = sp_blue(allindex_blue,3);
        blueint_ma = sp_blue(allindex_blue,5);
        
        
        if ORcrit == 1
        %add remaining red spots
        rest = sp_red(:,5);
        restOR = sp_redOR(:,3);
        rest(allindex,:) = [];
        restOR(allindex,:) = [];
        
        redint_ma = [redint_ma; rest]; 
        blueint_ma = [blueint_ma; restOR];
       
        %add remaining blue spots
         rest = sp_blue(:,5);
         restOR = sp_blueOR(:,3);
         rest(allindex_blue,:) = [];
         restOR(allindex_blue,:) = [];
      
         blueint_ma = [blueint_ma; rest];     
         redint_ma = [redint_ma; restOR];
         
        
        end
        
        
        
        dyeint4red = sp_red(allindex,7);
        dyeint4blue = sp_blue(allindex_blue,7);
        
        
        if ORcrit == 1
        rest = sp_red(:,7);
        restOR = sp_redOR(:,4);
        rest(allindex,:) = [];
        restOR(allindex,:) = [];
        dyeint4red = [dyeint4red; rest];
        dyeint4blue = [dyeint4blue; restOR];
        
        end
  
        
        
        if ORcrit == 1
        rest = sp_blue(:,7);
        restOR = sp_blueOR(:,4);
        rest(allindex_blue,:) = [];
        restOR(allindex_blue,:) = [];
        dyeint4blue = [dyeint4blue; rest];
        dyeint4red = [dyeint4red; restOR];
        end
        
        
    else
        redint = [];
        blueint = [];
        redint_ma = [];
        blueint_ma = [];
        
        dyeint4blue = [];
        dyeint4red = [];
    end
