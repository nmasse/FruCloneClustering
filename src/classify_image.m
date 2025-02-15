function [score,MI_threshold]=classify_image(s,template_images_ind,imageList,test_image_ind,matchedPoints_dir,MI_multiplier)
% CLASSIFY_IMAGE determine whether an image contains a clone of interest
% 
% Usage:
% [score,MI_threshold]=classify_image(s,template_images_ind,imageList,...
%					test_image_ind,matchedPoints_dir,MI_multiplier)
%
% This function is used to determine whether an image contains a clone of
% interest. It is assumed that the user has already created the neccessary
% XXXmatchedPoints.mat files that compare existing images to the test image.
% It is also assumed that the user defined which image files contain the
% clone of interest. These images are fed in the build_MI_structure.m to 
% produce the cell s. This cell contains the mutual information between 
% the matching dots in other images and whether those images contain the 
% clone.
%
% Input: 
%  
% s                  - output from build_MI_structure.m
% template_image_ind - index of images containing the clone. Must match
%                         the list of images used to produce the cell s.
%                         The index is based on the imageList cell
% imageList          - List of image names 
% test_image_ind     - index where test_image appears in the imageList
% matchedPoints_dir  - location of the template image XXXmatchedPoints.matfiles
%
% Output: score, is a 1 by 12 vector given the score that the test_image
%                contains the clone of interest. Scores near zero mean the 
%                clone is not present while higher scores indicate a better
%                chance. The first six entries give the mean number of matching
%                dots above 20 different mutual information thresholds.
%                These threshold are [.005:.005:.1]
%                and are contained in the MI_threshold vector. The next 20
%                entries give number of matched points weighted by the
%                modified mutual information for each dot. The mutual
%                information is modified by subtacting one of the
%                thresholds defined above and rectifying.
%
% See also compare_image_to_all_clones, create_image_classifie

MI_threshold=(0.005:0.005:0.1)*MI_multiplier;

count=zeros(length(test_image_ind),40)+10^(-20);
score=zeros(length(test_image_ind),40);

for i=1:length(s)

% load the XXXmatchedPoints.mat file of the ith image containing the
% clone. The matrix y indicates which dots matched dots in other
% images.

	h=dir([matchedPoints_dir imageList{template_images_ind(i)},'-*matchedPoints.mat']);
	load([matchedPoints_dir h(1).name],'y');

%remove any images from matched points list that were deemed bad

	for k=1:length(test_image_ind)

		if test_image_ind(k)~=template_images_ind(i)

			for j=1:40

				if j<=20

					ind=find(s{i}.MI>=MI_threshold(j));
					count(k,j)=count(k,j)+length(ind);
					score(k,j)=score(k,j)+sum(y(ind,test_image_ind(k))); %#ok<*NODEF>

				else

					modified_MI=max(0,s{i}.MI'-MI_threshold(j-20));
					count(k,j)=count(k,j)+sum(modified_MI);
					score(k,j)=score(k,j)+sum(single(y(:,test_image_ind(k))).*modified_MI);

				end

			end
		end

	end


end

clear y

score=score./count;
end

