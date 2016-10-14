function r = heatmaps(filepath, filename, subset_sz_rows, subset_sz_cols, separate_by, resolution_inches)

	% output will be saved to dir 'output' in same directory

	% filepath
	%		input file path or '' if same directory as input file
	% filename
	%		input file name
	% subset_sz_rows
	%		first n rows to restrict the heatmap/clustergram function to
	%		0 = use all rows
	% subset_sz_cols
	%		first n columns to restrict the heatmap/clustergram function to
	%		0 = use all columns
	% separate_by
	%		visually separate columns on the basis of a shared column label prefix
	%		percentage of total heatmap width to make the (null) separators between groups (if > 0)
	%		e.g. a stripe will be added between the 'OV_unc' and 'THCA_unc' boundary
	% 			OV_unc.edu.fc1f34ba.12e1.46d8.85ef.15b9486b37c2.1518624.rsem.isoforms.normalized_results
	% 			OV_unc.edu.fdda1428.ad6b.4337.a959.83bae1f9664b.1519084.rsem.isoforms.normalized_results
	% 			OV_unc.edu.ff781a4f.7281.4195.880f.3df099a401cc.1519261.rsem.isoforms.normalized_results
	% 			THCA_unc.edu.000b3ce1.5bcf.4dd5.b7e4.e4f9367a939b.1037824.rsem.isoforms.normalized_results
	% 			THCA_unc.edu.00759cb3.e0d6.47eb.948f.5ed3fc9f944f.1816680.rsem.isoforms.normalized_results
	% 			THCA_unc.edu.00775634.c7a2.4336.83aa.4da2dc58d375.1911049.rsem.isoforms.normalized_results
	% resolution_inches
	%		resolution of output PNG in inches

	if ~exist('output','dir')
		mkdir('output');
	end

	cols = 0;
	rows = 0;

	% -----------------------------------------
	% ------------ READ THE MATRIX ------------
	% -----------------------------------------
	fprintf('Reading file %s...\n', filename);
	fid = fopen(fullfile(filepath,['data_',filename,'.txt']),'rt');
	while (fgets(fid) ~= -1),
		rows = rows + 1;
	end
	fseek(fid, 0, 'bof');

	% read column labels
	delimiter = '\t'; 
	line = fgetl(fid);
	elements = regexp(line, '\S+(\s+)?');
	cols = numel(elements);
	column_labels = {};
	for i=2:cols
		idx1 = elements(i);
		if i == cols
			idx2 = length(line);
		else
			idx2 = elements(i+1)-2;
		end
		str_val = line(idx1:idx2);
		column_labels = [column_labels, str_val];
	end

	% read data and capture row labels
	row_labels = {};
	data = zeros(rows-1, cols-1);
	limit = rows-1;
	for i=1:limit
		line = fgetl(fid);
		elements = regexp(line, '\S+(\s+)?');
		if i <= limit
			% first col in each line is label
			str_val = line(1:elements(2)-2);
			row_labels = [row_labels, str_val];
			for j=2:numel(elements)
				idx1 = elements(j);
				if j == numel(elements)
					idx2 = length(line);
				else
					idx2 = elements(j+1)-2;
				end
				str_val = line(idx1:idx2);
				value = str2num(str_val);
				data(i,j-1) = value;
			end

		end
	end
	fclose(fid);

	fprintf('Finished reading %d x %d matrix\n', rows, cols);

	% --------------------------------------------
	% ------------ LOG TRANSFORM DATA ------------
	% --------------------------------------------
	fprintf('Drawing heatmap...\n');
	data_adjusted = data + 0.00001;
	data_log = log2(data_adjusted);

	% -----------------------------------------
	% ------------ ADD SEPARATORS -------------
	% -----------------------------------------
	current_label = '';
	test_label = '';
	insert_indices = [];
	if separate_by > 0
		if separate_by > 1
			separate_by = separate_by / 100;
		end
		% add null columns between cols with different names (first segment)
		for i=1:numel(column_labels)
			test_label = column_labels{i};
			sites = strfind(test_label, '.');
			segment = current_label;
			if numel(sites) > 1 && sites(1) > 1
				segment = test_label(1:sites(1)-1);
			end
			if strcmp(current_label,'') ~= 1 && strcmp(current_label, segment) ~= 1
				insert_indices = [insert_indices i-1];
			end
			current_label = segment;
		end

		data_intermediate = [];
		columns_to_add = round(cols * separate_by);
		for i=1:numel(insert_indices)+1
			if i == 1
				idx2 = insert_indices(i);
				data_intermediate = data_log(:, 1:insert_indices(i));
			else
				idx1 = insert_indices(i-1)+1;
				if i == numel(insert_indices)+1
					idx2 = cols-1;
				else
					idx2 = insert_indices(i);
				end
				data_intermediate = [data_intermediate zeros((rows-1),columns_to_add) data_log(:, idx1:idx2)];
			end
		end
		data_log = data_intermediate;
	end

	% -------------------------------------------
	% ------------ SUBSET IF NEEDED -------------
	% -------------------------------------------
	limit_rows = rows - 1;	
	limit_cols = cols - 1;
	if subset_sz_rows > 0
		limit_rows = subset_sz_rows;
	end
	if subset_sz_cols > 0
		limit_cols = subset_sz_cols;
	end
	subset_test_row_labels = row_labels(1:limit_rows);
	subset_test_col_labels = column_labels(1:limit_cols);
	subset_test_data = data_log(1:limit_rows,1:limit_cols);


	% ---------------------------------------------
	% ------------ HEATMAP AND OUTPUT -------------
	% ---------------------------------------------

	% we'll do the "standardization" ourselves since we want color-coding to be uniform for matrix values
	new_min = min(min(subset_test_data));
	new_max = max(max(subset_test_data));
	% normalize the matrix (0..1)
	subset_test_data = 1 * (subset_test_data - new_min) / (new_max - new_min);
	% adjust data so mean = 0
	new_mu = mean(reshape(subset_test_data, [size(subset_test_data,1) * size(subset_test_data,2), 1]));
	subset_test_data = subset_test_data - new_mu;
	new_min = min(min(subset_test_data))
	new_max = max(max(subset_test_data))
	drange = max(ceil(abs(new_min)), ceil(abs(new_max)))
	% range of data is should include bound highest and lowest values
	% symmetric = true means "forces the color scale of the heat map to be symmetric around zero"
	% standardize = 0 means don't allow MATLAB to standardize on rows or columns as neither would be appropriate in a small matrix

	cobj = clustergram(subset_test_data, 'Cluster', 1, 'Standardize', 0, 'DisplayRange', drange, 'Symmetric', false);
	set(cobj, 'ColumnLabels', subset_test_col_labels);
	set(cobj, 'RowLabels', subset_test_row_labels);

	rows_rendered = get(cobj, 'RowLabels');
	columns_rendered = get(cobj, 'ColumnLabels');
	fid_out = fopen(fullfile(filepath,['heatmap_',filename,'.txt']),'w');
	fprintf(fid_out, 'Rows (top to bottom):\n');
	i = limit_rows;
	while i > 0
		fprintf(fid_out, '\t%s\n', rows_rendered{i});
		i = i - 1;
	end
	fprintf(fid_out, 'Columns (left to right):\n');
	for i=1:limit_cols
		fprintf(fid_out, '\t%s\n', columns_rendered{i});
	end
	fclose(fid_out);
	fprintf('Saving files...\n');
	tobj = addTitle(cobj, filename, 'interpreter', 'none', 'FontSize', resolution_inches*1.5);
	plot(cobj);

	% title(filename);

	% figureHandle = gcf;
	% set(findall(figureHandle,'type','text'), 'FontSize', 5);

	fig = gcf;
	row_append_str = '';
	col_append_str = '';
	if subset_sz_rows > 0
		row_append_str = ['_rows',num2str(subset_sz_rows)];
	end
	if subset_sz_cols > 0
		col_append_str = ['_cols',num2str(subset_sz_cols)];
	end
	set(fig, 'PaperUnits', 'inches', 'PaperPosition', [0 0 resolution_inches resolution_inches]);
	print(fullfile(filepath,['heatmap_',filename,row_append_str,col_append_str,'.png']),'-dpng','-r200');

end
