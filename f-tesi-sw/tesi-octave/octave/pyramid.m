function [L1,L2,L3,L4,L5,L6,L7,L8,L9] = pyramid(ima)
%PYRAMID	Compute the pyramid decomposition of an image
%		[L1,L2,L3,L4,L5,L6,L7,L8,L9] pyramid(ima) computes
%		the pyramid decomposition of image ima. The number
%		of output arguments determines the number of levels
%		computed. Max n. of levels is 9.
%		The coefficient a is a=0.5.  See details in:
%		Burt and Adelson, IEEE COMM-31 pg 532-540, 1983

%		(c) Pietro Perona,
%		California Institute of Technology
%		May 30 1993

L = [ 'L1'
	'L2'
	'L3'
	'L4'
	'L5'
	'L6'
	'L7'
	'L8'
	'L9'
	'L0'];

[r,c] = size(ima);
dim = max(r,c);
maxlevels = floor(log2(dim));
levels = nargout;

if levels > maxlevels
	error('Too many levels requested. The image is too small.');
end

%L1 = downsample2(ima);
L1=camp_rc2(ima);

for level=2:levels,
   %eval([L(level,:) ' = downsample2(' L(level-1,:) ');']);
   eval([L(level,:) ' = camp_rc2(' L(level-1,:) ');']);
end;

