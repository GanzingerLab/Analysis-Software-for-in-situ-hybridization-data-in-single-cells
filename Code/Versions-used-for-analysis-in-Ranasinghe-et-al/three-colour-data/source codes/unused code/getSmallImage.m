function [A, a, b] = getSmallImage(I)


fig = figure(1);
frame = I{1};
figure(1); imagesc(frame);colormap(gray);

rect = round(getrect(fig));
a = rect(2);
b = rect(1);


rect(3) = max(50, rect(3));
rect(4) = max(50, rect(4));

A = cell(1, length(I));
for i=1:length(I),
    Y = I{i};
    A{i} = Y(rect(2):rect(2)+rect(4)-1, rect(1):rect(1)+rect(3)-1);
end