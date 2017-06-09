function [cmap, param, codewords] = myBoW(fmap, param, codewords)

% my Bag-of-visual-word algorithm
% 

% input feature maps
if ~iscell(fmap)
    error('Feature map should be cell type');
end

nmap = length(fmap);

finfo = zeros(nmap,4);
for fidx = 1:nmap
    [R,C,D] = size(fmap{fidx});
    finfo(fidx,:) = [R,C,R*C,D];
end
   
if length(unique(finfo(:,4)))~=1
    error('Feature depth mismatch');
else
    D = finfo(1,4);
end


if nargin < 3
    % aggregate feature
    features = zeros(sum(finfo(:,3)), D);
    for fidx = 1:nmap
        features(sum(finfo(1:fidx-1,3))+1:sum(finfo(1:fidx,3)),:) = ...
            reshape(fmap{fidx}, [finfo(fidx,3) D]);
    end
    features = features';   % column-wise features


    % feature sampling
    if isfield(param, 'featureSampling')
        features = features(:,randi(size(features,2), [1,param.featureSampling]));
    end

    % kmeans
    codewords = vl_kmeans(features, param.nc, 'Initialization', 'plusplus', 'MaxNumIterations', param.MaxNumIterations);
%     codewords = vgg_kmeans(features, param.nc, param.kmeans);
end




% find NN
kdtree = vl_kdtreebuild(codewords);
cmap = cell(nmap,1);
for fidx = 1:nmap
    featuresToBeDetermined = reshape(double(fmap{fidx}), [finfo(fidx,3) D]);    
    nn = vl_kdtreequery(kdtree, codewords, featuresToBeDetermined');
    cmap{fidx} = reshape(nn, [finfo(fidx,1) finfo(fidx,2)]);
end


end
