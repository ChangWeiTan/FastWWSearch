/*******************************************************************************
 * Copyright (C) 2017 Chang Wei Tan
 * 
 * This file is part of FastWWSearch.
 * 
 * FastWWSearch is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 * 
 * FastWWSearch is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with FastWWSearch.  If not, see <http://www.gnu.org/licenses/>.
 ******************************************************************************/
package experiments;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import items.ExperimentsLauncher;
import tools.Sampling;
import weka.core.Instances;
import windowSearcher.FastWWS;
import windowSearcher.KDD12;
import windowSearcher.SDM16;
import windowSearcher.WindowSearcher;

/**
 * Code for the paper "Efficient search of the best warping window for Dynamic Time Warping" published in SDM18
 * 
 * Experiment to plot Figure 1 of our SDM18 paper comparing the scalability of the different methods
 * We estimate the search time for dataset with sample size larger than estimate
 * 
 * @author Chang Wei Tan
 *
 */
public class ScalabilityExperiment {
	private static final int estimate = 10000;
	private static String osName, datasetName, username, projectPath, datasetPath, resDir, type;
	private static int[] sampleTrains = new int[]{100, 100, 250, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 500000, 1000000};

	public static void main(String[] args) throws Exception {
		datasetName = "SITS1M_fold1";		// Name of dataset to be tested
		type = "fastwws";						// Method type in finding the best window "naive, kdd12, sdm16, fastwws"
		
		// Get project and dataset path
		osName = System.getProperty("os.name");
		username = System.getProperty("user.name");
		if (osName.contains("Window")) {
			projectPath = "C:/Users/" + username + "/workspace/SDM18/";
			datasetPath = "C:/Users/" + username + "/workspace/Dataset/SITS_2006_NDVI_C/";
		} else {
			projectPath = "/home/" + username + "/workspace/SDM18/";
			datasetPath = "/home/" + username + "/workspace/Dataset/SITS_2006_NDVI_C/";
		}
		
		// Get initial heap size
		long heapMaxSize = Runtime.getRuntime().maxMemory();
		long heapFreeSize = Runtime.getRuntime().freeMemory(); 
		System.out.println("Heap Size -- Free " + 1.0*heapFreeSize/1e6 + ", " + 1.0*heapMaxSize/1e6);
		
		// Get arguments 
		if (args.length >= 1) projectPath = args[0];
		if (args.length >= 2) datasetPath = args[1];
		if (args.length >= 3) type = args[2];

		System.out.println("Experiment on " + type + " for " + datasetName + " dataset");

		// Load all data
		Instances allData = loadAllData(); 

		// Run the experiment depending on the given type
		switch (type) {
		case "navie": 
			keogh(allData);
			break;
		case "kdd12":
			kdd12(allData);
			break;
		case "sdm16":
			sdm16(allData);
			break;
		case "fastwws":
			fastWWS(allData);
			break;
		}
	}// End main

	/** 
	 * Load all data into 1 
	 * @return
	 */
	private static Instances loadAllData() {
		resDir = projectPath + "outputs/Scaling/";

		File dir = new File(resDir);
		if (!dir.exists())
			dir.mkdirs();

		System.out.println("Processing: " + datasetName);
		Instances data = ExperimentsLauncher.readAllInOne(datasetPath, datasetName);
		
		return data;
	}

	/**
	 * Run FastWWSearch (SDM18)
	 * @param data
	 */
	public static void fastWWS(Instances data) {
		System.out.println("FastWWS");
		double[] timeTaken = new double[sampleTrains.length];
		int i = 0;
		for (int sampleSize : sampleTrains) {
			double searchTime = fastWWS(data, sampleSize);
			timeTaken[i++] = searchTime;
		}
	}
	
