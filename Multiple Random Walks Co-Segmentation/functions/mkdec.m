function [oznode, pbnode] = mkdec(q, nv)

% make a decision

nImg = length(nv);

oznode = cell(nImg,1);
pbnode = cell(nImg,1);

for j=1:nImg
    qf_tmp = q(ithimg(nv,j),1);
    qb_tmp = q(ithimg(nv,j),2);

    pbnode{j} = [mat2gray(qf_tmp) mat2gray(qb_tmp)];

    [~, tmp] = max(pbnode{j}, [], 2);
    oznode{j} = double(tmp==1);
    oznode{j} = [oznode{j} double(tmp==2)];
end

    

end