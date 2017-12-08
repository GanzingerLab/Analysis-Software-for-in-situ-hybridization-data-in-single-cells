function makeavi_filtered(setup,newY_cell,T,save_dir)

mov=avifile(strcat(save_dir,'\',setup.directory,'_track_filtered.avi'),'FPS',str2double(setup.fbs),'Compression','Cinepak');

nTracks = length(dir(strcat(cd,'\',save_dir,'\track','*.dat')));
Data = cell(nTracks, 1);

    for ii = 1:nTracks,
    fileName = strcat(cd,'\', save_dir,'\track_', num2str(ii), '.dat');
    Data{ii} = load(fileName);
    end

h = waitbar(0,'Making avi file...','Position',[300,100,270,60]);

for t=1:T,

    imagesc(newY_cell(:, :, t)); colormap('jet'); hold on;

    for n=1:nTracks,
        track = Data{n};
        seq = track(:, 1);
        P = find(seq == t);
        if length(P)~=0
            index = P(1);
            plot(track(index, 3), track(index, 2), 'ro', 'LineWidth', 2);
            name1 = strcat(' SNR: ',num2str(track(index,5)),' ',' int: ',num2str(track(index,6)));
            name = strcat(' \leftarrow ', num2str(n));
            %optional, if SNR and mean intensity should not be displayed
            name = strcat(' \leftarrow ', num2str(n));
            text(track(index, 3), track(index, 2), name,'FontSize',9, 'Color', 'r');
        end
    end
    %    pause(0.1);
    drawnow;
    F = getframe;
    mov = addframe(mov, F);
    hold off;
    waitbar(t/T,h)
end

close(h);

mov = close(mov);
