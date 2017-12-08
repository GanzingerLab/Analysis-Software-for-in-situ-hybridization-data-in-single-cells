% Define a residual function
function err = residual_rcp(par, X,Y,Zdata)
X0=par(1);
Y0=par(2);
Zmodel = par(6) + (par(3)*exp(-(X-X0).^2/(2*par(4)^2)).*exp(-(Y-Y0).^2/(2*par(5)^2)));
err = sum(sum( (Zmodel-Zdata).^2 ));
end