function [p, q, x, out] = RMRWP(p, x, c, A, param, img2node)


% Repulsive MRW process


% for time analysis
out.stime = tic;


%% MRW Process
iter = 1;
energy = 1;

r_old = p;

while iter<=param.max_iter
    p_old = p;
    
    px = p.*(img2node*x);
    q = diag(1./(sum(px,2)+eps))*px;

    % repulsive term
    r = p.*q;
    r = r.*(1./(img2node*(img2node'*r)+eps));
    
    % concurrence term
    if ~isempty(c)
        r = param.gamma*r + (1-param.gamma)*c;
        r = r.*(1./(img2node*(img2node'*r)+eps));
    end
    
    % cooling factor
    r = (1-param.delta^iter)*r_old + param.delta^iter*r;
    r = r.*(1./(img2node*(img2node'*r)+eps));
    
    p = (1-param.epsilon)*A*p + param.epsilon*r;
    
    r_old = r;
    
    if param.prior_update == 1
        x = img2node'*q;
        x = diag(1./(sum(x,2)+eps)) * x;     
    elseif param.prior_update == 2        
        x = sum(px,2)'*q;
        x = x'/(sum(x)+eps);
    end
    
    p_diff = p_old-p;
    maxs = max(p_diff);
    sqsums = sum(p_diff.^2);
    energy = abs(max(maxs - sqsums));
    
    if energy < param.tol
        break
    end
    
    iter = iter + 1;
    
end

% for analysis
out.iter = iter;
out.e = energy;
out.etime = toc(out.stime);


end
