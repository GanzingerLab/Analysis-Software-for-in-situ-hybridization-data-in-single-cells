function [stack_files] = get_stacks(directory,parameters)

d = dir(directory);

count=1;

for n=3:length(d),
    
    name = d(n).name;
    isstk= strfind(name,parameters.file_type);
    isfret= strfind(name,'f');
    
    if (length(isstk) >= 1)
        if parameters.fret == 1
            
            if (length(isfret) >= 1)  
                stack_files{count} = name;
                count = count + 1;
            end
        else
            if isempty(isfret) == 1  
                stack_files{count} = name;
                count = count + 1;
            end
        end
    end
    
end
