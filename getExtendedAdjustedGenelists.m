% grabs "extended" gene lists and returns only those "significant" w/r/t AB, AE, BE relationships
function genes_adjnew = getExtendedAdjustedGenelists(DEG_map)
	genes_new = getExtendedGenelists();
	genes_adjnew = {};
	for i=1:numel(genes_new)
		genelist = genes_new{i};
		sublist = {genelist{1}};
		for j=2:numel(genelist)
			if probesetDEGsignificant(genelist{j}, true, DEG_map, 1)
				sublist = [sublist genelist{j}];
			end
		end
		genes_adjnew = [genes_adjnew {sublist}];
	end
end