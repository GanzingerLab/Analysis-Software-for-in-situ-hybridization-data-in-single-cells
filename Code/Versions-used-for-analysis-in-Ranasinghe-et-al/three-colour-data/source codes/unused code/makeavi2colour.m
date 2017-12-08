function makeavi2colour(setup,newY_cell,T,save_dir_green,save_dir_red)

mov=avifile(strcat(save_dir_red,'\',setup.directory,'_track_twocolour.avi'),'FPS',str2double(setup.fbs),'Compression','Cinepak');

nTracks_green = length(dir(strcat(cd,'\',save_dir_green,'\*.dat')))
Data_green = cell(nTracks_green, 1);

    for ii = 1:nTracks_green,
    fileName_green = strcat(cd,'\', save_dir_green,'\track_', num2str(ii), '.dat');
    Data_green{ii} = load(fileName_green);
    end

nTracks_red = length(dir(strcat(cd,'\',save_dir_red,'\*.dat')))
Data_red = cell(nTracks_red, 1);

    for ii = 1:nTracks_red,
    fileName_red = strcat(cd,'\', save_dir_red,'\track_', num2str(ii), '.dat');
    Data_red{ii} = load(fileName_red);
    end    
     

h = waitbar(0,'Making two colour avi file...','Position',[300,100,270,60]);

for t=1:T,

    imagesc(newY_cell(:, :, t)); colormap('gray'); hold on;

    for n=1:nTracks_green,
        track = Data_green{n};
        seq = track(:, 1);
        P = find(seq == t);
        if length(P)~=0
            index = P(1);
            plot(track(index, 2), track(index, 3), 'go', 'LineWidth', 2);
            name = strcat(' \leftarrow ', num2str(n));
            text(track(index, 2), track(index, 3), name,'FontSize',9, 'Color', 'g');
        end
    end
    
    for n=1:nTracks_red,
        track = Data_red{n};
        seq = track(:, 1);
        P = find(seq == t);
        if length(P)~=0
            index = P(1);
            plot(track(index, 2), track(index, 3), 'ro', 'LineWidth', 2);
            name = strcat(' \leftarrow ', num2str(n));
            text(track(index, 2), track(index, 3), name,'FontSize',9, 'Color', 'r');
        end
    end

    drawnow;
    F = getframe;
    mov = addframe(mov, F);
    hold off;
    waitbar(t/T,h)
end

close(h);

mov = close(mov);