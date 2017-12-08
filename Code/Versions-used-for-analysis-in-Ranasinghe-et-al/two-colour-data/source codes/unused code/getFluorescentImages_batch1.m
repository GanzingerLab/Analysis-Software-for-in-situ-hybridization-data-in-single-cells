function [I, directory,save_dir] = getFluorescentImages_batch1(stack_directory,fName,exp_name)

file = strcat(stack_directory, '\', fName);

    [im, nImage] = tiffread2(file);
    I = zeros(im(1).height, im(1).width, nImage);

    [dir,] = strread(fName,'%s%s','delimiter','.');
    
    directory = dir{1};
    h=waitbar(0, 'Data loading...');
    
    for t=1:nImage,
        I(:, :, t) = double(im(t).data);
        waitbar(t/length(im), h);
    end

    close(h);
    
    save_dir = strcat('Results_2colourvideo\',exp_name,'\',directory);
    
    if isdir(save_dir)==0,
        mkdir(save_dir);
    else
        'Attention, directory results already exists, will be overwritten'
    end
    


end
