% rows/keys in DEG_obj are probeset IDs
% order of columns in DEG_obj are:
%		AB	AC	AD	AE	AF	BC	BE	BF	EF	CE	DF	BD	CD	CF	DE

if ~exist('DEG','var')
	fprintf('Reading DEG matrix...\n');
	DEG = dlmread('MouseArrayDEGAnalysis_AllGenes.txt', '\t', 1, 1);
end
M_rows = 35556;

if ~exist('DEG_map','var')
	fprintf('Building DEG map...\n');
	% adjusted p value is column 5
	% probeset ID is column 9
	DEG_map = containers.Map('KeyType','char','ValueType','any');
	for i=1:15
		for j=1:M_rows
			current_row = (M_rows * (i-1)) + j;
			if j == 1
				fprintf('Reading row (%2d/15) %6d\n', i, current_row);
			end
			current_probeset = num2str(DEG(current_row, 9));
			current_adjp = DEG(current_row, 5);
			if i == 1
				DEG_map(current_probeset) = [current_adjp];
			else
				DEG_map(current_probeset) = [DEG_map(current_probeset) current_adjp];
			end
		end
	end
end