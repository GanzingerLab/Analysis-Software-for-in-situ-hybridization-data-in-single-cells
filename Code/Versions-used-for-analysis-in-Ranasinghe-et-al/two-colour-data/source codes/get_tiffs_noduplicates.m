function [red_files,blue_files] = get_tiffs_noduplicates(parameters,stack_directory)

d = dir(stack_directory);

for n=3:length(d),
    % start at 3, skip the first two, irrelevent entries (., ..)
    name = d(n).name;
    isstk= strfind(name,parameters.file_type);
    isfret= strfind(name(1:end-4),'f');
    isblue=findstr(name,'B');
    isred =findstr(name,'R');
    %separate blue and fluorescent TC and FRET files
   
        if (length(isstk) >= 1)
            if parameters.fret == 1
                
                if (length(isfret) >= 1)
                    index = [str2double(name(5:end-5))];
                    red_files{index} = name;
                    
                    
                elseif (length(isblue) >= 1)
                    index = [str2double(name(5:end-4))];
                    blue_files{index} = name;
                end
            else
                if (isempty(isfret) && isempty(isblue) && ~isempty(isred))
                    index = [str2double(name(1:end-5))];
                    red_files{index} = name;
                    
                elseif (length(isblue) >= 1)
                    index = [str2double(name(1:end-5))];
                    blue_files{index} = name;
                end
            end
        end
        
end

%delete double images due to mistake in automated image acquisition
files2del = [3:5:length(red_files)];
for i=1:length(files2del)
red_files{files2del(i)} = [];
blue_files{files2del(i)} = [];
end
end