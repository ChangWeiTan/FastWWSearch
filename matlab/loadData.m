function [Train, TrainClass, Test, TestClass] = loadData(dataName) %#ok<*STOUT>
if nargin < 1
    load('sampleTrain.mat'); %#ok<*LOAD>
    load('sampleTest.mat');
    return;
end
tscProblem = 'C:\Users\cwtan\workspace\Dataset\TSC_Problems';
trainName = sprintf('%s\\%s\\%s_Train', tscProblem, dataName, dataName);
testName = sprintf('%s\\%s\\%s_Test', tscProblem, dataName, dataName);

Train = load(trainName);
TrainClass = Train(:, 1);
Train(:, 1) = [];

Test = load(testName);
TestClass = Test(:, 1);
Test(:, 1) = [];

end