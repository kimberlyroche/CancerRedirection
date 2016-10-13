function save_arr = print_significant_genes(sublist, direction, genes_orig, genes_new, mapObj, fid, db_obj, do_plot)
	% sublist
	%			cell array of probeset IDs of interest
	% direction
	%			0 = sublist represents probesets depressed in expression in A and E compared to B
	%			~0 = sublist represents probesets elevated in expression in A and E compared to B
	% genes_orig
	%			cell array of cell arrays; each root level array is a cell array of { 'gene group name', 'member gene 1', 'member gene 2', ... }
	% genes_new
	%			as above but include the _extended_ genes ID'd by Chenyan
	% mapObj
	%			the 35556 x 18 mouse matrix as a map indexed on probeset ID for easy querying; see readM_map.m
	% fid
	%			file handle to write output to
	% db_obj
	%			an instantiated pointer to annotations.db
	% do_plot
	%			true/false flag; true = print plots of sublist; false = nah
	% RETURN save_arr
	%			save the membership of each probeset/gene for later use
	save_arr = {};
	if do_plot
		hold on;
	end
	for i=1:numel(sublist)
		current_probeset = sublist{i};
		sub_arr = {current_probeset};
		use_sub_arr = false;
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
			sub_arr = [sub_arr res(1).gene];
			fprintf(fid, '\t');
			orig_parent_gene_groups = parent_gene_group(res(1).gene, genes_orig);
			some = false;
			if numel(orig_parent_gene_groups) > 0
				some = true;
				for j=1:numel(orig_parent_gene_groups)
					use_sub_arr = true;
					sub_arr = [sub_arr orig_parent_gene_groups{j}];
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
					use_sub_arr = true;
					sub_arr = [sub_arr ext_parent_gene_groups{j}];
					if some || j > 1
						fprintf(fid, ',');
					end
					fprintf(fid, ext_parent_gene_groups{j});
				end
			end
		else
			fprintf(fid, '\t\t');
		end
		fprintf(fid, '\t%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', current_probeset, ...
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
		if use_sub_arr
			save_arr{numel(save_arr)+1} = sub_arr;
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