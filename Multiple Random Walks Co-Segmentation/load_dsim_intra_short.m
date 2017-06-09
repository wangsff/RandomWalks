function [ DSIM_intra_short, param ] = load_dsim_intra_short(DB, param)



nImg = length(DB);


if ~exist(fullfile(param.dir.result_class, 'DSIM_intra_short.mat'), 'file')
    
    DSIM_intra_short = struct('indr', {}, ... row index
                        'indc', {}, ... col index
                        'rgb', {}, ... rgb color difference
                        'lab', {}, ... lab color difference
                        'boundary', {}, ... boundary cues
                        'BoW_rgb', {}, ... Bag-of-words using LAB
                        'BoW_lab', {} ... Bag-of-words using LAB
                    );
            
    % evaluate elapsed time
    eval.time = zeros(nImg,8);

    for jIdx = 1:nImg
        %% input image j

        for iIdx=1:nImg
            %% input image img_i
            nsp_i = DB(iIdx).nsp;
                
            if jIdx==iIdx
                %% graph construction
                tic;
                % non-weighted edge matrix
                edge_mat = zeros(nsp_i, nsp_i);
                for j=1:DB(iIdx).R-1
                    for i=1:DB(iIdx).C-1
                        % 4 neighbor
                        edge_mat(DB(iIdx).sp_map(j,i), DB(iIdx).sp_map(j+1,i)) = 1;
                        edge_mat(DB(iIdx).sp_map(j,i), DB(iIdx).sp_map(j,i+1)) = 1;

                        % 8 neighbor
                        edge_mat(DB(iIdx).sp_map(j,i), DB(iIdx).sp_map(j+1,i+1)) = 1;
                        edge_mat(DB(iIdx).sp_map(j+1,i), DB(iIdx).sp_map(j,i+1)) = 1;
                    end
                end

                % boundary connection
%                 sp_top = unique(DB(iIdx).sp_map(1,:));
%                 sp_down = unique(DB(iIdx).sp_map(end,:));
%                 sp_left = unique(DB(iIdx).sp_map(:,1));
%                 sp_right = unique(DB(iIdx).sp_map(:,end));
% 
%                 sp_bnd = unique([sp_top, sp_down, sp_left', sp_right']);
%                 for j=1:length(sp_bnd)
%                     for i=1:length(sp_bnd)
%                         edge_mat(sp_bnd(j), sp_bnd(i)) = 1;
%                         edge_mat(sp_bnd(i), sp_bnd(j)) = 1;
%                     end
%                 end

                % edge extension
