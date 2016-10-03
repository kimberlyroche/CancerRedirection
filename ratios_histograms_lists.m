
% ========== BUILD LAYERED HISTOGRAM FOR A GIVEN MI PAIRING RATIO ==============
%    AB   AC   AD   AE   AF   BC   BD   BE   BF   CD   CE   CF   DE   DF   EF
%    1    2    3    4    5    6    7    8    9    10   11   12   13   14   15

addpath(genpath('/Applications/MATLAB_R2015a.app/toolbox/MIToolbox'));

if ~exist('groupMap','var')
	load('groups_data');
end

if ~exist('broad_distribs','var')
	load('distribs_mi_broad');
end

if ~exist('sample_distribs','var')
	load('distribs_mi_random');
end

% 0 = get the significant msig list and print to file plus the list of genes included in these signatures
% 1 = render the layered random-Broad msig histograms
% 2 = render the MDS-MI snapshots (you'll have to set a "specific" ratio numerator and denominator from above)
render_figure = 0;

% MI ratio numerator (see mapping at top of file)
specific_num = 4;

% MI ratio denominator (see mapping at top of file)
specific_denom = 8;

% molecular signatures this size or below will be discarded
min_grp_sz = 10;

% true = output all groups
% false = output significant groups only
log_all_groups = true;

% true = output member genes in one column (single space-delimited)
% false = output member genes in separate columns (must do this if you want to hyperlink in Excel)
genes_1_col = false;

% true = significance threshold using Bonferroni correction: threshold == 0.01 / num. molecular signatures
% false = significance threshold == mean + 2 * standard dev.
threshold_by_p = true;

figure('Visible','off');
bins = 100;
upper_limit = 6;
bogus = 0;
resolution = 15;
num_groups = 13311;

combos = containers.Map('KeyType', 'int32', 'ValueType', 'char');
combos(1) = 'AB'; combos(2) = 'AC'; combos(3) = 'AD'; combos(4) = 'AE'; combos(5) = 'AF';
combos(6) = 'BC'; combos(7) = 'BD'; combos(8) = 'BE'; combos(9) = 'BF';
combos(10) = 'CD'; combos(11) = 'CE'; combos(12) = 'CF';
combos(13) = 'DE'; combos(14) = 'DF';
combos(15) = 'EF';

% iterate all combos unless a specific combo specified above
for num=1:15
	for denom=1:15

		pval_sentinels = containers.Map('KeyType','char','ValueType','double');

		if specific_num > 0 && specific_denom > 0
			num = specific_num;
			denom = specific_denom;
		end

		if num ~= denom

			if render_figure == 1
				sz = size(sample_distribs,1);
				test_dist = [];
				for i=1:sz
					s = sample_distribs(i,:);
					diff = s(1,num)/s(1,denom);
					if isnan(diff)
						% 0/0
						bogus = bogus + 1;
					elseif diff == Inf
						test_dist = [test_dist; upper_limit];
					else
						test_dist = [test_dist; diff];
					end
				end
				fprintf('bogus in random MIs: %d\n',bogus);
			end

			bogus_nan = 0;
			bogus_sz = 0;
			grp_num = size(broad_distribs,1);
			mi_test = broad_distribs(:,num)./broad_distribs(:,denom);
			mi_drawable = [];
			samples_used = 0;
			k = keys(groupMap);
			for i=1:grp_num
				grp_sz = size(groupMap(k{i}),1);
				if grp_sz > min_grp_sz
					diff = mi_test(i);
					if isnan(diff)
						% 0/0 = unusable
						bogus_nan = bogus_nan + 1;
					elseif diff == Inf
						mi_drawable = [mi_drawable; log2(grp_sz)];
						samples_used = samples_used + 1;
					else
						mi_drawable = [mi_drawable; diff];
						samples_used = samples_used + 1;
					end
				else
					bogus_sz = bogus_sz + 1;
				end
			end
			if render_figure == 1
				fprintf('combo %s / %s, bogus in Broad group MIs: %d (NaN), %d (too small)\n',combos(num),combos(denom),bogus_nan,bogus_sz);
			end

			mu = mean(mi_drawable);
			sigma = std(mi_drawable);
			if threshold_by_p
				% Bonferroni
				threshold = 0.01 / samples_used;
				fprintf('MI ratio threshold p-val is: %f\n', threshold);
			else
				threshold = mu + 2 * sigma;
				fprintf('MI ratio threshold is: %f\n', threshold);
			end
			if render_figure == 1
				ix = randperm(samples_used);
				dist_shuffled = test_dist(ix);
				clf;
				hold on;
				grid off;
				block_width = 10;
				edges = linspace(0, upper_limit, bins);
				[n, edges] = histcounts(dist_shuffled, edges);
				for j=1:bins-1
					patch([block_width*(j-1) block_width*j block_width*j block_width*(j-1)], [0 0 n(j) n(j)], [1 0 0]);
				end
				[n, edges] = histcounts(mi_drawable,edges);
				for j=1:bins-1
					patch([block_width*(j-1) block_width*j block_width*j block_width*(j-1)], [0 0 n(j) n(j)], [0 0 1]);
				end
				hold off;
				alpha(0.5);

				axis([0 1000 0 6000]);
				set(gca, 'XTick', linspace(0, 1000, 11));
				xticklabels = {0};
				for xlab=1:10
					xticklabels = [xticklabels, sprintf('%5.3f', edges(xlab * 10))];
				end
				set(gca, 'XTickLabel', xticklabels);
				set(gca, 'FontSize', resolution);

				fig = gcf;
				fig.PaperUnits = 'inches';
				fig.PaperPosition = [0 0 resolution resolution];
				fig.PaperPositionMode = 'manual';
				str = sprintf('mean random: %6.4f\nstd dev random: %6.4f\nmean Broad: %6.4f\nstd dev Broad: %6.4f\nthreshold: %6.4f\nsamples used: %d\n', ...
							mean(dist_shuffled), ...
							std(dist_shuffled), ...
							mean(mi_drawable), ...
							std(mi_drawable), ...
							threshold, ...
							samples_used ...
				);
				fprintf('\n%s\n', str);
				print(['output/layeredhist_',combos(num),'-',combos(denom)],'-dpng','-r0');
			end

			if render_figure == 0 || render_figure == 2

				gene_occurence = containers.Map('KeyType','char','ValueType','int32');
				significant_groups = containers.Map('KeyType','char','ValueType','single');

				corr_group_size = [];
				corr_mi_ratio = [];
				corr_num = [];
				corr_denom = [];

				if render_figure == 0
					output1 = fopen(['output/threshold_list_',combos(num),'-',combos(denom),'_verbose.csv'],'w');
					output2 = fopen(['output/threshold_list_',combos(num),'-',combos(denom),'.csv'],'w');
					fprintf(output1, 'Molecular Signature,No. Transcripts,MI Ratio,MI Numerator,MI Denominator,P-Value,Genes,Probeset IDs\n');
					fprintf(output2, 'Molecular Signature,No. Transcripts,MI Ratio,MSDB Brief Description,Genes\n');
					for i=1:num_groups
						if size(groupMap(k{i}),1) > min_grp_sz
							mi_this_group = broad_distribs(i,num) / broad_distribs(i,denom);
							[hval,pval] = ztest(mi_this_group,mu,sigma);

							if render_figure == 0
								if log_all_groups || (~log_all_groups && (threshold_by_p && pval < threshold && mi_this_group > mu) || ...
										(~threshold_by_p && mi_this_group > threshold))
									% this group IS significant
									corr_group_size = [corr_group_size; size(groupMap(k{i}),1)];
									corr_mi_ratio = [corr_mi_ratio; mi_this_group];
									corr_num = [corr_num; broad_distribs(i,num)];
									corr_denom = [corr_denom; broad_distribs(i,denom)];
									fprintf('Recording data for group %s ...\n',k{i});
									significant_groups(k{i}) = pval;
									s = groupMap(k{i});
									for j=1:size(groupMap(k{i}),1)
										if isKey(gene_occurence, s(j).label)
											gene_occurence(s(j).label) = gene_occurence(s(j).label) + 1;
										else
											gene_occurence(s(j).label) = 1;
										end
									end
								end
							end
						end
					end

					fprintf('Pearsons correlation of size and MI ratio: %8.7f\n', corr(corr_group_size, corr_mi_ratio));
					fprintf('Max H of %d = %8.7f\n', size(corr_group_size, 1), log2(size(corr_group_size, 1)));
					fprintf('MI of size and MI ratio: %8.7f\n', mi(corr_group_size, corr_mi_ratio));

					sk = keys(significant_groups);
					str_arr = [];
					for i=1:size(significant_groups)
						member_genes = [];
						this_group = groupMap(sk{i});
						for w=1:size(k,2)
							if strcmp(sk{i}, k{w})
								break;
							end
						end
						for j=1:size(this_group, 1)
							[startIdx1, endIdx1] = regexpi(this_group(j).label, '^.*?\(');
							[startIdx2, endIdx2] = regexpi(this_group(j).label, '\)');
							name = this_group(j).label((endIdx1+1):(startIdx2-1));
							[startIdx1, endIdx1] = regexpi(this_group(j).label, ' \(');
							probesetID_list = this_group(j).label(1:(startIdx1-1));
							member_genes = [member_genes; struct( ...
								'label', name, ...
								'occurence', gene_occurence(this_group(j).label), ...
								'probeset_list', probesetID_list ...
							)];
						end

						% sort member genes on frequency (descending) using method below (only if logging a subset, oof)
						fields = fieldnames(member_genes);
						cell_version = struct2cell(member_genes);
						cell_sz = size(cell_version);
						cell_version = reshape(cell_version, cell_sz(1), []); % convert to matrix
						cell_version = cell_version';
						cell_version = sortrows(cell_version, 2);
						cell_version = flip(cell_version);
						cell_version = reshape(cell_version', cell_sz);
						member_genes = cell2struct(cell_version, fields, 1);

						% cURL Broad brief description for this gene set
						geneset_name = sk{i};
						fprintf('Building struct for %s...\n', sk{i});
						% Chrome's Developer Tools have a feature whereby you can right-click and 'Copy as cURL' on
						%	any http request, which you can then paste into a system call in MATLAB; splice in a genename
						%	and you can automatic the querying of brief description's from the Broad Inst's website, a la:
						%		http://software.broadinstitute.org/gsea/msigdb/geneset_page.jsp?geneSetName=
						%			BIOCARTA_CERAMIDE_PATHWAY&keywords=BIOCARTA_CERAMIDE_PATHWAY
						% You need to refence the cookie created when you're signed into the MSigDB which is a hassle
						%	but the 'Copy as cURL' function will do this for you, just paste into:
						%		[A, brief_desc] = system();
						brief_desc = '';

						expression = '<a href=''.*?''>(.*?)</a>';
						replace = '$1';
						brief_desc = regexprep(brief_desc, expression, replace);

						[startIdx, endIdx] = regexpi(brief_desc, '^(.*?)<th>Brief description</th>\s+<td>');
						brief_desc = brief_desc(endIdx+1:size(brief_desc,2));
						[startIdx, endIdx] = regexpi(brief_desc, '</td>');
						brief_desc = brief_desc(1:startIdx-1);
						gstr = struct( ...
							'label', sk{i}, ...
							'size', size(groupMap(sk{i}), 1), ...
							'num', broad_distribs(w,num), ...
							'denom', broad_distribs(w,denom), ...
							'ratio', (broad_distribs(w,num) / broad_distribs(w,denom)), ...
							'pval', significant_groups(sk{i}), ...
							'brief_desc', brief_desc, ...
							'member_genes', member_genes ...
						);
						str_arr = [str_arr; gstr];
					end

					% sort struct array by pval:
					%		http://blogs.mathworks.com/pick/2010/09/17/sorting-structure-arrays-based-on-fields/
					fields = fieldnames(str_arr);
					cell_version = struct2cell(str_arr);
					cell_sz = size(cell_version);
					cell_version = reshape(cell_version, cell_sz(1), []); % convert to matrix
					cell_version = cell_version';
					cell_version = sortrows(cell_version, 5);
					cell_version = reshape(cell_version', cell_sz);
					str_arr = cell2struct(cell_version, fields, 1);

					first = true;
					this_group = groupMap(sk{i});
					for j=1:size(str_arr, 1)
						current_group = str_arr(j);
						% remove commas from group names if present
						expression = ',';
						replace = ';';
						commaless_group_label = regexprep(current_group.label, expression, replace);
						fprintf(output1, '%s,%d,%5.3f,"%s",', ...
											commaless_group_label, ...
											current_group.size, ...
											current_group.ratio, ...
											current_group.num, ...
											current_group.denom, ...
											current_group.pval ...
						);
						fprintf(output2, '%s,%d,%5.3f,"%s",', ...
											['"=HYPERLINK(""http://software.broadinstitute.org/gsea/msigdb/cards/',current_group.label,'"", ""', commaless_group_label, '"")"'], ...
											current_group.size, ...
											current_group.ratio, ...
											current_group.brief_desc ...
						);
						first_gene = true;
						for k_it=1:size(current_group.member_genes, 1)
							first = false;
							current_gene = current_group.member_genes(k_it);
							if genes_1_col
								current_gene_string = current_gene.label;
							else
								current_gene_string = ['"=HYPERLINK(""http://www.genecards.org/cgi-bin/carddisp.pl?gene=',current_gene.label,'"", ""',current_gene.label,'"")"'];
							end
							if first_gene
								fprintf(output1, '%s', current_gene.label);
								fprintf(output2, '%s', current_gene_string);
								first_gene = false;
							else
								fprintf(output1, ' %s', current_gene.label);
								if genes_1_col
									fprintf(output2, ' %s', current_gene_string);
								else
									fprintf(output2, ',%s', current_gene_string);
								end
							end
						end

						fprintf(output1, ',');

						for k_it=1:size(current_group.member_genes, 1)
							current_gene = current_group.member_genes(k_it);
							expression = ',\s*';
							replace = ' ';
							probeset_list = regexprep(current_gene.probeset_list, expression, replace);
							fprintf(output1, '%s ', probeset_list);
						end

						fprintf(output1, '\n');
						fprintf(output2, '\n');
						first = true;
					end

				elseif render_figure == 2

					[sorted_values, sorted_indices] = sort(mi_test);
					lower_bound = 1;
					upper_bound = num_groups;
					while lower_bound <= num_groups && sorted_values(lower_bound) < 0
						lower_bound = lower_bound + 1;
					end
					while upper_bound > 0 && (isnan(sorted_values(upper_bound)) || sorted_values(upper_bound) == Inf)
						upper_bound = upper_bound - 1;
					end
					range = upper_bound - lower_bound;
					mds_out = fopen(['output/layeredhist_',combos(num),'-',combos(denom),'.txt'],'w');	
					render_points = round(([0.01,0.02,0.05,0.95,0.98,0.99]*range)+lower_bound);

					mins_maxes = [Inf 0; Inf 0; Inf 0];

					for g=1:size(render_points,2)
						idx = render_points(g);
						groupM = groupMap(k{sorted_indices(idx)});
						while size(groupM,1) <= min_grp_sz
							idx = idx + 1;
							groupM = groupMap(k{sorted_indices(idx)});
						end
						if g == size(render_points,2) || idx < render_points(g+1)
							rows = size(groupM,1);
							cols = 18;
							rho = [];
							i = 1;
							j = 1;
							max_h = log2(rows);
							fprintf(mds_out,'\tSize of %s = %d x %d\n',k{sorted_indices(idx)},rows,cols);
							while i <= cols
								j = i+1;
								i_col = [];
								for i_col_it=1:rows
									i_col = [i_col; groupM(i_col_it).values(i)];
								end
								while j <= cols
									j_col = [];
									for j_col_it=1:rows
										j_col = [j_col; groupM(j_col_it).values(j)];
									end
									c = mi(i_col, j_col);
									% c = 1 / (c / max_h);
									c = 1 / c;
									rho = [rho c];
									j = j + 1;
								end
								i = i + 1;
							end

							[Y,eigvals] = cmdscale(rho);

							if min(Y(:,1)) < mins_maxes(1,1)
								mins_maxes(1,1) = min(Y(:,1));
							end
							if max(Y(:,1)) > mins_maxes(1,2)
								mins_maxes(1,2) = max(Y(:,1));
							end
							if min(Y(:,2)) < mins_maxes(2,1)
								mins_maxes(2,1) = min(Y(:,2));
							end
							if max(Y(:,2)) > mins_maxes(2,2)
								mins_maxes(2,2) = max(Y(:,2));
							end
							if min(Y(:,3)) < mins_maxes(3,1)
								mins_maxes(3,1) = min(Y(:,3));
							end
							if max(Y(:,3)) > mins_maxes(3,2)
								mins_maxes(3,2) = max(Y(:,3));
							end
						end
					end

					mins_maxes(:,1) = floor(mins_maxes(:,1));
					mins_maxes(:,2) = ceil(mins_maxes(:,2));

					for g=1:size(render_points,2)
						idx = render_points(g);
						% remember, groupM is a STRUCT array
						groupM = groupMap(k{sorted_indices(idx)});
						while size(groupM,1) <= min_grp_sz
							idx = idx + 1;
							groupM = groupMap(k{sorted_indices(idx)});
						end
						if g == size(render_points,2) || idx < render_points(g+1)
							fprintf(mds_out,'group %d (Broad list row #%d)\n\t%s\n\tMI = %f / %f = %f\n', ...
								g, ...
								sorted_indices(idx), ...
								k{sorted_indices(idx)}, ...
								broad_distribs(sorted_indices(idx),num), ...
								broad_distribs(sorted_indices(idx),denom), ...
								(broad_distribs(sorted_indices(idx),num) / broad_distribs(sorted_indices(idx),denom)) ...
							);
							headers = {'a1','a2','a3','b1','b2','b3','c1','c2','c3','d1','d2','d3','e1','e2','e3','f1','f2','f3'};
							rows = size(groupM,1);
							cols = 18;
							rho = [];
							i = 1;
							j = 1;
							max_h = log2(rows);
							fprintf(mds_out,'\tSize of %s = %d x %d\n',k{sorted_indices(idx)},rows,cols);
							while i <= cols
								j = i+1;
								i_col = [];
								for i_col_it=1:rows
									i_col = [i_col; groupM(i_col_it).values(i)];
								end
								while j <= cols
									j_col = [];
									for j_col_it=1:rows
										j_col = [j_col; groupM(j_col_it).values(j)];
									end
									c = mi(i_col, j_col);
									% simply inverting MI to get a very rough analog of "distance"
									c = 1 / c;
									rho = [rho c];
									j = j + 1;
								end
								i = i + 1;
							end

							[Y,eigvals] = cmdscale(rho);

							[rows_l,cols_l] = size(Y);
							Y_range = Y(:,1);
							label_threshold = 0.001 * max(abs(max(Y(:,1))),abs(min(Y(:,1))));
							text_offset = (max(Y(:,1)) - min(Y(:,1))) / 65;

							if render_figure == 2
								colors = zeros(18,3);
								colors(1,:) = [150, 165, 55];
								colors(2,:) = colors(1,:);
								colors(3,:) = colors(1,:);
								colors(4,:) = [48, 60, 116];
								colors(5,:) = colors(4,:);
								colors(6,:) = colors(4,:);
								colors(7,:) = [41, 123, 72];
								colors(8,:) = colors(7,:);
								colors(9,:) = colors(7,:);
								colors(10,:) = [104, 38, 111];
								colors(11,:) = colors(10,:);
								colors(12,:) = colors(10,:);
								colors(13,:) = [170, 77, 57];
								colors(14,:) = colors(13,:);
								colors(15,:) = colors(13,:);
								colors(16,:) = [100, 100, 100];
								colors(17,:) = colors(16,:);
								colors(18,:) = colors(16,:);
								colors = colors * 1.5;
								colors = colors / 255;

								figure('Visible','off');
								clf;
								axis equal;
								axis([mins_maxes(1,1) mins_maxes(1,2) mins_maxes(2,1) mins_maxes(2,2) mins_maxes(3,1) mins_maxes(3,2)]);
								hold on;
								grid on;
								row_idx = 1;
								rendered_stuff = [];
								while row_idx <= rows_l
									color = colors(row_idx,:);
									msize = resolution*0.8;
									h = plot3(Y(row_idx,1), Y(row_idx,2), Y(row_idx,3), 'o', 'Color', color, 'MarkerFaceColor', color, 'markers', msize);
									if sqrt(power(Y(row_idx,1),2) + power(Y(row_idx,2),2) + power(Y(row_idx,3),2)) > label_threshold
										text(Y(row_idx,1), Y(row_idx,2), Y(row_idx,3)+text_offset, headers{row_idx}, 'Color', [0 0 0], 'FontSize', msize);
									end
									rendered_stuff = [rendered_stuff h];
									row_idx = row_idx + 1;
								end
								hold off;
								view(-45, 20);
								set(gca, 'FontSize', resolution);
								set(gca, 'XTickLabel', {});
								set(gca, 'YTickLabel', {});
								set(gca, 'ZTickLabel', {});

								fig = gcf;
								fig.PaperUnits = 'inches';
								fig.PaperPosition = [0 0 resolution resolution];
								fig.PaperPositionMode = 'manual';
								t = title(k{sorted_indices(idx)}, 'FontSize', resolution*1.25);
								set(t,'interpreter','none');
								print(['output/layeredhist_',combos(num),'-',combos(denom),'_group',num2str(g)],'-dpng','-r0');

							end
						else
							fprintf('Skipping %d - no group > %d near these points!\n',g,min_grp_sz);
						end
					end

					mins_maxes

					fclose(mds_out);
				end
				if render_figure == 0
					fclose(output1);
					fclose(output2);
				end
			end

		end

		if specific_num > 0 && specific_denom > 0
			break;
		end

	end

	if specific_num > 0 && specific_denom > 0
		break;
	end

end