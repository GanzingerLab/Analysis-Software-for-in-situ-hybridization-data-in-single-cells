function [I, directory,save_dir] = getFluorescentImages_batch(stack_directory,fName,sname,exp_name)

file = strcat(stack_directory, '\', fName);

    [im, nImage] = tiffread2(file);
    I = zeros(im(1).height, im(1).width, nImage);

    [dir, ext] = strread(fName,'%s%s','delimiter','.');
    
    directory = dir{1};
    h=waitbar(0, 'Data loading...');
    
    for t=1:nImage,
        I(:, :, t) = double(im(t).data);
        waitbar(t/length(im), h);
    end

    close(h);
    
    save_dir = strcat('Results_',exp_name,'\',directory);
    
    
    if isdir(save_dir)==0,
        mkdir(save_dir);
    end


end
