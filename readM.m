% read dataset into 35556 x 18 matrix variable M

input_filename = 'ABCDEF-rma-normalized.txt';
if ~exist('M','var')
	M = dlmread(input_filename, '\t', 1, 1);
end
[rows,cols] = size(M);
