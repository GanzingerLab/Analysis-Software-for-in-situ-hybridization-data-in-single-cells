%function [ output_args ] = surfaceplot( image )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
x1 = 1:size(image,1); x2 =1:size(image,2);
x2=x2'; x1=x1';
[X1,X2] = meshgrid(x1,x2);
F = double(image);
F = F./max(max(F));
%F = reshape(F,length(x2),length(x1));
surf(x2,x1,F);
caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
axis([1 25 1 25 0 1])
mu = [cx cy];
Sigma = cov;
[X1,X2] = meshgrid(x1,x2);
F = mvnpdf([X1(:) X2(:)],mu,Sigma);
F = F/max(F);
F = reshape(F,length(x2),length(x1));
figure(2),surf(x2,x1,F);
caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
axis([1 25 1 25 0 1])
xlabel('x1'); ylabel('x2'); zlabel('Probability Density');


