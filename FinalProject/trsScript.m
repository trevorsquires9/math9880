clear
clc
close all;

%% Visualizing nonconvexity
dim = 2;
A = diag([0 5]);
[q,~] = qr(randn(dim));
A = q'*A*q;
b = rand(dim,1);

f = @(x) 0.5*x'*A*x+b'*x;
dist = linspace(-1,1,100);
mesh = zeros(length(dist));
for i = 1:length(dist)
    for j= 1:length(dist)
        x = [dist(i);dist(j)];
        mesh(i,j) = f(x);
    end
end

surf(dist,dist,mesh)


%% Single Trial Run
clear
clc

% Algorithm Parameters
it = 100;
dim = 35;
convexParam.maxIt = it;
beckParam.maxIt = it;
sgdParam.epochs = it;
sgdParam.miniBatchProp = 1/4;
sgdParam.maxIt = ceil(sgdParam.epochs/sgdParam.miniBatchProp);

A = rand(dim);
A = A+A';
b = rand(dim,1);


[convex, beck, sgd,sdp] = solvingTRS(A,b,dim,convexParam,beckParam,sgdParam,[]);

% Generate output statistics/plots
figure();
subplot(2,2,1)
plot(1:convexParam.maxIt,convex.objVal)
xlabel('Iteration')
ylabel('Objective')
title('TRS Using Convex Reformulation')

subplot(2,2,2)
plot(1:beckParam.maxIt, beck.objValX)
hold on
plot(1:beckParam.maxIt, beck.objValY)
xlabel('Iteration')
ylabel('Objective')
title('TRS Using Double-Start FOCM')
legend('Starting at 0','Starting at random point','location','best')

subplot(2,2,3)
plot(1:sgdParam.maxIt,sgd.objVal)
xlabel('Iteration')
ylabel('Objective')
title('TRS Using Stochastic Projected Gradient Descent')