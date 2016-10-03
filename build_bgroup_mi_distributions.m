% build an array of MI relationships between column-groups for Broad Inst groups
% 	"column-group" = a1,a2,a3 or b1,b2,b3 etc.
% MI must be done on two 1D vectors, so you've got to collapse each 3-column group into a 1D vector

% groupMap - the probeset values for each Broad Inst. group - must exist first

k_arr = keys(groupMap);
grp_num = size(k_arr,2);
broad_distribs = zeros(grp_num,15);
orientations = [1 1 2 2 3 3; 2 3 1 3 1 2; 3 2 3 1 2 1];
combos = [1 1 1 1 1 4 4 4 4 7 7 7 10 10 13; 4 7 10 13 16 7 10 13 16 10 13 16 13 16 16];
for i=1:grp_num
	% for each group (i)
	included = size(groupMap(k_arr{i}),1);
	fprintf('%d   %s (%d)\n',i,k_arr{i}, included);
	% struct array
	s_arr = groupMap(k_arr{i});
	temp = [];
	for t=1:included
		temp = [temp; s_arr(t).values];
	end
	for j=1:15
		if size(temp, 1) > 0
			% for each pair combination (A-B, A-C, etc.) (j)
			col1 = [temp(:, combos(1,j)); temp(:, combos(1,j)+1); temp(:, combos(1,j)+2)];
			col2 = [temp(:, combos(2,j)); temp(:, combos(2,j)+1); temp(:, combos(2,j)+2)];
			mi_diff = mi(col1, col2);
			broad_distribs(i,j) = mi_diff;
		else
			broad_distribs(i,j) = 0;
		end

		% code for re-ordering column combos (not needed)
		% for k=1:6
		% 	% for each orientation of pair #1's three columns
		% 	pair3_1 = zeros(included*3,1);
		% 	pair3_1_cols = [combos(1,j) combos(1,j)+1 combos(1,j)+2];
		% 	for m=1:6
		% 		% for each orientation of pair #2's three columns
		% 		pair3_2 = zeros(included*3,1);
		% 		pair3_2_cols = [combos(2,j) combos(2,j)+1 combos(2,j)+2];
		% 		% fprintf('j=%d\t%d %d %d x %d %d %d\n', ...
		% 		% 	j, ...
		% 		% 	pair3_1_cols(orientations(1,k)), ...
		% 		% 	pair3_1_cols(orientations(2,k)), ...
		% 		% 	pair3_1_cols(orientations(3,k)), ...
		% 		% 	pair3_2_cols(orientations(1,m)), ...
		% 		% 	pair3_2_cols(orientations(2,m)), ...
		% 		% 	pair3_2_cols(orientations(3,m)) ...
		% 		% );
		% 		for n=1:included
		% 			pair3_1(n,1)				= temp(n,pair3_1_cols(orientations(1,k)));
		% 			pair3_1(n+included,1)		= temp(n,pair3_1_cols(orientations(2,k)));
		% 			pair3_1(n+(included*2),1)	= temp(n,pair3_1_cols(orientations(3,k)));
		% 			pair3_2(n,1)				= temp(n,pair3_2_cols(orientations(1,m)));
		% 			pair3_2(n+included,1)		= temp(n,pair3_2_cols(orientations(2,m)));
		% 			pair3_2(n+(included*2),1)	= temp(n,pair3_2_cols(orientations(3,m)));
		% 		end
		% 		mi_diff = mi(pair3_1,pair3_2);
		% 		broad_distribs(i,j) = broad_distribs(i,j) + mi_diff;
		% 	end
		% end
	end
end

% divide everybody by the # of summed combos to average
% broad_distribs = broad_distribs / 36;

save('distribs_mi_broad','broad_distribs');