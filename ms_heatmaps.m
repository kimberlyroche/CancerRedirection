% outputs heatmaps for all (20) gene lists pulled from getOrigGenelists() and getExtendedAdjustedGenelists(...)

fprintf('Reading matrix into map object...\n');
readM_map();

database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

readDEG();

genes_orig = getOrigGenelists();
% genes_new = getExtendedGenelists();
genes_new = getExtendedAdjustedGenelists(DEG_map);

grp_no = numel(genes_orig);
existing_sig = 0;
for i=1:20
	filename = genes_orig{i}{1};
	fid = fopen(['output/data_',filename,'.txt'], 'w');
	fprintf(fid, 'probeset-gene\tA1\tA2\tA3\tE1\tE2\tE3\tB1\tB2\tB3\n');
	for j=2:numel(genes_orig{i})
		res = gene2probeset(db_obj, genes_orig{i}{j});
		for k=1:numel(res)
			if probesetDEGsignificant(res(k).probeset, false, DEG_map, 1)
				fprintf(fid, '%s-%s_SIG', res(k).probeset, genes_orig{i}{j});
				existing_sig = existing_sig + 1;
			else
				fprintf(fid, '%s-%s_', res(k).probeset, genes_orig{i}{j});
				% fprintf(fid, '%s-%s', res(k).probeset, genes_orig{i}{j});
			end
			current_row = mapObj(res(k).probeset);
			fprintf(fid, '\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n', ...
				current_row(1), ...
				current_row(2), ...
				current_row(3), ...
				current_row(13), ...
				current_row(14), ...
				current_row(15), ...
				current_row(4), ...
				current_row(5), ...
				current_row(6) ...
			);
		end
	end
	for j=2:numel(genes_new{i})
		res = gene2probeset(db_obj, genes_new{i}{j});
		for k=1:numel(res)
			if probesetDEGsignificant(res(k).probeset, false, DEG_map, 1)
				fprintf(fid, '%s-%s_NEW_SIG', res(k).probeset, genes_new{i}{j});
			else
				fprintf(fid, '%s-%s_NEW', res(k).probeset, genes_new{i}{j});
			end
			current_row = mapObj(res(k).probeset);
			fprintf(fid, '\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n', ...
				current_row(1), ...
				current_row(2), ...
				current_row(3), ...
				current_row(13), ...
				current_row(14), ...
				current_row(15), ...
				current_row(4), ...
				current_row(5), ...
				current_row(6) ...
			);
		end
	end
	fclose(fid);
	heatmaps('output', filename, 0, 0, 0, 10);
end
