function [ out_ind ] = ithimg( nv, i )
%UNTITLED2 �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ
out_ind = sum(nv(1:i-1))+1 : sum(nv(1:i));


end

