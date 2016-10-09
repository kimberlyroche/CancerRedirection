function parent_groups = parent_gene_group(gene, gene_groups)
	% gene_groups is a cell array of cell arrays
	% gene_groups = {
	%					{ 'group name 1', 'member gene 1', 'member gene 2', ... },
	%					{ 'group name 2', 'member gene 3', 'member gene 4', ... },
	%					...
	parent_groups = {};
	grp_sz = numel(gene_groups);
	for i=1:grp_sz
		current_group = gene_groups{i};
		if ismember(gene, current_group(2:numel(current_group)))
			parent_groups = [parent_groups current_group{1}];
		end
	end
end