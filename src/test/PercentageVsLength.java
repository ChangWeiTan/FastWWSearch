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
package test;

import items.ExperimentsLauncher;
import weka.classifiers.Evaluation;
import weka.core.Instances;
import windowSearcher.FastWWS;
import windowSearcher.FastWWSByPercent;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Code for the paper "Efficient search of the best warping window for Dynamic Time Warping" published in SDM18
 * <p>
 * Experiment to search for the best warping window using our proposed method for SDM18
 *
 * @author Chang Wei Tan
 */
public class PercentageVsLength {
    private static final String projectName = "FastWWSearch";
    private static String osName, datasetName, username, projectPath, datasetPath, resDir, sampleType, method;
    private static int bestWW, bestWW2;
    private static int bestPP, bestPP2;
    private static double bestScore, bestScore2;
    private static int nbRuns = 1;

    public static void main(String[] args) throws Exception {
        // Initialise
        sampleType = "Single";
        datasetName = "ECG200";        // Name of dataset to be tested

        // Get project and dataset path
        osName = System.getProperty("os.name");
        username = System.getProperty("user.name");
        if (osName.contains("Window")) {
            projectPath = "C:/Users/" + username + "/workspace/" + projectName + "/";
            if (sampleType.equals("New"))
                datasetPath = "C:/Users/" + username + "/workspace/Dataset/TSC_Problems/";
            else
                datasetPath = "C:/Users/" + username + "/workspace/Dataset/UCR_Time_Series_Archive/";
        } else {
            projectPath = "/home/" + username + "/workspace/" + projectName + "/";
            if (sampleType.equals("New"))
                datasetPath = "/home/" + username + "/workspace/Dataset/TSC_Problems/";
            else
                datasetPath = "/home/" + username + "/workspace/Dataset/UCR_Time_Series_Archive/";
        }

        // Get arguments
        if (args.length >= 1) projectPath = args[0];
        if (args.length >= 2) datasetPath = args[1];
        if (args.length >= 3) sampleType = args[2];
        if (sampleType.equals("Single") && args.length >= 4) {
            datasetName = args[3];
            if (args.length >= 5) nbRuns = Integer.parseInt(args[4]);
        } else if (args.length >= 4) {
            nbRuns = Integer.parseInt(args[3]);
        }

        if (sampleType.equals("Single"))
            System.out.println("Find best warping window on " + datasetName + " dataset -- " + nbRuns + " runs");
        else
            System.out.println("Find best warping window on " + sampleType + " dataset -- " + nbRuns + " runs");

        // Run the comparison
        singleProblem(datasetName);

    }// End main

    /**
     * Running the experiment for a single dataset
     *
     * @param datasetName dataset name
     * @throws Exception e
     */
    private static void singleProblem(String datasetName) throws Exception {
        // Setting output directory
        resDir = projectPath + "outputs/Tests/" + datasetName + "/";

        // Check if it exist, else create the directory
        File dir = new File(resDir);
        if (!dir.exists())
            dir.mkdirs();

        // Reading the dataset
        System.out.println("Processing: " + datasetName);
        Instances[] data = ExperimentsLauncher.readTrainAndTest(datasetPath, datasetName);

        Instances train = data[0];
        Instances test = data[1];

        // FastWWS by percentage
        method = "FastWWSPer-Percentage";
        System.out.println("Launching FastWWS By Percentage");
        FastWWSByPercent classifierByPercent = new FastWWSByPercent(datasetName);
        classifierByPercent.setResDir(resDir);
        classifierByPercent.setType(method);

        long startPercent = System.nanoTime();
        classifierByPercent.buildClassifier(train);
        long stopPercentage = System.nanoTime();
        double searchTimePercent = (stopPercentage - startPercent) / 1e9;
        System.out.println(searchTimePercent + " s");

        bestWW2 = classifierByPercent.getBestWin();
        bestPP2 = classifierByPercent.getBestPercent();
        bestScore2 = classifierByPercent.getBestScore();

        Evaluation evalByPercent = new Evaluation(train);
        evalByPercent.evaluateModel(classifierByPercent, test);
        System.out.println(evalByPercent.errorRate());

        // FastWWS by length
        method = "FastWWSearch";
        System.out.println("Launching FastWWS");
        FastWWS classifier = new FastWWS(datasetName);
        classifier.setResDir(resDir);
        classifier.setType(method);

        // Training the classifier for best window
        long start = System.nanoTime();
        classifier.buildClassifier(train);
        long stop = System.nanoTime();
        double searchTime = (stop - start) / 1e9;
        System.out.println(searchTime + " s");

        bestWW = classifier.getBestWin();
        bestPP = classifier.getBestPercent();
        bestScore = classifier.getBestScore();

        // Evaluate the trained classfier with test set
        Evaluation eval = new Evaluation(train);
        eval.evaluateModel(classifier, test);
        System.out.println(eval.errorRate());

        // Save result
        saveSearchTime(eval.errorRate(), evalByPercent.errorRate());
    }

    /**
     * Save results (search time) to csv
     */
    private static void saveSearchTime(double error, double error2) {
        String fileName = resDir + datasetName + "_result_" + method + ".csv";
        FileWriter out;
        boolean append = false;
        File file = new File(fileName);
        if (file.exists())
            append = true;
        try {
            out = new FileWriter(fileName, append);
            if (!append)
                out.append("Method,Win(Length),Win(Percent),CV Acc,Test Error\n");
            out.append("FastWWS," + bestWW + "," + bestPP + "," + bestScore + "," + error + "\n");
            out.append("FastWWS by Percentage," + bestWW2 + "," + bestPP2 + "," + bestScore2 + "," + error2 + "\n");
            out.flush();
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
