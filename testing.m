% testing, junk file

% have to be in the workspace from per_gene_significance.m: geneScores, ratio, mapObj, db_obj

bins = 100;

[a,b] = histcounts(log2(ratios), bins);
k = keys(geneScores);

% interested in percentiles 1, 2, 5, 25, 50, 75, 95, 98, 99
fid = fopen('output/percentile_genes.txt', 'w');
fprintf(fid, 'percentile\tgene\ta1\ta2\ta3\tb1\tb2\tb3\te1\te2\te3\n');
for i=1:bins
	if a(i) > 0
		fprintf('Found something in bin #%d\n', i);
		lower_threshold = b(i);
		upper_threshold = Inf;
		if i < bins
			upper_threshold = b(i+1);
		end
		for j=1:numel(k)
			% for all geneScores
			if ~isempty(geneScores(k{j})) && (log2(geneScores(k{j}).ratio) < upper_threshold) && (log2(geneScores(k{j}).ratio) > lower_threshold)
				res = gene2probeset(db_obj, k{j});
				fprintf(fid, '%d\t%s', i, k{j});
				% fprintf('%d\t%s', i, k{j});
				for m=1:numel(res)
					if m > 1
						fprintf(fid, '%d\t%s', i, [k{j}, '_', num2str(m)]);
						% fprintf('%d\t%s', i, [k{j}, '_', num2str(m)]);
					end
					if isKey(mapObj, res(m).probeset)
						current_row = mapObj(res(m).probeset);
						fprintf(fid, '\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f', ...
							current_row(1), ...
							current_row(2), ...
							current_row(3), ...
							current_row(4), ...
							current_row(5), ...
							current_row(6), ...
							current_row(13), ...
							current_row(14), ...
							current_row(15) ...
						);
						% fprintf('\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f', ...
						% 	current_row(1), ...
						% 	current_row(2), ...
						% 	current_row(3), ...
						% 	current_row(4), ...
						% 	current_row(5), ...
						% 	current_row(6), ...
						% 	current_row(13), ...
						% 	current_row(14), ...
						% 	current_row(15) ...
						% );
					else
						for n=1:9
							fprintf(fid, '\t');
							% fprintf('\t');
						end
					end
					fprintf(fid, '\n');
					% fprintf('\n');
				end
				break;

			end
		end
	end
end
% fclose(fid);


% for j=1:numel(k)
% 	if ~isempty(geneScores(k{j})) && ~isnan(geneScores(k{j}).ratio) && log2(geneScores(k{j}).ratio) < -10
% 		k{j}
% 		log2(geneScores(k{j}).ratio)
% 	end
% end
