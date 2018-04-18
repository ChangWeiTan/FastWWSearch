package classifiers;

import items.MonoDoubleItemSet;
import sequences.SymbolicSequence;
import weka.core.Attribute;
import weka.core.Instance;
import weka.core.Instances;

import java.util.ArrayList;
import java.util.HashMap;

public class NNDTW {
    protected double[] U, L;
    protected SymbolicSequence[] train;
    protected HashMap<String, ArrayList<SymbolicSequence>> classedData;        // Sequences by classes
    protected HashMap <String, ArrayList <Integer>> classedDataIndices;        // Sequences index in train
    protected String[] classMap;
    protected double[][] warpingMatrix;
    protected int maxLength;

    public double classifyInstance(Instance sample, int w) {
        // transform instance to sequence
        MonoDoubleItemSet[] sequence = new MonoDoubleItemSet[sample.numAttributes() - 1];
        int shift = (sample.classIndex() == 0) ? 1 : 0;
        for (int t = 0; t < sequence.length; t++) {
            sequence[t] = new MonoDoubleItemSet(sample.value(t + shift));
        }
        SymbolicSequence seq = new SymbolicSequence(sequence);

        double minD = Double.MAX_VALUE;
        String classValue = null;
        seq.LB_KeoghFillUL(w, U, L);

        for (int i = 0; i < train.length; i++) {
            SymbolicSequence s = train[i];
            if (SymbolicSequence.LB_KeoghPreFilled(s, U, L) < minD) {
                double tmpD = seq.DTW(s, w, warpingMatrix);
                if (tmpD < minD) {
                    minD = tmpD;
                    classValue = classMap[i];
                }
            }
        }
        // System.out.println(prototypes.size());
        return Double.parseDouble(classValue);
    }

    public void setTrain(Instances data) {
        Attribute classAttribute = data.classAttribute();
        classedData = new HashMap <>();
        classedDataIndices = new HashMap <>();
        for (int c = 0; c < data.numClasses(); c++) {
            classedData.put(data.classAttribute().value(c), new ArrayList <SymbolicSequence>());
            classedDataIndices.put(data.classAttribute().value(c), new ArrayList <Integer>());
        }

        train = new SymbolicSequence[data.numInstances()];
        classMap = new String[train.length];
        maxLength = 0;
        for (int i = 0; i < train.length; i++) {
            Instance sample = data.instance(i);
            MonoDoubleItemSet[] sequence = new MonoDoubleItemSet[sample.numAttributes() - 1];
            maxLength = Math.max(maxLength, sequence.length);
            int shift = (sample.classIndex() == 0) ? 1 : 0;
            for (int t = 0; t < sequence.length; t++) {
                sequence[t] = new MonoDoubleItemSet(sample.value(t + shift));
            }
            train[i] = new SymbolicSequence(sequence);
            String clas = sample.stringValue(classAttribute);
            classMap[i] = clas;
            classedData.get(clas).add(train[i]);
            classedDataIndices.get(clas).add(i);
        }

        warpingMatrix = new double[maxLength][maxLength];
        U = new double[maxLength];
        L = new double[maxLength];
    }
}
