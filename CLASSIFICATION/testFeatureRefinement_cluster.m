% This code for developing feature refinement method
clear all
addpath('../SUPPORTFILES/');

% list of each class
% -------------------------------------------------------------------------
% 1. hard surface
% 2. soft surface
class{1} = {'bricks','cement','metal','tarmac','wood'};
class{2} = {'grass', 'sand', 'soil'};

% list of features
% -------------------------------------------------------------------------
intensity = 1:5;
runlength = 6:16;
glcmprop  = 17:23;
wavelet   = 24:135;
wavelet   = [wavelet(1:8) wavelet(17:64)]; % use only magnitude
waveletglcm = 136:142;
waveletrun  = 143:153;
lbphist   = 154:212;

selectedFeatures{1} = [wavelet lbphist];
selectedFeatures{2} = [wavelet];
selectedFeatures{3} = [lbphist];
selectedFeatures{4} = [intensity wavelet]; %**best performance
selectedFeatures{5} = [intensity lbphist];
selectedFeatures{6} = [intensity wavelet lbphist]; %**best performance
selectedFeatures{7} = [wavelet waveletrun];
selectedFeatures{8} = [wavelet waveletrun lbphist];
selectedFeatures{9} = [intensity runlength glcmprop wavelet lbphist];
selectedFeatures{10} = [intensity runlength glcmprop wavelet waveletrun lbphist];
% test wavelet 3 levels
selectedFeatures{11} = [wavelet(1:3) wavelet(5:7) wavelet(9:26) wavelet(33:50)];
% test wavelet only mean all subband
selectedFeatures{12} = [wavelet(1:8)];

%% CASE II randomly choose training set, testing 100 images from the same terrain type

usePCA = 1;
plot12 = 1;
numIteration = 100;
maxNumTrain = 200;
maxNumTest = 100;
maxNumFeatures = 12;
testType = {'grass','bricks','sand','soil','tarmac'};
ft = 6;

