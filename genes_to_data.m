genes_of_interest = {'Cdk1', 'Mapk1', 'Mapk3', 'Grb2', 'Hras', 'Raf1', 'Sos1', 'Map2k1', 'Nras', 'Irs2', 'Kras', 'Irs1', 'Ywhab', 'Map2k2'};

fprintf('Reading mouse matrix into map...\n');
readM_map();

fprintf('Querying list of all Broad-associated genes...\n');
database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

fid = fopen('output/genes_to_data.txt', 'w');
fprintf(fid, 'gene\ta1\ta2\ta3\tb1\tb2\tb3\tc1\tc2\tc3\td1\td2\td3\te1\te2\te3\tf1\tf2\tf3\n');
for i=1:numel(genes_of_interest)
	res = gene2probeset(db_obj, genes_of_interest{i});
	fprintf('Querying "%s"...\n', genes_of_interest{i});
	fprintf(fid, '%s', genes_of_interest{i});
	for j=1:numel(res)
		if isKey(mapObj, res(j).probeset)
			current_row = mapObj(res(j).probeset);
			for k=1:18
				fprintf(fid, '\t%.4f', current_row(k));
			end
		else
			for k=1:18
				fprintf(fid, '\t');
			end
		end
		fprintf(fid, '\n');
	end
end
fclose(fid);