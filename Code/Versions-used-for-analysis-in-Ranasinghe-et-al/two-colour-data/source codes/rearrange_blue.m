function [col_blue] = rearrange_blue(blue)

[M N]=size(blue);
Lblue = M*N;

col_blue = reshape(blue,Lblue,1);

col_blue = sort(col_blue,1);




