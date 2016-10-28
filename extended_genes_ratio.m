addpath(genpath('/Applications/MATLAB_R2015a.app/toolbox/MIToolbox'));

filename_tag = '_sig_one_transcript';
% filename_tag = '_sig_half_transcript';
% filename_tag = '_sig_all_transcript';
fprintf('Reading gene lists...\n');
readDEG();
genes_orig = getOrigGenelists();
% getExtendedGenelists();
genes_new = getExtendedAdjustedGenelists(DEG_map);

% 'mi_ratios.txt' is the just the list of MI(A,E)/MI(E,B) ratios values, output of ratios_histograms_lists.m,
%	so we have the whole population/distribution from which to judge percentile
ratios = dlmread('mi_ratios.txt');
perc_arr = prctile(ratios, 1:100);

readM_map();

database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

% keep of list of genes for which we don't have probesets/measurements
not_found_list = {};
fid = fopen(['output/extended_genes_significance',filename_tag,'.txt'],'w');
fprintf(fid, 'Group Name\tNum Genes\tOriginal MI Ratio\tOriginal MI A-E\tOriginal MI E-B\tPercentile\tNum Combined Genes\tCombined MI Ratio\tCombined MI A-E\tCombined MI E-B\tPercentile\n');

fprintf('Outputing MI ratio before-after significance...\n');
% assumption here is that _orig and _new gene lists have the same basic structure and order
for g=1:numel(genes_orig)
	A_combined = []; B_combined = []; E_combined = [];
	fprintf(fid, '%s\t', genes_orig{g}{1});
	% two iterations: once for original genes, second for extended list
	for h=1:2
		A_data = []; B_data = []; E_data = [];
		if h == 1
			arr_sz = numel(genes_orig{g});
			num_genes = arr_sz - 1;
		else
			arr_sz = numel(genes_new{g});
			num_genes = arr_sz - 1;
		end
		num_genes = arr_sz - 1;
		genes_in_arr = 0;
		for i=2:arr_sz
			if h == 1
				pids = gene2probeset(db_obj, genes_orig{g}{i});
			else
				pids = gene2probeset(db_obj, genes_new{g}{i});
			end
			bdim = size(pids,2);
			if bdim > 1
				% more than one probeset associated with this gene
				% average the expression of all the probesets/transcripts <- this is dicey, we need better info
				genes_in_arr = genes_in_arr + 1;
				temp_A = []; temp_B = []; temp_E = [];
				for j=1:bdim
					arr = mapObj(pids(j).probeset)';
					temp_A = [temp_A; arr(1:3)];
					temp_B = [temp_B; arr(4:6)];
					temp_E = [temp_E; arr(13:15)];
				end
				A_data = [A_data; mean(temp_A)];
				B_data = [B_data; mean(temp_B)];
				E_data = [E_data; mean(temp_E)];
				A_combined = [A_combined; mean(temp_A)];
				B_combined = [B_combined; mean(temp_B)];
				E_combined = [E_combined; mean(temp_E)];
			elseif bdim == 1
				% one gene associated with this probeset ID
				genes_in_arr = genes_in_arr + 1;
				arr = mapObj(pids.probeset)';
				A_data = [A_data; arr(1:3)];
				B_data = [B_data; arr(4:6)];
				E_data = [E_data; arr(13:15)];
				A_combined = [A_combined; arr(1:3)];
				B_combined = [B_combined; arr(4:6)];
				E_combined = [E_combined; arr(13:15)];
			else
				if h == 1
					not_found_list = [not_found_list; [genes_orig{g}{i}, ' (', genes_orig{g}{1}, ')']];
				else
					not_found_list = [not_found_list; [genes_new{g}{i}, ' (', genes_new{g}{1}, ')']];
				end
			end
		end
		if h == 1
			% print original MI ratios and percentile w/in the distribution
			A_reshaped = reshape(A_data, [genes_in_arr*3, 1]);
			B_reshaped = reshape(B_data, [genes_in_arr*3, 1]);
			E_reshaped = reshape(E_data, [genes_in_arr*3, 1]);
			num = mi(A_reshaped, E_reshaped);
			denom = mi(E_reshaped, B_reshaped);
			mi_ratio = num/denom;
			fprintf(fid, '%d\t%5.3f\t%5.3f\t%5.3f\t', num_genes, mi_ratio, num, denom);
			for p=1:numel(perc_arr)
				if perc_arr(p) > mi_ratio
					break;
				end
			end
			fprintf(fid, '%d\t', p);
		end
	end
	% print COMBINED MI ratios (original and extended genes) and percentile w/in the distribution
	num_genes = size(A_combined,1);
	A_reshaped = reshape(A_combined, [num_genes*3, 1]);
	B_reshaped = reshape(B_combined, [num_genes*3, 1]);
	E_reshaped = reshape(E_combined, [num_genes*3, 1]);
	num = mi(A_reshaped, E_reshaped);
	denom = mi(E_reshaped, B_reshaped);
	mi_ratio = num/denom;
	fprintf(fid, '%d\t%5.3f\t%5.3f\t%5.3f\t', num_genes, mi_ratio, num, denom);
	for p=1:numel(perc_arr)
		if perc_arr(p) > mi_ratio
			break;
		end
	end
	fprintf(fid, '%d\n', p);
end

% print probesets not found in experimental data
if numel(not_found_list) > 0
	fprintf(fid, '\nGenes/probesets not found:\n');
	for i=1:numel(not_found_list)
		fprintf(fid, '%s\n', not_found_list{i});
	end
end

fprintf(fid, '\n');
fclose(fid);





