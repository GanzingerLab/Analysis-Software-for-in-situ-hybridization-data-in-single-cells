function [bestparameters, gof,output] = Gaussianfit_kristina(img,param0,nspot)

[ny,nx] = size(img);
[X,Y] = meshgrid(1:nx,1:ny);

Xfit = reshape(X,[],1);
Yfit = reshape(Y,[],1);

Zdata=img;
Zfit=reshape(Zdata',[],1);

twoDgauss = fittype( 'a+(b*exp(-(x-c).^2/(2*d^2)).*exp(-(y-e).^2/(2*f^2)))','independent', {'x', 'y'},...
     'dependent','z','coefficients',{'a','b','c','d','e','f'});

options = fitoptions('Method','NonlinearLeastSquares');
options.Algorithm = 'Levenberg-Marquardt';
options.StartPoint = param0; 

[fitobject, gof, output] = fit([Xfit,Yfit],Zfit,twoDgauss,options);

bestparameters = coeffvalues(fitobject);


% optional plot of fit:
% if nspot == 17 || nspot == 20 %|| nspot == 45 || nspot == 85 
%    figure(10),
%   plot(fitobject, [Xfit, Yfit], Zfit)
%    title(strcat('R2 = ',num2str(gof.adjrsquare),',# =',num2str(nspot),',ampli=',num2str(bestparameters(2))));
%   
%    pause
%   close(10);
%end
end
