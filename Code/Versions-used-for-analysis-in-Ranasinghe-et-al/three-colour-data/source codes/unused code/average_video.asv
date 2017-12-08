function [I] = average_video(I,H,W,T,favg)

f=zeros(H,W,T);

f_start = zeros(H,W,1);
f_start = sum(I(:,:,1:favg),3);

for n=1:favg/2,
    f(:,:,n) = f_start;
end

for n=((favg/2)+1):(T-(favg/2)),
    f(:,:,n)= f(:,:,(n-1)) + I(:,:,(n+favg/2)) - I(:,:,(n-favg/2));
end



f_final = zeros(H,W,1);

f_final(:,:,1)=sum(I(:,:,T-favg:T),3);



for n = (T-(favg/2)+1):T,
    f(:,:,n) = f_final(:,:,1);
end

I_final = I - (f/favg);

I_final = uint16(I_final);          % rounds to nearest integer, values < 0 are set to 0

%    I_original = I;
I = I_final;