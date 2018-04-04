function bestWin = run()
[Train, TrainClass, ~, ~] = loadData();
bestWin = fastWWSearch(Train, TrainClass);
end