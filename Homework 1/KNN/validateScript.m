clear
clc 
close all;

imds = imageDatastore('../ProcessedImages','IncludeSubfolders',true,'LabelSource','foldernames');
nImg = length(imds.Files);
trials = 10;
n = 15;
ind = randi(nImg,trials,1);
count = 0;

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
    if pred
        count = count + 1;
    end
end

accuracy = count/trials;
