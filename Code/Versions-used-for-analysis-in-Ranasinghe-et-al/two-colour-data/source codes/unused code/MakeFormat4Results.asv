function [Tracks, info4Track] = MakeFormat4Results(Results, fullMask,minLength,save_name,xyaSNRma)
global n n3
[Tracks, info4Track] = produceTracks(Results, fullMask);

fileOrder = 0;
for i =1:length(Tracks)
    track = Tracks{i};

    if info4Track.len(i)<minLength,
        continue;
    end

    start4Frame = info4Track.finishTime(i) - info4Track.len(i)+1;
    myTrack = zeros(info4Track.len(i), 6);
    for index = 1:info4Track.len(i),
        frame=start4Frame + index - 1;
        y = Results{frame}.mu(track(index), 1);
        x = Results{frame}.mu(track(index), 2);
        
        %adding total brightness, SNR and mean intensity to result_tracks
        tt=xyaSNRma{frame};
        ll=find(tt==y)
        temp=tt(ll,:)
    
        amplitude = temp(3);
        SNR = temp(4);
        ma = temp(5);
        myTrack(index, :) = [frame, x, y, amplitude, SNR, ma];
    end
    fileOrder = fileOrder + 1;
    order4track = num2str(fileOrder, '%3d');
    filename = strcat(save_name,'tracks_for_',num2str(n),'_',num2str(n3),'/track_', order4track, '.dat');
    dlmwrite(filename,myTrack,'newline','pc');
   % drawTest(myTrack, fileOrder, 100);
end




function [track, info4track] = produceTracks(Results, fullMask)
T = length(Results);
myMask = fullMask;

info4track.finishTime = [];
track = [];
for t=T:-1:2,
    [Row, Col] = find(myMask{t} == 1);
    for c=1:length(Col),
        nTrack = length(track)+1;
        info4track.finishTime(nTrack) = t;
        track{nTrack} = Col(c);
        r = Row(c);
        
        track{nTrack} = [r, track{nTrack}];
        for t2=t-1:-1:2,
            mask = myMask{t2};
            [smallR, smallC] = find(mask(:, r) == 1);
            if length(smallR) == 0,
                %an track is finished.. (inversely)
                break;
            else
                track{nTrack} = [smallR, track{nTrack}];
                mask(smallR, r) = 0;
                myMask{t2} = mask;
                r = smallR;
            end
        end
        info4track.len(nTrack) = length(track{nTrack});
    end
end