%                 edge_mat_ext = zeros(nsp_i,nsp_i);
%                 for j=1:nsp_i        
%                     ind = find(edge_mat(j,:) == 1);
%                     edge_mat_ext(j,ind) = 1;
% 
%                     for i=1:length(ind)
%                         ind_ext = find(edge_mat(ind(i),:)==1);
%                         edge_mat_ext(j,ind_ext) = 1;
%                     end
%                     edge_mat_ext(j,j) = 0;
%                 end
%                 edge_mat = edge_mat_ext;

                for j=1:nsp_i
                    edge_mat(j,j) = 0;
                end
                
                [indr, indc, ~] = find(edge_mat);
                
                eval.time(jIdx,1) = toc;
                
                DSIM_intra_short(jIdx, iIdx).indr = indr;
                DSIM_intra_short(jIdx, iIdx).indc = indc;
                
                
                %% intra-image feature dissimilarities
                ind_edge = sub2ind(size(edge_mat), indr, indc);
                
                % rgb
                tic;
                distances = dist(DB(iIdx).sp_rgb_mean');
                distances = (distances - min(distances(:))) / (max(distances(:) - min(distances(:))));
                
                eval.time(jIdx,2) = toc;
                
                DSIM_intra_short(jIdx, iIdx).rgb = distances(ind_edge);
                

                % lab
                tic;
                distances = dist(DB(iIdx).sp_lab_mean');
                distances = (distances - min(distances(:))) / (max(distances(:) - min(distances(:))));
                
                eval.time(jIdx,3) = toc;
                
                DSIM_intra_short(jIdx, iIdx).lab = distances(ind_edge);
                
                
                % boundary cues by gradient magnitude
                tic;
                gm = sqrt(DB(iIdx).gx.^2 + DB(iIdx).gy.^2);
                gm = gm/max(gm(:));
                
                distances = zeros(nsp_i, nsp_i);
                pj_list = DB(iIdx).sp_center(indr,:);
                pi_list = DB(iIdx).sp_center(indc,:);
                for pidx = 1:size(pj_list,1)
                    % Bresenham's line drawing algorithm
                    [line_r,line_c] = bresenham(pj_list(pidx,1),pj_list(pidx,2), ...
                        pi_list(pidx,1),pi_list(pidx,2));
                    line_ind = sub2ind(size(gm), round(line_r), round(line_c));
                    
                    distances(ind_edge(pidx)) = sum(gm(line_ind));
                end
                distances = (distances - min(distances(:))) / (max(distances(:) - min(distances(:))));
                
                eval.time(jIdx,6) = toc;
                
                DSIM_intra_short(jIdx, iIdx).boundary = distances(ind_edge);                
                
                
                
                % BoW: RGB color
                tic;
                [cmap, param.BoW_intra, ~] = myBoW({DB(iIdx).rgb}, param.BoW_intra);
                
                hist_BoW = zeros(nsp_i, param.BoW_intra.nc);
                for j=1:nsp_i
                    sp_idx = DB(jIdx).sp_idx{j};
                    hist_BoW(j,:) = histc(cmap{1}(sp_idx'), 1:param.BoW_intra.nc);
                end
                
                if strcmp(param.hist_dist,'hisect')
                    distances = hist_isect(hist_BoW, hist_BoW);                    
                else
                    hist_BoW = diag(1./(sum(hist_BoW,2)+eps))*hist_BoW;
                    if strcmp(param.hist_dist,'chisqr')
                        distances = pdist2(hist_BoW, hist_BoW, 'chisq');
                    else
                        distances = pdist2(hist_BoW, hist_BoW);
                    end
                end
                
                distances = (distances - min(distances(:))) / (max(distances(:) - min(distances(:))));
                
                eval.time(jIdx,7) = toc;
                
                DSIM_intra_short(jIdx, iIdx).BoW_rgb = distances(ind_edge);
                
                
                
                % BoW: LAB color
                tic;
                [cmap, param.BoW_intra, ~] = myBoW({DB(iIdx).lab}, param.BoW_intra);
                
                hist_BoW = zeros(nsp_i, param.BoW_intra.nc);
                for j=1:nsp_i
                    sp_idx = DB(jIdx).sp_idx{j};
                    hist_BoW(j,:) = histc(cmap{1}(sp_idx'), 1:param.BoW_intra.nc);
                end
                
                if strcmp(param.hist_dist,'hisect')
                    distances = hist_isect(hist_BoW, hist_BoW);                    
                else
                    hist_BoW = diag(1./(sum(hist_BoW,2)+eps))*hist_BoW;
                    if strcmp(param.hist_dist,'chisqr')
                        distances = pdist2(hist_BoW, hist_BoW, 'chisq');
                    else
                        distances = pdist2(hist_BoW, hist_BoW);
                    end
                end
                
                distances = (distances - min(distances(:))) / (max(distances(:) - min(distances(:))));
                
                eval.time(jIdx,8) = toc;
                
                DSIM_intra_short(jIdx, iIdx).BoW_lab = distances(ind_edge);
                
                
                
            
            end
        end
    end
    
    save(fullfile(param.dir.result_class, 'dsim_intra_short.mat'), 'DSIM_intra_short', 'eval');
    if param.disp.verbose
        fprintf('intra-image superpixel dissimilarities (short) are calculated and saved!\n');
    end
else
    load(fullfile(param.dir.result_class, 'dsim_intra_short.mat'));    
    if param.disp.verbose
        fprintf('intra-image superpixel dissimilarities (short) are loaded!\n');
    end
        
end

