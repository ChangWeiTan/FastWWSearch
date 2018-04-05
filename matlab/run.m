function [bestWin, nns, errors] = run()
clc; close all;

[Train, TrainClass, ~, ~] = loadData();

tic;
[bestWinFastWWS, nnsFastWWS, errorsFastWWS] = fastWWSearch(Train, TrainClass);
fastWWSTime = toc;
fprintf('FastWWSearch completed in %.3fs\n', fastWWSTime);

tic;
[bestWin, nns, errors] = naiveWWSearch(Train, TrainClass);
naiveTime = toc;
fprintf('Naive search completed in %.3fs\n', naiveTime);

% plot
x = linspace(0, length(errors)-1, length(errors));
figure(1)
clf
plot(x, errors, 'b', 'linewidth', 2);
hold on;
plot(x, errorsFastWWS, 'r', 'linewidth', 2);
plot(bestWin, errors(bestWin+1), 'gx', 'MarkerSize', 8);
plot(bestWinFastWWS, errorsFastWWS(bestWin+1), 'go', 'MarkerSize', 8);
hold off;
xlim([0, length(errors)]);
ylim([0, 1]);
xlabel('Warping Windows, w')
ylabel('Error Rate, e');
title(sprintf('Error Rate vs Warping Window - (%d,%d)', bestWin, bestWinFastWWS))
end