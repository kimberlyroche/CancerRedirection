% scores probeset or gene as being statistically significant on the basis of adjusted p values already present
%	in the DEG matrix
% identifier = gene or probeset identifier
% is_gene = true if identifier is a gene name; false if identifier is a probeset ID
% DEP_map = existing reference to the DEG map obj (slow to load, so loaded in the calling script and passed down)
% threshold = (if multiple transcripts for a gene)
%		1 if only one transcript (probeset) must be significant for gene to be significant
%		2 if half or more transcripts represent significance threshold
%		3 if ALL transcripts must be significant for this gene to be significant
function r = probesetDEGsignificant(identifier, is_gene, DEG_map, threshold)
	ab_col = 1;
	ae_col = 4;
	be_col = 7;
	alpha = 0.01;
	if ~is_gene
		% if identifier is a gene, check it for significance against the DEG matrix
		row_of_interest = DEG_map(identifier);
		r = false;
		if row_of_interest(ab_col) < alpha && row_of_interest(be_col) < alpha && row_of_interest(ae_col) > alpha
			r = true;
		end
	else
		% identifier is a gene name - this is tougher
		% grab probesets associated with this gene
		database_path = 'annotations.db';
		sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
		db_obj = DB(database_path, sqlite3_path);
		pids = gene2probeset(db_obj, identifier);
		if isempty(pids)
			r = false;
		elseif numel(pids) == 1
			% if there is one probeset associated with this gene, its significance in the DEG matrix is the gene's significance
			row_of_interest = DEG_map(pids(1).probeset);
			r = false;
			if row_of_interest(ab_col) < alpha && row_of_interest(be_col) < alpha && row_of_interest(ae_col) > alpha
				r = true;
			end
		else
			% if there are more than one probesets associated with this gene, require the majority of them to be significant for the
			%	gene itself to be considered significant
			r = false;
			sigs = [];
			for i=1:numel(pids)
				row_of_interest = DEG_map(pids(i).probeset);
				if row_of_interest(ab_col) < alpha && row_of_interest(be_col) < alpha && row_of_interest(ae_col) > alpha
					if threshold == 1
						r = true;
						break;
					end
					sigs = [sigs 1];
				else
					if threshold == 2
						sigs = [sigs -1];
					elseif threshold == 3
						sigs = [sigs 0];
					end
				end
			end
			if threshold == 2
				if sum(sigs) >= 0
					r = true;
				end
			elseif threshold == 3
				if sum(sigs) == numel(pids)
					r = true;
				end
			end
		end
	end
end