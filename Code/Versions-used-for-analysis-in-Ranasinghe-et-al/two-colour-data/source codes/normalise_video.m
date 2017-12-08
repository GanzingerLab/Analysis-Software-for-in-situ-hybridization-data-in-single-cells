function I_out = normalise_video(I)
%finds the global min/maximum and normalises the movie
[H,W,T] = size(I);

global_max=max(max(max(I)));
global_min=min(min(min(I)));
for i=1:T
I_out(:,:,i)=(I(:,:,i)-global_min)./(global_max-global_min);
end