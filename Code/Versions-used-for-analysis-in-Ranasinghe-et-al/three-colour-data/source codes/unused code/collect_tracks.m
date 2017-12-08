function collect_tracks

d=dir;

%% This part checks for all the directories in the current folder

for n=1:length(d),
    
   if d(n).isdir ==true,
       list_dir{n}=d(n).name;
   end
end
    
jj=1;  
log={};

%% This part checks for .dat files in the directories that were found in
%% the first step, excluding numbers 1 & 2 since these are empty

for n=3:length(list_dir),
    
    directory = list_dir{n};
    
    nTracks = length(dir(strcat(directory, '/*.dat')));

    for ii=1:nTracks
        fileName = strcat(directory, '/track_', num2str(ii), '.dat');
        Data{ii} = load(fileName);
        fileName = strcat('track_', num2str(jj), '.log'); 
        log{jj,1} = directory;
        log{jj,2} = ii;
        log{jj,3} = jj;
        jj=jj+1;
        dlmwrite(fileName,Data{ii},'newline','pc');
            
    end
    
    
    
end

%% This next part creats a record of how the files have been renamed this
%% was all taken from
%% http://www.mathworks.com/support/solutions/data/1-1190ZB.html?solution=1
%% -1190ZB but modified slightly to save the whole data array


ex2 = cellfun(@ex_func,log,'UniformOutput',0);
size_ex2 = cellfun(@length,ex2,'UniformOutput',0);
str_length = max(max(cell2mat(size_ex2)));
ex3 = cellfun(@(x) ex_func2(x,str_length),ex2,'uniformoutput',0);

ex4 = cell2mat(ex3);
fid = fopen('log.txt','wt');
for i = 1:size(ex4,1)
    fprintf(fid,'%s\n',ex4(i,:));
end
fclose(fid);

function [ out ] = ex_func( in )

in_datatype = class(in);

switch in_datatype
    case 'char'
        out = in;
    case 'double'
        out = num2str(in);
end

function [ out ] = ex_func2( in, str_length )

a = length(in);
out = [char(32*ones(1,str_length-a)), in];