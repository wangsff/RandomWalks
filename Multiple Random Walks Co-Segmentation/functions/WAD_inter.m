function [W_inter, A_inter, D_inter] = WAD_inter(DB, hist_sift, hist_lab, hist_text, param)

nImg = length(DB);

W_inter = cell(nImg,nImg);
D_inter = cell(nImg,nImg);
for j=1:nImg
    for i=1:nImg
        nsp_j = DB(j).nsp;
        nsp_i = DB(i).nsp;
        if j==i
            W_inter{j,i} = sparse(nsp_j, nsp_i);
            D_inter{j,i} = sparse(nsp_j, nsp_i);
            continue
        end
        % BoW: sift
        if strcmp(param.hist_dist,'hisect')
            DSIM_inter_BoW_sift = hist_isect(hist_sift{j}, hist_sift{i});
        elseif strcmp(param.hist_dist,'chisqr')
            DSIM_inter_BoW_sift = pdist2(hist_sift{j},hist_sift{i},'chisq');
        end

        % BoW: lab
        if strcmp(param.hist_dist,'hisect')
            DSIM_inter_BoW_lab = hist_isect(hist_lab{j}, hist_lab{i});
        elseif strcmp(param.hist_dist,'chisqr')
            DSIM_inter_BoW_lab = pdist2(hist_lab{j},hist_lab{i},'chisq');
        end

        % BoW: text
        if strcmp(param.hist_dist,'hisect')
            DSIM_inter_BoW_text = hist_isect(hist_text{j}, hist_text{i});
        elseif strcmp(param.hist_dist,'chisqr')
            DSIM_inter_BoW_text = pdist2(hist_text{j},hist_text{i},'chisq');
        end

        dissim = param.fw_inter(1)* DSIM_inter_BoW_sift + ...
                 param.fw_inter(2)* DSIM_inter_BoW_lab + ...
                 param.fw_inter(3)* DSIM_inter_BoW_text;
             
        D_inter{j,i} = dissim;
        
        % normalization
        dissim = (dissim - min(dissim(:)))/(max(dissim(:))-min(dissim(:)));

        W_inter{j,i} = exp(-dissim.^2/param.sigsqr_inter);
    end
end

% make it symmetric
for j=1:nImg
    for i=1:nImg
        W_inter{j,i} = max(W_inter{j,i}, W_inter{i,j}');
    end
end

% transition matrix
A_inter = cell(nImg,nImg);
for j=1:nImg
    for i=1:nImg
        nsp_j = DB(j).nsp;
        nsp_i = DB(i).nsp;
        
        degs = sum(W_inter{j,i},1)';
        degs(degs==0) = eps;

        invD = spdiags(1./degs, 0, nsp_i, nsp_i);
        A_inter{j,i} = W_inter{j,i}*invD;
    end
end


end