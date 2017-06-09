function [results, mIdx] = postprocess( results, mIdx, DB, img2node, nv )


forq_p = results(mIdx).p;
x = results(mIdx).x;

nImg = length(DB);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Post Processing
tic; 

% prepare
nv_sted = ones(length(nv),2);
nv_sted(1,2) = sum(nv(1));
for nv_id = 2:length(nv_sted)
    nv_sted(nv_id,1) = sum(nv(1:nv_id-1))+1;
    nv_sted(nv_id,2) = sum(nv(1:nv_id));
end

%% ========================================================================
%  WD4: Bilateral filter (Large superpixel-level)
%  ========================================================================
lab_sigsqr = 20;
trans_p = forq_p;
for img_id = 1:length(nv)
    pos_sigsqr = (DB(img_id).R^2+DB(img_id).C^2)/500;
    pos_weight = exp(-(dist(DB(img_id).sp_center').^2)/pos_sigsqr);
    lab_weight = exp(-(dist(DB(img_id).sp_lab_mean').^2)/lab_sigsqr);
    tot_weight = pos_weight.*lab_weight;
    w_nrmlizer = sum(tot_weight,2);

    for iter_id = 1:1
        trans_p(nv_sted(img_id,1):nv_sted(img_id,2),1) = ...
            sum(repmat(trans_p(nv_sted(img_id,1):nv_sted(img_id,2),1),1,nv(img_id)).*tot_weight);
        trans_p(nv_sted(img_id,1):nv_sted(img_id,2),1) = ...
            trans_p(nv_sted(img_id,1):nv_sted(img_id,2),1) ./ w_nrmlizer;
        trans_p(nv_sted(img_id,1):nv_sted(img_id,2),2) = ...
            sum(repmat(trans_p(nv_sted(img_id,1):nv_sted(img_id,2),2),1,nv(img_id)).*tot_weight);
        trans_p(nv_sted(img_id,1):nv_sted(img_id,2),2) = ...
            trans_p(nv_sted(img_id,1):nv_sted(img_id,2),2) ./ w_nrmlizer;
    end
end
%  ========================================================================
%  ========================================================================
%  WD5: Prior estimation
%  ========================================================================
pri_x = zeros(size(x));
for img_id = 1:length(nv)
    img_p = trans_p(nv_sted(img_id,1):nv_sted(img_id,2),:);
    nimg_p = img_p*diag(1./(max(img_p)+eps));
    pri_x(img_id,:) = sum(nimg_p)/sum(nimg_p(:));
end

px = trans_p.*(img2node*pri_x);
q = diag(1./(sum(px,2)+eps))*px;
qf = q(:,1);
qb = q(:,2);


%  ========================================================================
%  ========================================================================
%  WD6: Bilateral filter (Pixel-level)
%  ========================================================================
qf_qb = zeros(size(qf));
for img_id = 1:length(nv)
    qf_img = qf(ithimg(nv,img_id));
    qf_img = (qf_img-min(qf_img(:)))/(max(qf_img(:))-min(qf_img(:)));
    qb_img = qb(ithimg(nv,img_id));
    qb_img = (qb_img-min(qb_img(:)))/(max(qb_img(:))-min(qb_img(:)));

    qf_qb(nv_sted(img_id,1):nv_sted(img_id,2)) = qf_img - qb_img;
end

win_size = 20;
pos_sigsqr = 50;
[x_list,y_list] = meshgrid(-win_size:win_size,-win_size:win_size);
pos_weight = exp(-(x_list.^2+y_list.^2)/(pos_sigsqr));

lab_sigsqr = 20;
qfqb_img = cell(length(nv),1);
qfpost_img = cell(length(nv),1);
for img_id = 1:length(nv)    

    qfqb_img{img_id} = zeros(DB(img_id).R,DB(img_id).C);
    qfpost_img{img_id} = zeros(DB(img_id).R,DB(img_id).C);
    for sp_id = 1:nv(img_id)
        qfqb_img{img_id}(DB(img_id).sp_map == sp_id) = qf_qb(sp_id+nv_sted(img_id,1)-1);
    end
    for y_id = 1:DB(img_id).R
        for x_id = 1:DB(img_id).C
            y_min = max(y_id-win_size,1);
            y_max = min(y_id+win_size,DB(img_id).R);
            x_min = max(x_id-win_size,1);
            x_max = min(x_id+win_size,DB(img_id).C);
            lab_weight = exp(-sum((DB(img_id).lab(y_min:y_max,x_min:x_max,:)-...
                repmat(DB(img_id).lab(y_id,x_id,:),y_max-y_min+1,x_max-x_min+1,1)).^2,3)/lab_sigsqr);
            total_weight = lab_weight.*...
                pos_weight((y_min:y_max)-y_id+win_size+1,(x_min:x_max)-x_id+win_size+1);
            qfpost_img{img_id}(y_id,x_id) = ...
                sum(sum(total_weight.*qfqb_img{img_id}(y_min:y_max,x_min:x_max)))/...
                sum(total_weight(:));
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% get results
mIdx = mIdx + 1;
results(mIdx).mname = [results(mIdx-1).mname ' (P)'];
results(mIdx).etime = toc;

sal = cell(nImg,1);
seg = cell(nImg,1);
for iIdx = 1:nImg
    sal{iIdx} = qfpost_img{iIdx};
    seg{iIdx} = double(qfpost_img{iIdx}>0);
end

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
    
    
    
    
end