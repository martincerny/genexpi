#Returns a boolean matrix. True -> can be fit by a constant profile
testConstant <- function(profilesMatrix, errorDef = defaultErrorDef() ) {
  errors = errorMargin(profilesMatrix, errorDef);
  minUpperBound = apply(profilesMatrix + errors, FUN = min, MARGIN = 1)
  maxLowerBound = apply(profilesMatrix - errors, FUN = max, MARGIN = 1)
  return(minUpperBound > maxLowerBound)
}

computeConstantSynthesis <- function(deviceSpecs, profilesMatrix, tasks = NULL, numIterations = 256, timeStep = NULL) {
  if(is.null(tasks)) {
    tasks = 1:(dim(profilesMatrix)[1]);
  }

  taskListR = list();
  for (i in 1:length(tasks))
  {
    #Create the inference tasks (move to 0-based indices in Java)
    taskListR[[i]] = .jnew(computeJavaType("NoRegulatorInferenceTask"), as.integer(tasks[i] - 1))
  }

  tasksJava <- .jarray(taskListR, contents.class = computeJavaType("NoRegulatorInferenceTask"));

  if(class(profilesMatrix) ==  "jobjRef") {
    profilesJava = profilesMatrix
  } else {
    profilesJava = geneProfilesFromMatrix(profilesMatrix)
  }

  if(is.null(timeStep)) {
    useCustomTimeStep = FALSE
    customTimeStep = .jfloat(-1.0)
  } else {
    useCustomTimeStep = TRUE
    customTimeStep = .jfloat(timeStep)
  }

  rInt = rinterfaceJavaType("RInterface");
  results = .jcall(rInt, paste0("[L",computeJavaType("InferenceResult"),";"),
                   "computeConstantSynthesis",
                   getJavaDeviceSpecs(deviceSpecs),
                   profilesJava,
                   tasksJava,
                   as.integer(numIterations),
                   useCustomTimeStep,
                   customTimeStep,

                   evalArray = FALSE);

  model = J(computeJavaType("InferenceModel"))$NO_REGULATOR;

  return( inferenceResultsToR(results, model, profilesMatrix, profilesJava, tasks, tasksJava, rClass = "constantSynthesisResult"));
}

evaluateConstantSynthesisResult <- function(constantSynthesisResult, targetTimePoints, timeStep) {
  if(class(constantSynthesisResult) != "constantSynthesisResult") {
    stop("Must provide an object of class 'constantSynthesisResult'");
  }
  rInt = rinterfaceJavaType("RInterface");
  results = J(rInt)$evaluateConstantSynthesisResult(constantSynthesisResult$profilesJava,
                                          constantSynthesisResult$tasksJava,
                                          constantSynthesisResult$resultsJava,
                                          as.numeric(0),
                                          as.numeric(targetTimePoints));
  return(.jevalArray(results, simplify = TRUE));
}

testConstantSynthesis <- function(constantSynthesisResults, errorDef = defaultErrorDef(), minFitQuality = 0.8, timeStep = NULL ) {
  profiles = constantSynthesisResults$profilesMatrix;

  if(is.null(timeStep)) {
    timeStep = 1
  }

  time = 0:(dim(profiles)[2] - 1);

  constantSynthesisEvaluated = evaluateConstantSynthesisResult(constantSynthesisResults, time, timeStep)

  constantSynthesisProfiles = logical(dim(profiles)[1])
  for(i in 1:length(constantSynthesisResults$tasks)) {
    profileIndex = constantSynthesisResults$tasks[i];
    if(fitQuality(profiles[profileIndex,], constantSynthesisEvaluated[i,], errorDef) >= minFitQuality) {
      constantSynthesisProfiles[profileIndex] = TRUE;
    }
  }

  return(constantSynthesisProfiles)
}
