function [results, eval] = MRW_IS_CS( coImgAll, param )



% Reserve for results
results = struct('mname', {}, 'sal_map', {}, 'seg_map', {}, 'p', {}, 'q', {}, 'x', {}, ...
                    'peval', {}, 'etime', {}, 'niter', {});


% measure
eval.time = [];
eval.iter = [];


%% load data
[coImg, DB, param] = load_database(coImgAll, param);                    % load image features
[DSIM_intra, param] = load_dsim_intra(DB,param);                        % load dissimilarity matrix
[DSIM_intra_short, param] = load_dsim_intra_short(DB,param);            % load dissimilarity matrix
[DSIM_intra_full, param] = load_dsim_intra_full(DB,param);              % load dissimilarity matrix
[hist_sift, hist_lab, hist_text] = load_BoW_inter(DB,param);            % calculate BoW in advance


%% extra things
nImg = coImg.nImg;                                                      % the number of images
nv = zeros(nImg,1);                                                     % the number of vertices
for iIdx = 1:nImg
    nv(iIdx) = DB(iIdx).nsp;
end

img2node = zeros(sum(nv),nImg);
for i=1:nImg
    img2node(sum(nv(1:i-1))+1 : sum(nv(1:i)),i) = 1;
end

% mask
mask = zeros(sum(nv),5);
for i=1:nImg
    sp_top = unique(DB(i).sp_map(1,:));
    sp_bottom = unique(DB(i).sp_map(end,:));
    sp_left = unique(DB(i).sp_map(:,1)');
    sp_right = unique(DB(i).sp_map(:,end)');
    sp_boundary = unique([sp_top sp_bottom sp_left sp_right]);
    
    mask(sum(nv(1:i-1))+sp_top,1) = 1;
    mask(sum(nv(1:i-1))+sp_bottom,2) = 1;
    mask(sum(nv(1:i-1))+sp_left,3) = 1;
    mask(sum(nv(1:i-1))+sp_right,4) = 1;
    mask(sum(nv(1:i-1))+sp_boundary,5) = 1;
end


fprintf('--------------* Average Performance *-------------\n');


%% WAS for intra-image nodes
tic;
[~, A_intra, S_intra] = WAS_intra(DB, DSIM_intra, param);
eval.time = [eval.time toc];


%% WAS for intra-image nodes without boundary connections
tic;
[~, A_intra_short] = WAS_intra(DB, DSIM_intra_short, param);
eval.time = [eval.time toc];


%% WAS for intra-image nodes with fully connected edges
tic;
[~, A_intra_full] = WAS_intra(DB, DSIM_intra_full, param);
eval.time = [eval.time toc];


%% W for inter-image nodes
tic;
% BoW reweight and normalize
for jIdx = 1:nImg
    A_tmp = A_intra_short{jIdx,jIdx};
    
    hist_sift{jIdx} = A_tmp' * hist_sift{jIdx};
    hist_lab{jIdx} = A_tmp' * hist_lab{jIdx};
    hist_text{jIdx} = A_tmp' * hist_text{jIdx};
    
    if strcmp(param.hist_dist,'chisqr')
        hist_sift{jIdx} = diag(1./(sum(hist_sift{jIdx},2)+eps))*hist_sift{jIdx};       
        hist_lab{jIdx} = diag(1./(sum(hist_lab{jIdx},2)+eps))*hist_lab{jIdx};
        hist_text{jIdx} = diag(1./(sum(hist_text{jIdx},2)+eps))*hist_text{jIdx};   
    end
end

[~, A_inter, D_inter] = WAD_inter(DB, hist_sift, hist_lab, hist_text, param);

eval.time = [eval.time toc];


%% weight / affinity of co-images
tic;
Amat_intra = cell2mat(A_intra);

Amat_inter = cell(nImg,nImg);
for j=1:nImg
    for i=1:nImg
        if j==i
            Amat_inter{j,i} = A_intra_full{j,i}/(nImg+eps);
        else
            Amat_inter{j,i} = A_inter{j,i}/(nImg+eps);
        end
    end
end

SAmat = cell2mat(S_intra) * cell2mat(Amat_inter);

eval.time = [eval.time toc];


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MRW-IS (independent segmentation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
niter = zeros(nImg,1);
tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% initial setups
[p, x] = iniMRW([0.5 0.5], mask, img2node);
q = zeros(size(p));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Repulsive MRW Process
for iIdx = 1:nImg
    [pi, qi, xi, out] = RMRWP_single(p(ithimg(nv,iIdx),:), x(iIdx,:), A_intra{iIdx,iIdx}, param.MRW);
    
    p(ithimg(nv,iIdx),:) = pi;
    q(ithimg(nv,iIdx),:) = qi;
    x(iIdx,:) = xi;
    
    niter(iIdx) = out.iter;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save results
mIdx = 1;
results(mIdx).mname = 'MRW-IS';
results(mIdx).p = p;
results(mIdx).q = q;
results(mIdx).x = x;
results(mIdx).etime = toc;
results(mIdx).niter = niter;

% decision
[oznode,pbnode] = mkdec(q,nv);
[seg,sal] = node2img(DB,oznode,pbnode);

% performance evaluation
peval = zeros(nImg,5);
for iIdx = 1:nImg
    % performance measure
    if ~isempty(seg)
        [Acu, Err, Pre, Rec, F1] = calcPerform(seg{iIdx}, DB(iIdx).GT_map);
        peval(iIdx,:) = [Acu, Err, Pre, Rec, F1];
    end
end

results(mIdx).sal_map = sal;
results(mIdx).seg_map = seg;
results(mIdx).peval = peval;

fprintf('%11s (%6.2fs) - Acu:%.4f,   Err:%.3f,   Pre:%.3f,   Rec:%.3f,   F1:%.3f\n', ...
    results(mIdx).mname, mean(results(mIdx).etime), mean(results(mIdx).peval));
  
if param.postprocess
    [results, mIdx] = postprocess(results, mIdx, DB, img2node, nv);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MRW-CS (cosegmentation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
niter = [];
tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% initial setups
[p, x] = iniMRW([0.5 0.5], mask, img2node);

[oznode, ~] = mkdec(p,nv);
[fDist, fDistNorm] = calcFdist(D_inter, oznode, nv);
fDist_old = mean(mean(fDist));
fDistNorm_old = mean(mean(fDistNorm));

p_old = p;
q_old = q;


%% Multi-pass
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% iteration
iter = 1;
if param.disp.showPlot
    iter_show = 1;
else
    iter_show = param.MRW.max_iter;
end

while iter<=iter_show    
    %% Inter-image Affinity Propagation
    c = SAmat*p;

    %% Repulsive MRW Process
    [p, q, x, out] = RMRWP(c, x, c, Amat_intra, param.MRW, img2node);
    
    niter = [niter out.iter];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 1/0 hard decision by p and q
    [oznode, ~] = mkdec(q, nv);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% foreground distance
    [fDist, fDistNorm] = calcFdist(D_inter, oznode, nv);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% escape condition
    
    % 1st stopping criterion
    if fDist_old < mean(mean(fDist,2))
        p = p_old;
        q = q_old;    
        break
    else
        p_old = p;
        q_old = q;
        
        fDist_old = mean(mean(fDist,2));
    end
    
    % 2nd stopping criterion
    if abs(fDistNorm_old - mean(mean(fDistNorm,2))) < 0.00005
        p = p_old;
        q = q_old;
        
        break
    else
        p_old = p;
        q_old = q;
        
        fDistNorm_old = mean(mean(fDistNorm,2));
    end
    
    
    iter = iter + 1;
        
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save results
mIdx = mIdx + 1;
results(mIdx).mname = 'MRW-CS';
results(mIdx).p = p;
results(mIdx).q = q;
results(mIdx).x = x;
results(mIdx).etime = toc;
results(mIdx).niter = niter;

% decision
[oznode,pbnode] = mkdec(q,nv);
[seg,sal] = node2img(DB,oznode,pbnode);

% performance evaluation
peval = zeros(nImg,5);
for iIdx = 1:nImg
    % performance measure
    if ~isempty(seg)
        [Acu, Err, Pre, Rec, F1] = calcPerform(seg{iIdx}, DB(iIdx).GT_map);
        peval(iIdx,:) = [Acu, Err, Pre, Rec, F1];
    end
end

results(mIdx).sal_map = sal;
results(mIdx).seg_map = seg;
results(mIdx).peval = peval;

fprintf('%11s (%6.2fs) - Acu:%.4f,   Err:%.3f,   Pre:%.3f,   Rec:%.3f,   F1:%.3f\n', ...
    results(mIdx).mname, mean(results(mIdx).etime), mean(results(mIdx).peval));


if param.postprocess
    [results, mIdx] = postprocess(results, mIdx, DB, img2node, nv);
end


end