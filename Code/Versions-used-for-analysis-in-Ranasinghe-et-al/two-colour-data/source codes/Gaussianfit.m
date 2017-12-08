function [ bestparameters,fval,exitflag output] = Gaussianfit( img,param0 )
%2dGaussianfit Summary of this function goes here
%   Detailed explanation goes here

[ny,nx] = size(img);
[X,Y] = meshgrid(1:nx,1:ny);
Zdata=img;

% par(3)=amplitude
% par(4)=sigma_X
% par(5)=sigma_Y
% X0=par(1);
% Y0=par(2);
% background = par(6);

%This is the actual Gaussian fit:
% - "residual" calculates the deviation of the fit from the image, given the intial parameters param0
% - fminsearch minimises the residual values for varying parameters from param0: X,Y,sigma_X,sigma_Y, amplitude
% - syntax: @(arg to optimise)function(arg),initial values for arg
%
%options = optimset('MaxFunEvals',3000,'MaxIter',3000);
options = optimset('Display','off');
[bestparameters,fval,exitflag,output] = fminsearch(@(parameters) residual_rcp(parameters, X, Y, Zdata),param0,options);





