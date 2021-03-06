package cz.cas.mbu.genexpi.compute;

import java.io.IOException;
import java.util.List;

import com.nativelibs4java.opencl.CLContext;

public class AdditiveRegulationInferenceEngine<NUMBER_TYPE extends Number> extends OneWeightPerRegulatorInferenceEngine<NUMBER_TYPE>{

	public AdditiveRegulationInferenceEngine(Class<NUMBER_TYPE> elementClass, CLContext context, EMethod method,
			EErrorFunction errorFunction, ELossFunction lossFunction, boolean useCustomTimeStep, Float customTimeStep,
			boolean verbose, int numIterations, boolean preventFullOccupation, int numRegulators,
			float regularizationWeight, boolean useConstitutiveExpression, boolean useFixedSeed, long fixedSeed)
			throws IOException {
		super(elementClass, context, 
				InferenceModel.createAdditiveRegulationModel(numRegulators, useConstitutiveExpression), 
				method, errorFunction, lossFunction, useCustomTimeStep, customTimeStep, verbose,
				numIterations, preventFullOccupation, numRegulators, regularizationWeight, useConstitutiveExpression,
				useFixedSeed, fixedSeed);
		// TODO Auto-generated constructor stub
	}

	
			
		
}
