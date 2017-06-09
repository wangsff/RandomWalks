function [W, A, S] = WAS_intra(DB, DSIM, param)

nImg = length(DB);

W = cell(nImg,nImg);
A = cell(nImg,nImg);
if nargout > 2
    S = cell(nImg,nImg);
end

for j=1:nImg
    for i=1:nImg
        nsp_j = DB(j).nsp;
        nsp_i = DB(i).nsp;
        
        if j==i
            % aggregation
            dissim = param.fw_intra(1)* DSIM(j,i).rgb + ...
                     param.fw_intra(2)* DSIM(j,i).lab + ...
                     param.fw_intra(3)* DSIM(j,i).boundary + ...
                     param.fw_intra(4)* DSIM(j,i).BoW_rgb + ...
                     param.fw_intra(5)* DSIM(j,i).BoW_lab;
            
            % similarity
            W{j,i} = sparse(DSIM(j,i).indr,DSIM(j,i).indc, exp(-dissim.^2/param.sigsqr_intra), nsp_j, nsp_i);
            W{j,i} = max(W{j,i}, W{j,i}');
                        
            % affinity
            degs = sum(W{j,i},1)';
            degs(degs==0) = eps;
            
            invD = spdiags(1./degs, 0, nsp_j, nsp_i);
            A{j,i} = W{j,i}*invD;
            
            if nargout > 2
                % MRW stationary
                S{j,i} = param.MRW.epsilon * ((speye(nsp_j) - (1-param.MRW.epsilon)*A{j,i})\speye(nsp_j));
            end
        else
            W{j,i} = sparse(nsp_j, nsp_i);
            A{j,i} = sparse(nsp_j, nsp_i);
            if nargout > 2
                S{j,i} = sparse(nsp_j, nsp_i);
            end
        end
    end
end



end

