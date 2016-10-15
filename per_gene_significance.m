% method = 1
%		judges significance of every probeset (35556) in the matrix with respect to the AB, BE, AE relationship
%		using the DEG matrix (DEG_map obj)
% method = 2
%		outputs heatmaps for all 
method = 2;

fprintf('Reading matrix into map object...\n');
readM_map();

database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

genes_orig = getOrigGenelists();
genes_new = getExtendedGenelists();

if method == 1
	% print the entire probeset list with associated gene name(s) and significance tagged
	% output to tab-delimited output/sig_genes.txt
	readDEG();
	ab_col = 1;
	ae_col = 4;
	be_col = 7;
	fprintf('Collecting significant gene information...\n');

	fid = fopen('output/sig_genes.txt', 'w');
	fprintf(fid, 'A-B adj p\tE-B adj p\tA-E adj p\tprobeset ID\tgenes\n');
	alpha = 0.01;
	k = keys(DEG_map);
	for i=1:numel(k)
		current_row = DEG_map(k{i});
		if current_row(ab_col) < alpha && current_row(be_col) < alpha && current_row(ae_col) > alpha
			res = probeset2gene(db_obj, k{i});
			fprintf(fid, '%.6f\t%.6f\t%.6f\t%s\t', ...
				current_row(ab_col), ...
				current_row(be_col), ...
				current_row(ae_col), ...
				k{i} ...
			);
			if ~isempty(res)
				for j=1:numel(res)
					if j > 1
						fprintf(fid, ',');
					end
					fprintf(fid, '%s', res(j).gene);
				end
				fprintf(fid, '\n');
			else
				fprintf(fid, '---\n');
			end
		end
	end
	fclose(fid);
else
	% heatmaps
	grp_no = numel(genes_orig);
	for i=grp_no:grp_no
		filename = genes_orig{i}{1};
		fid = fopen(['output/data_',filename,'.txt'], 'w');
		fprintf(fid, 'probeset-gene\tA1\tA2\tA3\tE1\tE2\tE3\tB1\tB2\tB3\n');
		for j=2:numel(genes_orig{i})
			res = gene2probeset(db_obj, genes_orig{i}{j});
			for k=1:numel(res)
				if probesetDEGsignificant(res(k).probeset, false, DEG_map, 1)
					fprintf(fid, '%s-%s_SIG', res(k).probeset, genes_orig{i}{j});
				else
					fprintf(fid, '%s-%s', res(k).probeset, genes_orig{i}{j});
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
end
