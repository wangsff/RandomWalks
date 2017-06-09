function [ out_ind ] = ithimg( nv, i )
%UNTITLED2 이 함수의 요약 설명 위치
%   자세한 설명 위치
out_ind = sum(nv(1:i-1))+1 : sum(nv(1:i));


end

