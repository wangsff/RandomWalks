function bnd_map = segBnd( binImg )

[R,C] = size(binImg);
       
% forward gradient
gxf = zeros(R,C);
gyf = zeros(R,C);

j = 1:R;
i = 1:C-1;
gxf(j,i) = binImg(j,i+1) - binImg(j,i);

j = 1:R-1;
i = 1:C;
gyf(j,i) = binImg(j+1,i) - binImg(j,i);

% backward gradient
gxb = zeros(R,C);
gyb = zeros(R,C);

j = 1:R;
i = 2:C;
gxb(j,i) = binImg(j,i) - binImg(j,i-1);

j = 2:R;
i = 1:C;
gyb(j,i) = binImg(j,i) - binImg(j-1,i);

bnd_map = abs(gxf) + abs(gyf) + abs(gxb) + abs(gyb);


end
