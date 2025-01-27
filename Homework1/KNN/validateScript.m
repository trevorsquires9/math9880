clearclear
clc 
close all;

rng(15)

imds = imageDatastore('../ProcessedImages','IncludeSubfolders',true,'LabelSource','foldernames');
nImg = length(imds.Files);
trials = 2500;
n = 15;
ind = randi(nImg,trials,1);
confusionMat = zeros(2);


for i=1:trials
    A = readimage(imds,ind(i));
    bestVal = inf*ones(n,1);
    bestInd = zeros(n,1);
    for j = 1:nImg
        if ind(i)~=j
            tmp = readimage(imds,j);
            tmpMat = double(A)-double(tmp);
            diff = norm(tmpMat(:));
            [maxVal,maxLoc] = max(bestVal);
            if diff < maxVal
                bestVal(maxLoc) = diff;
                bestInd(maxLoc) = j;
            end
        end
    end
    pred = round(mean(imds.Labels(bestInd) == imds.Labels(ind(i))));
    confusionMat(imds.Labels(ind(i)),pred+1) = confusionMat(imds.Labels(ind(i)),pred+1)+1;

end
save('knnResults','confusionMat')
