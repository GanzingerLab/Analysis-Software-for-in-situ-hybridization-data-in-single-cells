function save_tracks(Tracks,info4Track,Results,minLength,save_dir)
fileOrder = 0;
for n =1:length(Tracks) %loop over all Tracks
    track = Tracks{n};

    if info4Track.len(n)<minLength     %if track is too short
        continue;
    end

    start4Frame = info4Track.finishTime(n) - info4Track.len(n)+1;
    myTrack = zeros(info4Track.len(n), 5);
    
    %store information about track (eg coordinates, sigma, amplitude)
    %in myTrack
    for index = 1:info4Track.len(n),
        frame=start4Frame + index - 1;
        
        y = Results{frame}.mu(track(index), 1);
        x = Results{frame}.mu(track(index), 2);
        amplitude = Results{frame}.amplitude(track(index));
        sigma = sqrt(Results{frame}.Sigma(track(index)));
        myTrack(index, :) = [frame, x, y, sigma, amplitude];
    end
    %save TrackInfo in .dat format in folder Results
    fileOrder = fileOrder + 1;
    order4track = num2str(fileOrder, '%3d');
    filename = strcat(save_dir,'/track_', order4track, '.dat');
    dlmwrite(filename,myTrack,'newline','pc');
    drawTest(myTrack, fileOrder, 100);
end