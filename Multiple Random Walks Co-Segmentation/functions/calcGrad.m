function [gx, gy] = calcGrad( img )

[R C] = size(img);

gx = zeros(R,C);
gy = zeros(R,C);

j = 1:R;
i = 1:C-1;
gx(j,i) = img(j,i+1) - img(j,i);

j = 1:R-1;
i = 1:C;
gy(j,i) = img(j+1,i) - img(j,i);

end
