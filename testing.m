% heatmaps of 20 groups by probeset IDs
%	include extended genes
%	only A, E, B columns
%	later: label extended genes and independently found/significant genes

readM();

% get distributions of the expression levels of A, E, B
as = reshape(M(:,1:3), [size(M,1)*3, 1]);
bs = reshape(M(:,4:6), [size(M,1)*3, 1]);
es = reshape(M(:,13:15), [size(M,1)*3, 1]);

readM_map();
k = keys(mapObj);
k_sz = numel(k);

if ~exist('signif_probesets', 'var')
	% for all probesets
	%	use Wilcoxon rank sum test to determine if:
	%		A1,2,3 is significant (delta median) from A
	%		B1,2,3 is significant (delta median) from A
	%		E1,2,3 is significant (delta median) from A
	% KNOWN ISSUE: p-values are hugely skewed because variation within a row (samples) is much smaller
	%				than variation within the random, unlinked A population; how to correct for?
	signif_probesets = {};
	count = 0;
	alpha = 0.01;
	for i=1:k_sz
		if mod(i,100) == 0
			fprintf('Iteration %d\n', i);
		end
		current_row = mapObj(k{i});
		a_sig = ranksum(as, current_row(1:3));
		b_sig = ranksum(bs, current_row(4:6));
		e_sig = ranksum(es, current_row(13:15));
		if a_sig <= alpha && b_sig <= alpha && e_sig <= alpha
			signif_probesets = [signif_probesets k{i}];
		end
	end
end

database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

mu_a = mean(as);
mu_b = mean(bs);
mu_e = mean(es);
sig_sz = numel(signif_probesets);
for i=1:sig_sz
	% for probesets significant in A, E, B
	%	filter those matching (A < mu && E < mu && B > mu) || (A > mu && E > mu && B < mu)
	current_row = mapObj(signif_probesets{i});
	mu_sample_a = mean(current_row(1:3));
	mu_sample_b = mean(current_row(4:6));
	mu_sample_e = mean(current_row(13:15));
	flag = false;
	if mu_sample_a < mu_a && mu_sample_e < mu_e && mu_sample_b > mu_b
		fprintf('DN: ');
		flag = true;
	elseif mu_sample_a > mu_a && mu_sample_e > mu_e && mu_sample_b < mu_b
		fprintf('UP: ');
		flag = true;
	end
	if flag
		res = probeset2gene(db_obj, signif_probesets{i});
		if ~isempty(res)
			fprintf('%s', res(1).gene);
		else
			fprintf('---');
		end
		fprintf('\t%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', signif_probesets{i}, ...
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
	end
end



















