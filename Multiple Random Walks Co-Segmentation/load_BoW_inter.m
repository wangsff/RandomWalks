function [hist_sift, hist_lab, hist_text] = load_BoW_inter(DB, param)


nImg = length(DB);


% BoW: sift
fmap = cell(1,nImg);
for jIdx = 1:nImg
    fmap{jIdx} = DB(jIdx).sift;
end
if ~exist(fullfile(param.dir.result_class, 'BoW_inter_sift.mat'), 'file')
    tic;    
    [cmap_sift, param.BoW_inter, cw_sift] = myBoW(fmap, param.BoW_inter);

    hist_sift = cell(nImg,1);
    for jIdx =1:nImg
        hist = zeros(DB(jIdx).nsp, param.BoW_inter.nc);
        for j=1:DB(jIdx).nsp
            sp_idx = DB(jIdx).sp_idx{j};
            hist(j,:) = histc(cmap_sift{jIdx}(sp_idx), 1:param.BoW_inter.nc);
        end
        hist_sift{jIdx} = hist;
    end
    eval.time = toc;

    save(fullfile(param.dir.result_class, 'BoW_inter_sift.mat'), 'cw_sift', 'hist_sift', 'eval');
else
    load(fullfile(param.dir.result_class, 'BoW_inter_sift.mat'));
end


% BoW: lab
fmap = cell(1,nImg);
for jIdx = 1:nImg
    fmap{jIdx} = DB(jIdx).lab;
end
if ~exist(fullfile(param.dir.result_class, 'BoW_inter_lab.mat'), 'file')
    tic;
    [cmap_lab, param.BoW_inter, cw_lab] = myBoW(fmap, param.BoW_inter);

    hist_lab = cell(nImg,1);
    for jIdx =1:nImg
        hist = zeros(DB(jIdx).nsp, param.BoW_inter.nc);
        for j=1:DB(jIdx).nsp
            sp_idx = DB(jIdx).sp_idx{j};
            hist(j,:) = histc(cmap_lab{jIdx}(sp_idx), 1:param.BoW_inter.nc);
        end
        hist_lab{jIdx} = hist;
    end
    eval.time = toc;

    save(fullfile(param.dir.result_class, 'BoW_inter_lab.mat'), 'cw_lab', 'hist_lab', 'eval');
else
    load(fullfile(param.dir.result_class, 'BoW_inter_lab.mat'));
end


% BoW: texton
fmap = cell(1,nImg);
for jIdx = 1:nImg
    fmap{jIdx} = double(DB(jIdx).gray);
end

GSS = td_fastSelfSim;

GSS.numberClusters = param.BoW_inter.nc;
GSS.clusteringMethod = 1;
GSS.clusteringPatchesNumber = param.BoW_inter.featureSampling;

if ~exist(fullfile(param.dir.result_class, 'BoW_inter_text.mat'), 'file')
    tic;    
    GSS = GSS.getClustersFromPixels(fmap);
    cw_text = GSS.CX;

    cmap_text = cell(nImg,1);
    for jIdx = 1:nImg
        cmap_text{jIdx} = GSS.quantise(double(DB(jIdx).gray));
    end

    hist_text = cell(nImg,1);
    for jIdx =1:nImg
        hist = zeros(DB(jIdx).nsp, param.BoW_inter.nc);
        for j=1:DB(jIdx).nsp
            sp_idx = DB(jIdx).sp_idx{j};
            hist(j,:) = histc(cmap_text{jIdx}(sp_idx), 1:param.BoW_inter.nc);
        end
        hist_text{jIdx} = hist;
    end
    eval.time = toc;

    save(fullfile(param.dir.result_class, 'BoW_inter_text.mat'), 'cw_text', 'hist_text', 'eval');
else
    load(fullfile(param.dir.result_class, 'BoW_inter_text.mat'));
end
        
