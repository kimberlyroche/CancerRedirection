% build 'groupMap_labels' - a map of struct arrays
% map {
%	'ZHANG_TLX_TARGETS_36HR_UP' =>	[
%										struct {
%												label: '1043402 (genename)'
%												values: [7.069852 6.939350 6.813323 ...]
%										},
%										struct {
%												label: '1086271, 1489346, 1455491 (genename)'
%												values: [7.317612 7.070506 6.987699 ...]
%										},
%										...
%									]
%	...
% }

% first, since we're going to have to query row IDs (probeset IDs), jam everything into a map (hash)
%	for easy access
if ~exist('mapObj','var')
	input_filename = 'mouse.txt';
	mapObj = containers.Map('KeyType','char','ValueType','any');
	col_sz = 1;
	fid = fopen(input_filename);
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

if ~exist('groupMap_labels','var')
	groupMap_labels = containers.Map('KeyType','char','ValueType','any');
end

% query the database (if possible? plugin installed?)
database_path = '/Users/kimroche/Desktop/annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';

dataset_sz = 18;
offset = 0;
group_sample = 13311;
% above correspond to OFFSET and LIMIT in select query respectively
%	you can just pull a subset if you want
db_obj = DB(database_path, sqlite3_path);
grouplist = getNgroups(db_obj, offset, group_sample);

for g=1:group_sample

	bgroup = grouplist(g).bgroup;
	result = group2probeset_gene_pairs(db_obj, bgroup);
	bdim = size(result,2);

	fprintf('%d %s\n',g,bgroup);

	counter = 100;
	while counter > 0 && bdim ~= size(groupMap(bgroup),1)
		fprintf('\t(retrying)\n');
		result = group2probeset_gene_pairs(db_obj, bgroup);
		bdim = size(result,2);
		counter = counter - 1;
	end

	temp = [];
	included = 0;
	for i=1:bdim
		try
			C = strsplit(result(i).pids,',');
			bgroup_rowlabel = '';

			for csz=1:size(C,2)
				if csz > 1
					bgroup_rowlabel = [bgroup_rowlabel,', '];
				end
				bgroup_rowlabel = [bgroup_rowlabel,C{csz}];
			end
			bgroup_rowlabel = [bgroup_rowlabel,' (',result(i).gene,')'];

			upper = size(C,2);
			avg = zeros(1,18);
			found = 0;
			for j=1:upper
				if isKey(mapObj, C{j})
					avg = avg + mapObj(C{j})';
					found = found + 1;
				end
			end
			if found > 0
				avg = avg / found;
				s = struct('label',bgroup_rowlabel,'values',avg);
				temp = [temp; s];
				included = included + 1;
			end
		catch ME
			% I don't think there's a need to catch exceptions; isKey should do it but...
			disp(ME.message);
		end
	end

	groupMap_labels(bgroup) = temp;

end

% uncomment to save file
save('groups_data_labels','groupMap_labels');

groupMap = groupMap_labels;
