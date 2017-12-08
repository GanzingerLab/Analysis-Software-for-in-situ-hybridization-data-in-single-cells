function [track, info4track] = produceTracks(Results, fullMap, fullMask)
%output, cell track with the numbers in the respective frames
%        info4track.len is length of the track
%        info4track.finishTime(nTrack) defines the frame in which track
%        finishes



T = length(Results); %T, index for image frame
myMask = fullMask;   %mask with 0 or 1 entries

info4track.finishTime = [];
track = [];


for t=T:-1:2 %start with the last frame and end with the second one
    [Row, Col] = find(myMask{t} == 1); 
    %get numbers of linked spots, Row number in previous stack,
    %Col number in current stack
    
    for c=1:length(Col) %loop over all linked spots in current stack
        nTrack = length(track)+1;       %counts the number of tracks
        info4track.finishTime(nTrack) = t;
        track{nTrack} = Col(c); 
        r = Row(c);
        track{nTrack} = [r, track{nTrack}]; %r=spotnumber in prev image
                                            % =spotnumber in curr image
        % eg spot r is linked to spot track{nTrack}
        
        for t2=t-1:-1:2,
            mask = myMask{t2};
            %looking if spot r is linked to another spot in the
            %previous image
            [smallR, smallC] = find(mask(:, r) == 1);
            if length(smallR) == 0 %a track is finished.. (inversely)
                break;
            else
            %link spot in previous frame to r
                track{nTrack} = [smallR, track{nTrack}];
                mask(smallR, r) = 0; 
                myMask{t2} = mask;
                r = smallR;
            end
        end
        info4track.len(nTrack) = length(track{nTrack});
    end
end
