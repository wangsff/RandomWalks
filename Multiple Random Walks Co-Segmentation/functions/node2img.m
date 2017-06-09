function [seg, sal] = node2img(DB, oznode, pbnode)

nImg = length(oznode);


%% segmentation map
seg = cell(nImg,1);

for iIdx = 1:nImg
    seg{iIdx} = double(ismember(DB(iIdx).sp_map, find(oznode{iIdx}(:,1)==1)));
end


%% saliency map
if nargout > 1
    sal = cell(nImg,1);
    
    for iIdx = 1:nImg
    
        sal{iIdx} = zeros(DB(iIdx).R, DB(iIdx).C);
        for i=1:DB(iIdx).nsp
            sal{iIdx}(DB(iIdx).sp_idx{i}) = pbnode{iIdx}(i,1);
        end
        % normalization
        sal{iIdx} = mat2gray(sal{iIdx});
    end
end


end