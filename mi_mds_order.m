function distances = mi_mds_order(input_filename, spacing_range)

	% get column labels first
	% expect there to be an "extra" column for the left-most column of row labels
	% store column labels in "headers" var
	fileID = fopen(input_filename,'r');
	first_row = fgetl(fileID);
	fclose(fileID);
	headers = strsplit(first_row,'\t');
	headers = headers(2:numel(headers));

	% start the output file, which will contain the similarity/distance matrix and eigenvalues as reference info
	[pathstr, name, ext] = fileparts(input_filename);
	fileID = fopen(fullfile(pathstr,'output',[name,'_mds3d_data.txt']),'w');
	fprintf(fileID,'Output of: %s\n\n',[name,ext]);

	% uses the MI toolbox here: http://www.cs.man.ac.uk/~pococka4/MIToolbox.html
	% make sure the path to the (compiled) MI toolbox is in the env
	addpath('/Applications/MATLAB_R2015a.app/toolbox/MIToolbox');

	num_sets = size(headers,2);
	num_rows = 0; % TBD

	% get number of rows cleverly with a system call to wc -l
	% thx internet: http://www.mathworks.com/matlabcentral/answers/81137-pre-determining-the-number-of-lines-in-a-text-file
	[status, cmdout] = system(['wc -l ',input_filename]);
	if status ~= 1
		scan_cell = textscan(cmdout,'%u %s');
		num_rows = scan_cell{1};
	else
		fprintf(fileID, 'Count not read row count of %s\n', input_filename);
		fclose(fileID);
		exit;
	end

	% read matrix now that we know its dimensions
	% assumptions: the first column is row labels, the first row is column labels
	%	hence the 1 1 offsets below
	dimensions = [1 1 num_rows-2 num_sets];
	M = dlmread(input_filename, '\t', dimensions);
	[rows,cols] = size(M);

	% maximum entropy, determined by set size (number of rows); MI has the range 0 .. max entropy
	max_h = log2(rows);

	% rho is our similarity/distance matrix
	% we're going to use inverse MI as a measure of distance because no one can stop us
	rho = [];
	i = 1;
	j = 1;
	while i <= cols
		j = i+1; % we just need a triangular matrix so the inner loop gets to skip some columns
		while j <= cols
			fprintf('Getting correlation for %d x %d\n', i, j); % user feedback
			% we can improve on this
			c = 1 / ( mi(M(:,i), M(:,j)) / max_h );
			rho = [rho c];
			j = j + 1;
		end
		i = i + 1;
	end

	% print the triangular similarity/distance matrix to the reference file in human readable format
	fprintf(fileID,'SIMILARITY MATRIX\n');
	rcols = cols;
	rrows = cols;
	last=1;
	fprintf(fileID,'      \t');
	for i=1:num_sets
		fprintf(fileID,'%6d\t',i);
	end
	fprintf(fileID,'\n');
	for i=1:rrows
		fprintf(fileID,'%6d\t',i);
		for j=1:i
			fprintf(fileID,'    __\t');
		end
		for j=last:(last + rcols-i - 1)
			fprintf(fileID,'%6.4f\t',rho(j));
		end
		fprintf(fileID,'\n');
		last = j + 1;
	end
	fprintf(fileID,'\n\n');

	% multidimensional scaling - this will return a matrix of coordinates where each column is an additional dimension
	%	in this case we're only interested in the first dimension (this should be the dim. of largest spread anyway)
	[all_coords,eigvals] = cmdscale(rho);
	coords = all_coords(:,1);

	% print eigenvalues too; we don't need them as such but their nice to see
	% these give us an idea of the contribution each dimension makes to the final spread of the spatial rendering
	fprintf(fileID,'EIGENVALUES\n');
	for i=1:size(eigvals,1)
		fprintf(fileID, '\t%6.4f\n', eigvals(i));
	end
	fprintf(fileID, '\n\n');

	distances = [];
	input_start = min(coords);
	input_end = max(coords);
	output_start = 0;
	output_end = spacing_range;
	fprintf(fileID,'DISTANCES (0 - %.1f)\n', spacing_range);
	for i=1:cols
		d = output_start + ((output_end - output_start) / (input_end - input_start)) * (coords(i) - input_start);
		distances = [distances d];
		fprintf(fileID, '\t%s\t%.4f\n', headers{i}, d);
	end

	fclose(fileID);
	
end

