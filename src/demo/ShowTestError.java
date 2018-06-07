package demo;

import classifiers.NNDTW;
import items.ExperimentsLauncher;
import tools.UCRArchive;
import weka.core.Attribute;
import weka.core.Instance;
import weka.core.Instances;
import windowSearcher.FastWWS;

import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;

public class ShowTestError {
    private static String osName, datasetName, username, projectPath, datasetPath, resDir, sampleType;
    private static int bestWarpingWindow;
    private static double bestScore;
    private static int nbRuns = 1;

    public static void main(String[] args) throws Exception {
        // Initialise
        sampleType = "Single";                // Doing just 1 dataset, can be Sorted, Small, New or All
        datasetName = "CinC_ECG_torso";    // Name of dataset to be tested

        // Get project and dataset path
        osName = System.getProperty("os.name");
        username = System.getProperty("user.name");
        if (osName.contains("Window")) {
            projectPath = "C:/Users/" + username + "/workspace/SDM18/";
            if (sampleType.equals("New"))
                datasetPath = "C:/Users/" + username + "/workspace/Dataset/TSC_Problems/";
            else
                datasetPath = "C:/Users/" + username + "/workspace/Dataset/UCR_Time_Series_Archive/";
        } else {
            projectPath = "/home/" + username + "/workspace/SDM18/";
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

        // Run the experiment depending on the given type
        switch (sampleType) {
            case "Sorted":
                for (int j = 0; j < UCRArchive.sortedDataset.length; j++) {
                    datasetName = UCRArchive.sortedDataset[j];
                    singleProblem(datasetName);
                }
                break;
            case "Small":
                for (int j = 0; j < UCRArchive.smallDataset.length; j++) {
                    datasetName = UCRArchive.smallDataset[j];
                    singleProblem(datasetName);
                }
                break;
            case "New":
                for (int j = 0; j < UCRArchive.newTSCProblems.length; j++) {
                    datasetName = UCRArchive.newTSCProblems[j];
                    singleProblem(datasetName);
                }
                break;
            case "All":
                File rep = new File(datasetPath);
                File[] listData = rep.listFiles(new FileFilter() {
                    @Override
                    public boolean accept(File pathname) {
                        return pathname.isDirectory();
                    }
                });
                Arrays.sort(listData);

                for (File dataRep : listData) {
                    datasetName = dataRep.getName();
                    singleProblem(datasetName);
                }
                break;
            case "Single":
                singleProblem(datasetName);
                break;
        }
    }

    private static void singleProblem(String datasetName) {
        // Setting output directory
        resDir = projectPath + "outputs/Test/";

        // Check if it exist, else create the directory
        File dir = new File(resDir);
        if (!dir.exists())
            dir.mkdirs();

        // Reading the dataset
        System.out.println("Processing: " + datasetName);
        Instances[] data = ExperimentsLauncher.readTrainAndTest(datasetPath, datasetName);

        Instances train = data[0];
        Instances test = data[1];
        System.out.println(train.numInstances());
        Attribute classAttribute = test.classAttribute();

        // Initialising the classifier
        System.out.println("Classifying dataset " + datasetName);
        NNDTW classifier = new NNDTW();
        classifier.setTrain(train);
        for (int w = 0; w < train.numAttributes()-1; w++) {
            double error = 0;
            for (int i = 0; i < test.numInstances(); i++) {
                Instance query = test.instance(i);
                double testClass = classifier.classifyInstance(query, w);
                double actualClass = Double.parseDouble(query.stringValue(classAttribute));
                if (actualClass != testClass) {
                    error++;
                }
            }
            error = error / test.numInstances();
            System.out.println(w + "," + error);
            saveOutput(resDir + datasetName + "_TestAcc.csv", w, error);
        }
    }

    private static void saveOutput(String filename, int win, double testError) {
        FileWriter out;
        boolean append = false;
        File file = new File(filename);
        if (file.exists())
            append = true;
        try {
            out = new FileWriter(filename, append);
            if (!append)
                out.append("Win,TestError\n");
            out.append(win + "," + testError + "\n");
            out.flush();
            out.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
