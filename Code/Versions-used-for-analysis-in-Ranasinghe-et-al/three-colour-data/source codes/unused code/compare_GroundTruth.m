function compare_GroundTruth(minLength, name4window)
load groundTruth.mat;
nTracks = length(data);
for n=1:nTracks,
    myTrack = [n*ones(length(data{n}.width), 1), data{n}.mu(:, 2), data{n}.mu(:, 1), data{n}.width', data{n}.amplitude'];
    if size(myTrack, 1)>minLength,
        drawTest(myTrack, n, name4window);
    end
end
