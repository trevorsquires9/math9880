clear
clc
close all;

cd LinuxCVX
cd cvx
cvx_setup
cd ..
cd ..

%% Multiple Trial Run
clear
clc

% Algorithm Parameters
it = 200;
dim = 35;
convexParam.maxIt = it;
beckParam.maxIt = it;
sgdParam.epochs = it;
sgdParam.miniBatchProp = 1/4;
sgdParam.maxIt = ceil(sgdParam.epochs/sgdParam.miniBatchProp);
trials = 50000;

% Algorithm Instances
optVals = zeros(trials,3);
for j = 1:trials
    A = rand(dim);
    A = A+A';
    b = zeros(dim,1);
    [convex, beck, sgd] = solvingTRS(A,b,dim,convexParam,beckParam,sgdParam,[]);
    optVals(j,:) = [convex.optVal,beck.optVal,sgd.optVal];
end
relError = abs(optVals(:,1)-optVals(:,3))./abs(optVals(:,1));
worstErr = max(relError);
save('ErrorAnalysis','relError','worstErr')

%% Large Dimension Run
clear
clc

% Algorithm Parameters
it = 70;
dim = [10,25,50,100,250,500,750,1000];
timings = zeros(length(dim),4);
convexParam.maxIt = it;
beckParam.maxIt = it;
sgdParam.epochs = it;
sgdParam.miniBatchProp = 1/4;
sgdParam.maxIt = ceil(sgdParam.epochs/sgdParam.miniBatchProp);
sdpParam.run = 1;
 
for i = 1:length(dim)
    A = rand(dim(i));
    A = A+A';
    b = zeros(dim(i),1);
    
    [convex, beck, sgd, sdp] = solvingTRS(A,b,dim(i),convexParam,beckParam,sgdParam,sdpParam);
    timings(i,:) = [convex.time, beck.time,sgd.time,sdp.time];
end
save('Timings','timings')
