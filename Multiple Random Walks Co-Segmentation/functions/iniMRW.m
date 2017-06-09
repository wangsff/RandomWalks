function [p, x] = iniMRW(prior, mask, img2node)

[nv, nImg] = size(img2node);

% enforce center prior

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% foreground walker
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pf = ones(sum(nv),1);

% boundary to 0
pf(mask(:,5)==1,:) = 0;

% normalization
pf = pf.*(1./(img2node*(img2node'*pf)+eps));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% background walker
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pb = ones(sum(nv),1);
pb(mask(:,5)~=1,1) = 0;
    
% normalization
pb = pb.*(1./(img2node*(img2node'*pb)+eps));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% prior
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xf = prior(1)*ones(nImg, 1);
xb = prior(2)*ones(nImg, 1);

p = [pf pb];
x = [xf xb];

end
