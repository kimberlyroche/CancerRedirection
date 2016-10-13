function histogramstack(input_filename, transform)
	% renders histogram stack in 1D (angled); output file [input name]_stack_data.txt and [input name]_stack.png

	addpath(genpath('/Applications/MATLAB_R2015a.app/toolbox/MIToolbox'));

	print_dmatrix = true;

	% read from arbitrary input file; get columns first
	fileID = fopen(input_filename,'r');
	first_row = fgetl(fileID);
	fclose(fileID);
	headers = strsplit(first_row,'\t');
	headers = headers(2:numel(headers));

	[pathstr, name, ext] = fileparts(input_filename);
	fileID = fopen(fullfile(pathstr,[name,'_stack_data.txt']),'w');
	fprintf(fileID,'Output of: %s\n\n',[name,ext]);

	figure('Visible','on');

	num_sets = size(headers,2);
	num_rows = 0;

	% http://www.mathworks.com/matlabcentral/answers/81137-pre-determining-the-number-of-lines-in-a-text-file
	[status, cmdout] = system(['wc -l ',input_filename]);
	if status ~= 1
		scan_cell = textscan(cmdout,'%u %s');
		num_rows = scan_cell{1};
	else
		fprintf(fileID, 'Count not read row count of %s\n', input_filename);
		fclose(fileID);
		exit;
	end

	dimensions = [1 1 num_rows-2 num_sets];

	labels = [];

	% M = dlmread(input_filename, '\t', dimensions);
	M = dlmread(input_filename, '\t', 1, 1);
	[rows,cols] = size(M);

	% remove rows of all zeros
	num_rows = rows;
	i = 1;
	while i <= num_rows
		if sum(M(i,:)) == 0
			fprintf('Removing row of all-zero row %d...\n', i);
			M(i,:) = [];
			num_rows = num_rows - 1;
		else
			i = i + 1;
		end
	end
	[rows,cols] = size(M);

	max_h = log2(rows);

	% OPTIONAL - TRANSFORM TO LOG BASE-WHATEVER
	if transform
		M = arrayfun(@(x)(log2(1.+x)), M);
	end

	% distances from slice to slice; we'll have to scale these up to something visually meaningful
	distances = [];
	output_start = 0;
	output_end = num_sets * 50;

	% compute correlation (etc.) matrix; you can do this one of two ways, a square matrix of dissimilarity measurements
	% with diagonals as exactly 0:
	% 	0 A B C
	%	A 0 D E
	%	B D 0 F
	%	C E F 0
	% alternatively you can represent the dissimilarity matrix as a vector, a la, visually awful but interpretable to
	% the cmdscale() function:
	%	[A B C D E F]
	rho = [];
	i = 1;
	j = 1;
	while i <= cols
		j = i+1;
		while j <= cols
			fprintf('Getting correlation for %d x %d\n', i, j);
			c = 0;
			% mutual information
			c = 1 / ( mi(M(:,i), M(:,j)) / max_h );
			rho = [rho c];
			j = j + 1;
		end
		i = i + 1;
	end

	corr_label = 'mutual information';

	if print_dmatrix
		% this matrix is in sort of a gross form; printing it in a human-readable way is kind of a chore
		% print with numbers instead of column header names since they can be super long and make the
		%	matrix nightmarishly wide
		fprintf(fileID,'DISSIMILARITY MATRIX (%s)\n',corr_label);
		rcols = num_sets;
		rrows = num_sets;
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
	end

	% multidimensional scaling
	% will return a matrix of coordinates where each column is an additional dimension
	[coords,eigvals] = cmdscale(rho);
	fprintf(fileID,'EIGENVALUES\n');
	for i=1:size(eigvals,1)
		fprintf(fileID,'\t%6.4f\n',eigvals(i));
	end
	fprintf(fileID,'\n\n');

	% we'll use 1D (column #1) to represent the distance between slices
	% the coordinates determined by cmdscale() aren't ordered; since we want to represent these things in a line, we've
	% got to sort them, while maintaining some way to tell which index was which dataset (that's sort_indices)
	[sort_coords,sort_indices] = sort(coords(:,1));

	% scale up the distances (sort_coords) to get some visual separation
	input_start = sort_coords(1);
	input_end = sort_coords(cols);
	i = 1;
	fprintf(fileID,'DISTANCES\n');
	while i <= cols
		output = output_start + ((output_end - output_start) / (input_end - input_start)) * (sort_coords(i) - input_start);
		distances = [distances output];
		fprintf(fileID,'\t%s   %6.2f\n',headers{sort_indices(i)},output);
		i = i + 1;
	end
	fprintf(fileID,'\n\n');

	fprintf('Beginning rendering...\n');
	bins = 100;	% number of bins to use per histogram
	sq_w = 20;
	x_offset = 0;
	i = 1;
	ecolor_scale = 0.35;
	colors = zeros(18,3);
	colors(1,:) = [150, 165, 55];
	colors(2,:) = colors(1,:);
	colors(3,:) = colors(1,:);
	colors(4,:) = [48, 60, 116];
	colors(5,:) = colors(4,:);
	colors(6,:) = colors(4,:);
	colors(7,:) = [41, 123, 72];
	colors(8,:) = colors(7,:);
	colors(9,:) = colors(7,:);
	colors(10,:) = [104, 38, 111];
	colors(11,:) = colors(10,:);
	colors(12,:) = colors(10,:);
	colors(13,:) = [170, 77, 57];
	colors(14,:) = colors(13,:);
	colors(15,:) = colors(13,:);
	colors(16,:) = [100, 100, 100];
	colors(17,:) = colors(16,:);
	colors(18,:) = colors(16,:);
	colors = colors * 1.5;
	colors = colors / 255;
	i = cols;
	random_colormap = hsv(num_sets);
	while i > 0
		use_index = sort_indices(i);
		x_offset = distances(i) * 10;
		fprintf('%d\t%f\n', use_index, x_offset);
		[N,edges] = histcounts(M(:,use_index),bins);
		j = 1;
		if num_sets == 18 && num_rows = 35556
			color = colors(use_index,:);
		else
			color = random_colormap(randi(num_sets), :);
		end
		while j <= bins
			if j > 1 || N(j) < N(j+1)*2
				% we can get away with only drawing three faces of the box given the angle we're viewing it from
				X = [x_offset x_offset+(sq_w*1); x_offset x_offset+(sq_w*1)];
				Y = [(1-j)*sq_w (1-j)*sq_w; -j*sq_w -j*sq_w];
				Z = [N(j) N(j); N(j) N(j)];
				X2 = [x_offset x_offset; x_offset x_offset];
				Y2 = [-j*sq_w (1-j)*sq_w; -j*sq_w (1-j)*sq_w];
				Z2 = [0 0; N(j) N(j)];
				X3 = [x_offset x_offset+(sq_w*1); x_offset x_offset+(sq_w*1)];
				Y3 = [-j*sq_w -j*sq_w; -j*sq_w -j*sq_w];
				Z3 = [0 0; N(j) N(j)];
				surf(X,Y,Z,'FaceColor',color,'EdgeColor',color*ecolor_scale);
				hold on
				surf(X2,Y2,Z2,'FaceColor',color,'EdgeColor',color*ecolor_scale);
				last_s = surf(X3,Y3,Z3,'FaceColor',color,'EdgeColor',color*ecolor_scale);
			end
			j = j + 1;
		end
		i = i - 1;
	end

	save_title = ['distribution stack ',corr_label];

	hold off;

	fprintf('Saving image...\n');
	axis equal;
	view(-45, 20);
	% set(gca,'YTick',[-2000,-1000,0]);
	% set(gca,'YTickLabel',{'0','1000','2000'});
	set(gca,'XTickLabel',{});
	set(gca,'YTickLabel',{});
	set(gca,'ZTickLabel',{});
	fig = gcf;
	fig.PaperUnits = 'inches';
	fig.PaperPosition = [0 0 50 25];
	fig.PaperPositionMode = 'manual';
	print(fullfile(pathstr,[name,'_stack']),'-dpng','-r0');

	fclose(fileID);
end