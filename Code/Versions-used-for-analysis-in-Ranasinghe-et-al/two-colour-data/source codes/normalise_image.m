function I_out = normalise_image(I)
%finds the global min/maximum and normalises the movie

global_max=max(max(max(I)));

I_out=(I)./(global_max);