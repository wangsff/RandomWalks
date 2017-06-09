function [fDistAll, fDistNormAll] = calcFdist(D_inter, oznode, nv)

nImg = length(nv);

fDist = zeros(nImg,nImg);
fDistNorm = zeros(nImg,nImg);
for j=1:nImg
    for i=1:nImg
        if j==i
            continue
        end
        tmp = D_inter{j,i};
        tmp(oznode{j}(:,1)==0,:) = 0; % from foreground nodes in img j
        tmp = tmp(:,oznode{i}(:,1)==1); % to foreground nodes in img i
        
        mintmpDist = min(tmp,[],2);

        fDist(j,i) = mean(mintmpDist);
        fDistNorm(j,i) = sum(mintmpDist) / sum(oznode{j}(:,1));
    end
end

fDistAll = mean(sum(fDist,2));
fDistNormAll = mean(sum(fDistNorm,2));

end