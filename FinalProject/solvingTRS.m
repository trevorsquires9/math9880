%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solves Trust Region subproblem various through various optimization
% techniques.
%
% Author
%   Trevor Squires
%
% Details
%   Solves TRS via 4 different approaches:
%   - SDP reformulation
%   - Convex reformulation/relaxation
%   - Stochastic gradient descent
%   - Double-Start FOCM (Beck)
%
% Notes
%   - Output is not correct
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [conRef,beck,sgd,sdp] = solvingTRS(A,b,dim,conParam,beckParam,sgdParam,sdpParam)
%% Problem setting

% Instance parameters
eigMin = min(eig(A));
L = norm(A,2);
fixedL = norm(A-eigMin*eye(dim),2);

% Function Setup
f = @(x) 0.5*x'*A*x + b'*x;
gradf = @(x) A*x+b;
g = @(x) f(x) - 0.5*eigMin*norm(x,2)^2;
gradg = @(x) gradf(x) + eigMin*x;


%% TRS via convex reformulation
tic;
maxIt = defaultField(conParam,'maxIt',100);
x = zeros(dim,maxIt);
objVal = zeros(maxIt,1);

x(:,1) = randn(dim,1);
x(:,1) = x(:,1)/norm(x(:,1),2);
objVal(1) = f(x(:,1));

for i = 2:maxIt
    x(:,i) = x(:,i-1) - 1/(fixedL)*gradg(x(:,i-1));
    tmp = norm(x(:,i));
    if tmp > 1
        x(:,i) = x(:,i)/tmp;
    end
    objVal(i) = f(x(:,i));
end
solu = x(:,end);

% Minimizer is the same as the original problem, but objective value is
% not. Need to use different objective function for comparions.
optVal = f(solu);

% Store useful variables in a structure
conRef.time = toc;
conRef.objVal = objVal;
conRef.x = x;
conRef.solu = solu;
conRef.optVal = optVal;

%% TRS via Beck paper
tic;
maxIt = defaultField(beckParam,'maxIt',100);
x = zeros(dim,maxIt);
y = zeros(dim,maxIt);
objValX = zeros(maxIt,1);
objValY = zeros(maxIt,1);

% First pass
y(:,1) = randn(dim,1);
y(:,1) = y(:,1)/norm(y(:,1),2);
objValY(1) = f(y(:,1));
for i = 2:maxIt
    y(:,i) = y(:,i-1) - 1/L*gradf(y(:,i-1));
    tmp = norm(y(:,i));
    if tmp > 1
        y(:,i) = y(:,i)/tmp;
    end
    objValY(i) = f(y(:,i));
end
soluY = y(:,end);

% Second pass
x(:,1) = zeros(dim,1);
objValX(1) = f(x(:,1));
for i = 2:maxIt
    x(:,i) = x(:,i-1) - 1/L*gradf(x(:,i-1));
    tmp = norm(x(:,i));
    if tmp > 1
        x(:,i) = x(:,i)/tmp;
    end
    objValX(i) = f(x(:,i));
end
soluX = x(:,end);

% Store useful objects in structure
beck.time = toc;
beck.objValX = objValX;
beck.objValY = objValY;

% Pick best solution
if f(soluX)<f(soluY)
    beck.x = x;
    beck.solu = soluX;
    beck.optVal = f(soluX);
else
    beck.x = y;
    beck.solu = soluY;
    beck.optVal = f(soluY);
end

%% TRS via Stochastic Gradient Descent
tic;
maxIt = defaultField(sgdParam,'maxIt',100);
miniBatchProp = defaultField(sgdParam,'miniBatchProp',0.2);
miniBatchSize = ceil(dim*miniBatchProp);


x = zeros(dim,maxIt);
objVal = zeros(maxIt,1);

x(:,1) = randn(dim,1);
x(:,1) = x(:,1)/norm(x(:,1),2);
objVal(1) = f(x(:,1));

for i = 2:maxIt
    %Compute partial gradient
    miniBatchInd = randi(dim,miniBatchSize,1);
    partialGrad = b;
    for j = 1:miniBatchSize
        partialGrad = partialGrad + A(:,miniBatchInd(j))*x(miniBatchInd(j),i-1);
    end
    %Update using partial gradient
    x(:,i) = x(:,i-1) - 1/(L)*partialGrad;
    tmp = norm(x(:,i));
    if tmp > 1
        x(:,i) = x(:,i)/tmp;
    end
    objVal(i) = f(x(:,i));
end
solu = x(:,end);

% Store useful objects in structures
sgd.time = toc;
sgd.objVal = objVal;
sgd.x = x;
sgd.solu = solu;
sgd.optVal = min(objVal);

%% TRS via Semidefinite Reformulation
run = defaultField(sdpParam,'run',0);
if run
    tic;
    A = 0.5*A;
    C = [0 0.5*b'; 0.5*b A];
    Q1 = [0 zeros(1,dim); zeros(dim,1) eye(dim)];
    Q2 = [1 zeros(1,dim); zeros(dim,1) zeros(dim)];
    
    cvx_begin sdp quiet
        variable T(dim+1,dim+1) semidefinite symmetric
        minimize(trace(C*T))
        subject to
        trace(Q1*T) == 1
        trace(Q2*T) == 1
    cvx_end
    sdp.time = toc;
    sdp.solu = T(2:end,1);
    sdp.optVal = cvx_optval;
else
    sdp = [];
end