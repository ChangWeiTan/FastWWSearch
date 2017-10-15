# FastWWSearch
This is the repository for the paper "Efficient search of the best warping window for Dynamic Time Warping".
We provide the code here for peer-review assessment of our paper by the SDM18 Program Committee.

This work focused on fast learning/searching for the best warping window for Dynamic Time Warping and Time Series Classification. 

Running the files in the experiments folder will give the results for the paper. Note that the actual run time might differ as we randomly sample the training dataset - the ordering of the data in the training dataset will affect the runtime.

In general, there are 3-5 parameters to modify:
A. ScalabilityExperiment.java
  1. project path - path where the project/file/directory is located
  2. dataset path - path where the dataset is located (SITS_2006_NDVI_C)
  3. methods - algorithm used to search for the best warping window for a dataset
    a. FastWWSearch
    b. LBKeogh
    c. UCRSuite
    d. LBKeogh-UCRSuite
    
B. Benchmarking experiments (UCR_methods.java)
  1. project path - path where the project/file/directory is located
  2. dataset path - path where the dataset is located (UCR_Time_Series_Archive)
  3. sample type - how do you want to sample the UCR datasets 
    a. Single - just doing 1 dataset
    b. Sorted - all datasets sorted in ascending distance operation per query
    c. Small - doing just the small datasets
    d. New - including datasets from http://www.timeseriesclassification.com
    e. All - all datasets sorted in alphabetical order
  4. datasetName - name of dataset to test (only applicable if select Single for sample type
  5. number of runs - number of random sampling to do
  
Once the experiment is done, it will save the results in the projectPath/output/xxx/datasetName/datasetName_result_yyy.csv
  xxx -> Benchmark or Incorporate_PrunedDTW or Scaling
  yyy -> Methods used 
