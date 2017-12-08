function drawTest(myTrack, fileOrder, figureNum)
color = rand(1, 3);

mu = myTrack(:, 2:3);

figure(figureNum);
axis([1 250 1 250]);
plot(mu(:, 1), mu(:, 2), 'Color', color);
hold on;
drawnow;
name = strcat(' \leftarrow ', num2str(fileOrder), '(', num2str(size(myTrack, 1)), ')');
text(mu(1, 1), mu(1, 2), name,'FontSize',10);
hold on;
drawnow;