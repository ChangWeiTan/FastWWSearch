# FastWWSearch
This is the repository for the paper "Efficient search of the best warping window for Dynamic Time Warping". http://changweitan.com/research/LearningDTWWindow-CameraReady.pdf

This work focused on fast learning/searching for the best warping window for Dynamic Time Warping and Time Series Classification. 

## Experiments
Running the files in the experiments folder will give the results for the paper. Note that the actual run time might differ as we randomly sample the training dataset - the ordering of the data in the training dataset will affect the runtime.

In general, there are 3-5 parameters to modify:
A. ScalabilityExperiment.java
  1. project path - path where the project/file/directory is located
  2. dataset path - path where the dataset is located (SITS_2006_NDVI_C)
  3. methods - algorithm used to search for the best warping window for a dataset
    * FastWWSearch
    * LBKeogh
    * UCRSuite
    * LBKeogh-UCRSuite
    
B. Benchmarking experiments (UCR_methods.java)
  1. project path - path where the project/file/directory is located
  2. dataset path - path where the dataset is located (UCR_Time_Series_Archive)
  3. sample type - how do you want to sample the UCR datasets 
    * Single - just doing 1 dataset
    * Sorted - all datasets sorted in ascending distance operation per query
    * Small - doing just the small datasets
    * New - including datasets from http://www.timeseriesclassification.com
    * All - all datasets sorted in alphabetical order
  4. datasetName - name of dataset to test (only applicable if select Single for sample type
  5. number of runs - number of random sampling to do
  
Once the experiment is done, it will save the results in the projectPath/output/xxx/datasetName/datasetName_result_yyy.csv
  xxx -> Benchmark or Incorporate_PrunedDTW or Scaling
  yyy -> Methods used 

## Subsets of windows
Our method gives the exact best warping window by considering the full length (i.e. building a table matrix of training size x series length). However, it is possible to use any subsets of the full series length to search for the best window in that subset. Note that results from different subsets might differ, and might not be really exact. 

Usually the best warping window are given as a percentage of the full series length. Here, we extended our original FastWWSearch for this purpose (FastWWSByPercentage.java). In other words we only consider 101 windows ranging from 0 to 100 percent. For example, if a series has length of 200, the original method considers all 200 windows while the "by percentage" version only considers 101 windows (0,2,4,...,200) 
