function print_significant_genes(sublist, probeset_signif_arr, direction, genes_orig, genes_new, mapObj, fid, db_obj, do_plot)
	if do_plot
		hold on;
	end
	for i=1:numel(sublist)
		current_probeset = sublist{i};
		current_row = mapObj(current_probeset);
		res = probeset2gene(db_obj, current_probeset);
		if direction == 0
			fprintf(fid, 'DN\t');
		else
			fprintf(fid, 'UP\t');
		end
		if ~isempty(res)
			fprintf(fid, '%s', res(1).gene);
		else
			fprintf(fid, '---');
		end
		if ~isempty(res)
			fprintf(fid, '\t');
			orig_parent_gene_groups = parent_gene_group(res(1).gene, genes_orig);
			some = false;
			if numel(orig_parent_gene_groups) > 0
				some = true;
				for j=1:numel(orig_parent_gene_groups)
					if j > 1
						fprintf(fid, ',');
					end
					fprintf(fid, orig_parent_gene_groups{j});
				end
			end
			fprintf(fid, '\t');
			ext_parent_gene_groups = parent_gene_group(res(1).gene, genes_new);
			if numel(ext_parent_gene_groups) > 0
				for j=1:numel(ext_parent_gene_groups)
					if some || j > 1
						fprintf(fid, ',');
					end
					fprintf(fid, ext_parent_gene_groups{j});
				end
			end
		else
			fprintf(fid, '\t\t');
		end
		fprintf(fid, '\t%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', current_probeset, ...
			current_row(1), ...
			current_row(2), ...
			current_row(3), ...
			current_row(4), ...
			current_row(5), ...
			current_row(6), ...
			current_row(13), ...
			current_row(14), ...
			current_row(15), ...
			probeset_signif_arr(i,1), ...
			probeset_signif_arr(i,2), ...
			probeset_signif_arr(i,3) ...
		);
		if do_plot
			plot( ...
				[1 2 3 4 5 6 7 8 9], ...
				[current_row(1), ...
				current_row(2), ...
				current_row(3), ...
				current_row(4), ...
				current_row(5), ...
				current_row(6), ...
				current_row(13), ...
				current_row(14), ...
				current_row(15)] ...
			);
		end
	end
	if do_plot
		hold on;
		if direction == 0
			saveGCF('output/dn_plots');
		else
			saveGCF('output/up_plots');
		end
	end
end