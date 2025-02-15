function coords = ind2coord(siz, IND, voxdims, axperm)
% IND2COORD find XYZ coords corresponding to 1D indices into a 3D image
% 
% Usage: coords = ind2coord(siz, IND, voxdims, [axperm])
%
% Input:
% siz     - size of 3d image array
% IND     - 1D indices into the image array
% voxdims - vector of 3 voxel dimensions (width, height, depth, dx,dy,dz)
% axperm  - 3-vector containing reordering of axes, negatives imply flip
%           
% coords  - 3xN XYZ triples 
%
% Permutations and Flips:
% -----------------------
% axperm = [1 2 3]  do nothing
% axperm = [-1 2 3] flip the points along the array's first axis
% axperm = [-2 1 3] flip 1st axis and then swap 1st and 2nd
%
% axperm = [1 -2 3] fixes coords from images loaded by readpic
% axperm = [2 1 3] fixes coords from images loaded by imread (eg tif)
%
% See also coord2ind, ind2sub

if(length(siz)) ~= 3
	error('coords2ind only handles 3d data');
end

pixcoords=zeros(3,length(IND));

% first convert from indices to pixel coords
[pixcoords(1,:) pixcoords(2,:) pixcoords(3,:)] = ind2sub(siz,IND);

if(nargin==4)
	% flip and swap axes if required
	for i=1:3
		% NB (pix)coords are 0 indexed whereas subscripts are 1 indexed,
		% so we subtract 1 implicitly or explixicitly below
		if(axperm(i)<0)
			% flip axis (NB siz(i)-1-pixcoords would give 1-indexed flip)
			pixcoords(i,:)=siz(i)-pixcoords(i,:);
		else
			pixcoords(i,:)=pixcoords(i,:)-1;
		end
	end
	pixcoords=pixcoords(abs(axperm),:);
end

% then convert from pixel coords to physical coords
coords(1,:)=pixcoords(1,:)*voxdims(1);
coords(2,:)=pixcoords(2,:)*voxdims(2);
coords(3,:)=pixcoords(3,:)*voxdims(3);

end