% classification process
% -------------------------------------------------------------------------
accK    = zeros(length(testType),maxNumTest);
accKQ = zeros(length(testType),maxNumTest);
computeTime = zeros(length(testType),maxNumTest);
for testnum = 1:length(testType)
    curTestName = testType{testnum};
    fprintf('%25s :\n',curTestName);
    accKAll    = zeros(numIteration,maxNumTest);
    accKAllQ = zeros(numIteration,maxNumTest);
    computeTimeAll  = zeros(numIteration,maxNumTest);
    
    for it = 1:numIteration
        fprintf('%2d ',it);
        
        % data from class 1
        trainingData = [];
        testingData = [];
        trainingLabels = [];
        testingLabels = [];
        for numClass = 1:2
            for c1 = 1:length(class{numClass})
                terraintype = class{numClass}{c1};
                featureMatrix = dlmread(['C:\Locomotion\results\code_motion\forTraining\features\',terraintype,'far.txt']);
                featureMatrix = featureMatrix(:,2:end); % remove index order
                % get selected features
                featureMatrix = featureMatrix(:,selectedFeatures{ft});
                featureMatrix(isnan(featureMatrix)) = 0;
                totalSamples = size(featureMatrix,1);
                % choose testing images
                testingSet = zeros(1,totalSamples);
                if strcmpi(terraintype,curTestName)
                    firstIndTest = randi(totalSamples,1,1);
                    lastInd = min(totalSamples,firstIndTest+maxNumTest-1);
                    testingSet(firstIndTest:lastInd) = 1;
                    if sum(testingSet)<maxNumTest
                        lastInd = maxNumTest-sum(testingSet);
                        testingSet(1:lastInd) = 1;
                    end
                    featureMatrixTest = featureMatrix;
                    testingData  = [testingData; featureMatrix(testingSet>0,:)];
                    testingLabels  = [testingLabels;  numClass*ones(sum(testingSet),1)];
                end
                % randomly choose samples for training
                numTraining = min(maxNumTrain,totalSamples);
                trainingSet = zeros(1,totalSamples);
                while sum(trainingSet)<numTraining
                    updateInd = randi(totalSamples,1, max(5,(numTraining-sum(trainingSet))));
                    trainingSet(updateInd) = 1;
                    trainingSet(testingSet>0) = 0;
                end
                % gather with other types
                trainingData = [trainingData; featureMatrix(trainingSet>0,:)];
                trainingLabels = [trainingLabels; numClass*ones(sum(trainingSet),1)];
                % update available testing set
                testingSet(trainingSet>0) = 1;
            end
        end
        
        % loop add testing image to training
        allIndx = 1:length(testingLabels);
        for k = 1:maxNumTest
            
            tic
            % add k-th test to train
            if k>1
                % random select the added train image
                curind = randi(length(allIndx),1,1);
                allIndx(curind) = [];
                % train features
                trainingData = [trainingData; testingData(curind,:)];
                trainingLabels = [trainingLabels; testingLabels(curind,:)];
                testingData(curind,:) = [];
                testingLabels(curind,:) = [];
                % add new testing for fair calculation of accuracy
                if (sum(testingSet==0)>0)
                    testToAdd = 0;
                    while (testToAdd==0)
                        lastInd = lastInd + 1;
                        if lastInd > size(featureMatrixTest,1)
                            lastInd = 1;
                        end
                        if testingSet(lastInd)==0
                            testToAdd = 1;
                            testingSet(lastInd) = 1;
                            testingData = [testingData; featureMatrixTest(lastInd,:)];
                            testingLabels = [testingLabels; testingLabels(1)];
                        end
                    end
                else
                    curind = randi(size(featureMatrixTest,1),1,1);
                    testingData = [testingData; featureMatrixTest(curind,:)];
                    testingLabels = [testingLabels; testingLabels(1)];
                end
            end
            
            % usePCA
            if usePCA
                shiftdata = mean(trainingData);
                [coef,score,latent] = princomp(trainingData - repmat(shiftdata,[length(trainingLabels) 1]));
                dimchoose = 1:min(length(selectedFeatures{ft}),maxNumFeatures);%(cumsum(latent)./sum(latent))<0.999;
                trainingDataCur = score(:,dimchoose);
                % testing
                scoretesting = (testingData - repmat(shiftdata,[length(testingLabels) 1]))*coef;
                testingDataCur = scoretesting(:,dimchoose);
            end
            
            % Discriminant analysis classifier
            % -------------------------------------------------------------------------
            % normalisation dataset
            data = trainingDataCur;
            scaling1 = min(data,[],1);
            scaling2 = 1./(max(data,[],1)-min(data,[],1));
            trainingDataCur = (data - repmat(scaling1,size(data,1),1)).*(repmat(scaling2,size(data,1),1));
            % modelling
            % 'linear' � Estimate one covariance matrix for all classes.
%             mdl = ClassificationDiscriminant.fit(trainingDataCur,trainingLabels);
            % 'quadratic' � Estimate one covariance matrix for each class.
            mdlQ = ClassificationDiscriminant.fit(trainingDataCur,trainingLabels,'discrimType','quadratic');
            mdlQ.Prior(testingLabels(1)) = mdlQ.Prior(testingLabels(1))*2;
            
            % Testing
            % -------------------------------------------------------------------------
            % normalisation dataset
            data = testingDataCur;
            testingDataCur = (data - repmat(scaling1,size(data,1),1)).*(repmat(scaling2,size(data,1),1));
%             predictLabels = predict(mdl,testingDataCur);
%             accKcur = mean(predictLabels==testingLabels)*100;
            predictLabels = predict(mdlQ,testingDataCur);
            accKcurQ = mean(predictLabels==testingLabels)*100;
            
            % record results
            % -------------------------------------------------------------------------
            computeTimeAll(it,k) = toc;
%             accKAll(it,k) = accKcur;
            accKAllQ(it,k) = accKcurQ;
        end
    end
    fprintf('\n');
    computeTime(testnum,:) = mean(computeTimeAll);
%     accK(testnum,:) = mean(accKAll);
    accKQ(testnum,:) = mean(accKAllQ);
end