	/**
	 * Run FastWWSearch (SDM18) for a given size
	 * @param data
	 * @param sampleSize
	 * @return
	 */
	public static double fastWWS(Instances data, int sampleSize) {
		double searchTime = 0;
		long start, stop;
		try{
			Instances newTrain = Sampling.sample(data, sampleSize);

			System.out.println("Size: " + sampleSize + ", Launching FastWWS");
			FastWWS classifier = new FastWWS(datasetName);
			classifier.setResDir(resDir);
			classifier.setType(type);
			start = System.nanoTime();
			classifier.buildClassifier(newTrain);
			stop = System.nanoTime();
			searchTime = 1.0 * ((stop - start)/1e9);
			saveSearchTime(sampleSize, searchTime);
			System.out.println("Size: " + sampleSize + ", " + searchTime + " s");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return searchTime;
	}
	
	/**
	 * Run DTW with LB Keogh
	 * @param data
	 */
	public static void keogh(Instances data) {
		System.out.println("KEOGH");
		double[] timeTaken = new double[sampleTrains.length];
		int i = 0;
		for (int sampleSize : sampleTrains) {
			double searchTime = keogh(data, sampleSize);
			timeTaken[i++] = searchTime;
		}
	}
	
	/**
	 * Run DTW with LB Keogh for a given size
	 * @param data
	 */
	public static double keogh(Instances data, int sampleSize) {
		double share = 1, searchTime = 0;
		long start, stop;
		WindowSearcher classifier = new WindowSearcher(datasetName);
		classifier.setResDir(resDir);
		classifier.setType(type);
		try{
			Instances newTrain = Sampling.sample(data, sampleSize);
			System.out.println("Size: " + sampleSize + ", Launching Keogh");
			if (sampleSize < estimate+1) {
				start = System.nanoTime();
				classifier.buildClassifier(newTrain);
				stop = System.nanoTime();
			} else {
				start = System.nanoTime();
				classifier.buildClassifierEstimate(newTrain, estimate);
				stop = System.nanoTime();
				share = 1.0 * (estimate+1) / newTrain.numInstances();
			}
			searchTime = 1.0 * ((stop - start)/1e9);
			searchTime = searchTime/share;
			saveSearchTime(sampleSize, searchTime);
			System.out.println("Size: " + sampleSize + ", " + searchTime + " s");
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return searchTime;
	}

	/**
	 * Run KDD12 method 
	 * @param data
	 */
	public static void kdd12(Instances data) {
		System.out.println("KDD12");

		double[] timeTaken = new double[sampleTrains.length];
		int i = 0;
		for (int sampleSize : sampleTrains) {
			double searchTime = kdd12(data, sampleSize);
			timeTaken[i++] = searchTime;
		}
	}

	/** 
	 * Run KDD12 method for a given size
	 * @param data
	 * @param sampleSize
	 * @return
	 */
	public static double kdd12(Instances data, int sampleSize) {
		double share = 1, searchTime = 0;
		long start, stop;
		try{
			Instances newTrain = Sampling.sample(data, sampleSize);
			System.out.println("Size: " + sampleSize + ", Launching KDD12");
			if (sampleSize < estimate+1) {
				KDD12 classifier = new KDD12(datasetName);
				classifier.setResDir(resDir);
				classifier.setType(type);
				start = System.nanoTime();
				classifier.buildClassifier(newTrain);
				stop = System.nanoTime();
			} 
			else {
				KDD12 classifier = new KDD12(datasetName);
				classifier.setResDir(resDir);
				classifier.setType(type);
				start = System.nanoTime();
				classifier.buildClassifierEstimate(newTrain, estimate);
				stop = System.nanoTime();
				share = 1.0 * (estimate+1) / newTrain.numInstances();
				System.out.println("Share: " + share);
			}
			searchTime = 1.0 * ((stop - start)/1e9);
			searchTime = searchTime/share;
			saveSearchTime(sampleSize, searchTime);
			System.out.println("Size: " + sampleSize + ", " + searchTime + " s");

		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return searchTime;
	}

	/**
	 * Run SDM16 method
	 * @param data
	 */
	public static void sdm16(Instances data) {
			System.out.println("SDM16");

			double[] timeTaken = new double[sampleTrains.length];
			int i = 0;
			for (int sampleSize : sampleTrains) {
				double searchTime = sdm16(data, sampleSize);
				timeTaken[i++] = searchTime;
			}
	}

	/** 
	 * Run SDM16 method for a given size
	 * @param data
	 * @param sampleSize
	 * @return
	 */
	public static double sdm16(Instances data, int sampleSize) {
		double share = 1, searchTime = 0;
		long start, stop;
		SDM16 classifier = new SDM16(datasetName);
		classifier.setResDir(resDir);
		classifier.setType(type);
		try{
			Instances newTrain = Sampling.sample(data, sampleSize);

			System.out.println("Size: " + sampleSize + ", Launching SDM16");
			if (sampleSize < estimate+1) {
				start = System.nanoTime();
				classifier.buildClassifier(newTrain);
				stop = System.nanoTime();
			} 
			else {
				start = System.nanoTime();
				classifier.buildClassifierEstimate(newTrain, estimate);
				stop = System.nanoTime();
				share = 1.0 * (estimate+1) /newTrain.numInstances();
			}
			searchTime = 1.0 * ((stop - start)/1e9);
			searchTime = searchTime/share;
			saveSearchTime(sampleSize, searchTime);
			System.out.println("Size: " + sampleSize + ", " + searchTime + " s");
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return searchTime;
	}
	
	/**
	 * Save results (search time) to csv
	 * @param searchTime
	 * @param error
	 */
	private static void saveSearchTime(int sampleSize, double searchTime) {
		String fileName = resDir + "scaling_result_" + type + ".csv";
		FileWriter out;
		boolean append = false;
		File file = new File(fileName);
		if (file.exists()) 
			append = true;
		try {
			out = new FileWriter(fileName, append);
			if (!append)
				out.append("SampleSize,SearchTime(s)\n");
			out.append(sampleSize + "," + searchTime + "\n");
			out.flush();
	        out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
