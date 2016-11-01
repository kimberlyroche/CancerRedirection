% clear coolness_map;

readM_map();

readDEG();
genes_orig = getOrigGenelists();
genes_extended = getExtendedGenelists();
% genes_extended = getExtendedAdjustedGenelists(DEG_map);

database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

if ~exist('coolness_map', 'var') || numel(coolness_map) < 1
	coolness_map = containers.Map('KeyType','char','ValueType','any');
	% 'genename' -> {
	%					{ probeset_list },
	%					{ molecular_signature_list },
	%					is_diff_expressed,
	%					is_extended
	%				}

	for i=1:numel(genes_orig)
		g = genes_orig{i};
		groupname = g{1};
		for j=2:numel(g)
			gene = g{j};
			gene = [upper(gene(1)),lower(gene(2:length(gene)))]; % let's assume we don't have any genes of 1 character
			res = gene2probeset(db_obj, gene);
			if numel(res) > 0
				for m=1:numel(res)
					probeset = res(m).probeset;
					temp = {};
					k = keys(coolness_map);
					if ismember(gene, k)
						temp = coolness_map(gene);
						if ~ismember(probeset, temp{1})
							temp{1} = [temp{1}, probeset];
						end
						if ~ismember(groupname, temp{2})
							temp{2} = [temp{2}, groupname];
						end
						temp{3} = 0;
						temp{4} = 0;
					else
						temp = { {probeset}, {groupname}, 0, 0 };
					end
					temp{3} = probesetDEGsignificant(gene, true, DEG_map, 1);
					temp{4} = 0;
					coolness_map(gene) = temp;
					fprintf('%s\t%s\t%s\tN\n', gene, probeset, g{1});
				end
			else
				fprintf('\t\t\t\tno probesets for %s\n', gene);
				coolness_map(gene) = { {}, {}, 0, 0 };
			end
		end
	end
	for i=1:numel(genes_extended)
		g = genes_extended{i};
		groupname = g{1};
		for j=2:numel(g)
			gene = g{j};
			gene = [upper(gene(1)),lower(gene(2:length(gene)))]; % let's assume we don't have any genes of 1 character
			res = gene2probeset(db_obj, gene);
			if numel(res) > 0
				for m=1:numel(res)
					probeset = res(m).probeset;
					temp = {};
					k = keys(coolness_map);
					if ismember(gene, k)
						temp = coolness_map(gene);
						if ~ismember(probeset, temp{1})
							temp{1} = [temp{1}, probeset];
						end
						if ~ismember(groupname, temp{2})
							temp{2} = [temp{2}, groupname];
						end
						temp{3} = 0;
						temp{4} = 0;
					else
						temp = { {probeset}, {groupname}, 0, 0 };
					end
					temp{3} = probesetDEGsignificant(gene, true, DEG_map, 1);
					temp{4} = 1;
					coolness_map(gene) = temp;
					fprintf('%s\t%s\t%s\tY\n', gene, probeset, g{1});
				end
			else
				fprintf('\t\t\t\tno probesets for %s\n', gene);
				coolness_map(gene) = { {}, {}, 0, 1 };
			end
		end
	end
end

aeb_only = true;
k = keys(coolness_map);
fid = fopen('output/biomarker_list.txt', 'w');
fid2 = fopen('output/biomarker_datapoints.txt', 'w');
fid3 = fopen('output/biomarker_core_datapoints.txt', 'w');
fprintf(fid, 'Gene name\tProbe set list\tMolecular signature list\tDifferentially Expressed\tExtended\n');
if aeb_only
	fprintf(fid2, 'identifier\ta1\ta2\ta3\tb1\tb2\tb3\te1\te2\te3\n');
	fprintf(fid3, 'identifier\ta1\ta2\ta3\tb1\tb2\tb3\te1\te2\te3\n');
else
	fprintf(fid2, 'identifier\ta1\ta2\ta3\tb1\tb2\tb3\tc1\tc2\tc3\td1\td2\td3\te1\te2\te3\tf1\tf2\tf3\n');
	fprintf(fid3, 'identifier\ta1\ta2\ta3\tb1\tb2\tb3\tc1\tc2\tc3\td1\td2\td3\te1\te2\te3\tf1\tf2\tf3\n');
end
for i=1:numel(k)
	temp = coolness_map(k{i});
	fprintf(fid, '%s\t', k{i});
	probesets = temp{1};
	for j=1:numel(probesets)
		% print data matrix of all biomarkers
		fprintf(fid2, '%s_%s\t', k{i}, probesets{j});
		row = mapObj(probesets{j});
		if aeb_only
			fprintf(fid2, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', row(1), row(2), row(3), row(4), row(5), row(6), row(13), row(14), row(15));
		else
			for m=1:17
				fprintf(fid2, '%f\t', row(m));
			end
			fprintf(fid2, '%f\n', row(18));
		end
		% end
		% print data matrix of CORE biomarkers
		if temp{3} == 1
			fprintf(fid3, '%s_%s\t', k{i}, probesets{j});
			row = mapObj(probesets{j});
			if aeb_only
				fprintf(fid3, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', row(1), row(2), row(3), row(4), row(5), row(6), row(13), row(14), row(15));
			else
				for m=1:17
					fprintf(fid3, '%f\t', row(m));
				end
				fprintf(fid3, '%f\n', row(18));
			end
		end
		% end
		if j > 1
			fprintf(fid, ', ');
		end
		fprintf(fid, '%s', probesets{j});
	end
	fprintf(fid, '\t');
	groups = temp{2};
	for j=1:numel(groups)
		if j > 1
			fprintf(fid, ', ');
		end
		fprintf(fid, '%s', groups{j});
	end
	fprintf(fid, '\t');
	fprintf(fid, '%d\t%d\n', temp{3}, temp{4});
end
fclose(fid);
fclose(fid2);
fclose(fid3);










