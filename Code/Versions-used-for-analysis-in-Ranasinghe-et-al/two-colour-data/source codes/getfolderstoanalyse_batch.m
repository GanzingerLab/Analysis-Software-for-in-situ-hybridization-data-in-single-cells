function [folders2analyse,root_directory] = getfolderstoanalyse_batch(path) 

%root_directory  = uigetdir('','Choose directory containing image files');
root_directory = strcat(path);
d = dir(root_directory);
count = 1;

for n=3:length(d),
    % start at 3, skip the first two, irrelevent entries (., ..)
    
    if strcmp(d(n).name,'0.5') ~= 1
    folders2analyse{count} = d(n).name;   
    count = count +1;
    end
    
end


end