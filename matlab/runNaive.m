function [bestWin, nns, errors] = runNaive()
clc; close all;

[Train, TrainClass, ~, ~] = loadData();

tic;
[bestWin, nns, errors] = naiveWWSearch(Train, TrainClass);
naiveTime = toc;
fprintf('Naive Search completed in %.3fs\n', naiveTime);

% plot
x = linspace(0, length(errors)-1, length(errors));
figure(1)
clf
plot(x, errors, 'linewidth', 2);
hold on;
plot(bestWin, errors(bestWin+1), 'rx', 'MarkerSize', 8);
hold off;
xlim([0, length(errors)]);
ylim([0, 1]);
xlabel('Warping Windows, w')
ylabel('Error Rate, e');
title(sprintf('Error Rate vs Warping Window - %d', bestWin))
end