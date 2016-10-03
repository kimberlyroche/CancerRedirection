if ~exist('mapObj','var')
	input_filename = 'ABCDEF-rma-normalized.txt';
	mapObj = containers.Map('KeyType','char','ValueType','any');
	col_sz = 1;
	fid = fopen(input_filename);
	fgetl(fid); % skip first line (column headers)
	tline = fgetl(fid);
	while ischar(tline)
		cols = strsplit(tline);
		charval = cols{1};
		cols(1) = [];
		mapObj(charval) = cellfun(@str2num, cols)';
		tline = fgetl(fid);
		col_sz = col_sz + 1;
	end
	fclose(fid);
end