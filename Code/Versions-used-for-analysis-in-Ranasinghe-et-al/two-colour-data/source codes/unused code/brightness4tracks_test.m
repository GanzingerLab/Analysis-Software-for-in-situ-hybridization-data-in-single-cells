%function [spots] = brightness4tracks(save_name)
%global n n3
n=1;
n3=1;
%nTracks = length(dir(strcat(cd,'\',save_name,'tracks_for_',num2str(n),'_',num2str(n3),'\track','*.dat')));
nTracks = 1;
if ~isempty(nTracks)
Data = cell(nTracks, 1);

    %for ii = 1:nTracks,
    ii=3;
    fileName = strcat(cd,'\', save_name,'tracks_for_',num2str(n),'_',num2str(n3),'\track_', num2str(ii), '.dat');
    
    Data{1} = load(fileName);
    %end
    
    for iii=1:nTracks,
        clear all_brightness all_position
        track = Data{iii};
        all_brightness = track(:,6);
        all_position = track(:,2:3);
        count = 1;
        for i=1:length(all_brightness)-1
        if all_brightness(i+1) > 0.6*all_brightness(i)
           count = count+1;
        else
           break
        end
        end
        mean_brightness(iii)= mean(all_brightness(1:count));
        if count > 1
        mean_position(iii,1:2)= mean(all_position(1:count,:));
        else
        mean_position(iii,1:2)= all_position(1,:);
        end
    end
    mean_brightness = mean_brightness';
    spots = [mean_position mean_brightness];
else
    spots = 0;
end