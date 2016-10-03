% outputs all pairs of genes present in each group listed in groupsnames{}
% 	pairs list can be imported into Cytoscape to generate a network
%
% run with build_db = true to insert the pairs in to the database
% run with build_db = false to output the pairs.txt file

build_db = true;

if(~exist('groupMap','var'))
	load('groups_data.mat');
end

gkeys = keys(groupMap);
groupnames = { ...
	'PID_CERAMIDE_PATHWAY', ...
	'KEGG_BASE_EXCISION_REPAIR', ...
	'HUANG_DASATINIB_RESISTANCE_UP', ...
	'MOSERLE_IFNA_RESPONSE', ...
	'FLECHNER_BIOPSY_KIDNEY_TRANSPLANT_OK_VS_DONOR_DN', ...
	'KEGG_SNARE_INTERACTIONS_IN_VESICULAR_TRANSPORT', ...
	'BOGNI_TREATMENT_RELATED_MYELOID_LEUKEMIA_DN', ...
	'SA_PROGRAMMED_CELL_DEATH', ...
	'CROMER_METASTASIS_DN', ...
	'REACTOME_POL_SWITCHING', ...
	'NIKOLSKY_BREAST_CANCER_21Q22_AMPLICON', ...
	'INGA_TP53_TARGETS', ...
	'GOTZMANN_EPITHELIAL_TO_MESENCHYMAL_TRANSITION_UP', ...
	'LANDIS_BREAST_CANCER_PROGRESSION_UP', ...
	'REACTOME_PROCESSIVE_SYNTHESIS_ON_THE_LAGGING_STRAND', ...
	'MOOTHA_FFA_OXYDATION', ...
	'REACTOME_NOTCH_HLH_TRANSCRIPTION_PATHWAY', ...
	'BIOCARTA_CERAMIDE_PATHWAY', ...
	'REACTOME_SOS_MEDIATED_SIGNALLING', ...
	'MILI_PSEUDOPODIA_CHEMOTAXIS_DN' ...
};

% translate groupnames into indices from groupMap, which we're considering our canonical ordering
groups = [];
for i=1:numel(groupnames)
	for j=1:numel(gkeys)
		if(strcmp(gkeys{j}, groupnames{i}) == 1)
			groups = [groups, j];
			j = numel(gkeys) + 1;
		end
	end
end

database_path = '/path/to/genepairs.db';
sqlite3_path = '/path/to/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

if(build_db)
	% first run
	for i=1:size(groups,2)
		g = groupMap(gkeys{groups(i)});
		for k=1:size(g,1)
			gene1 = g(k).label;
			idx1 = findstr(gene1, '(') + 1;
			idx2 = findstr(gene1, ')') - 1;
			gene1 = gene1(idx1:idx2);
			vals = g(k).values;
			ae_d_1 = vals(13) - vals(1);
			ae_d_2 = vals(14) - vals(2);
			ae_d_3 = vals(15) - vals(3);
			ae_delta_1 = mean([ae_d_1, ae_d_2, ae_d_3]);
			eb_d_1 = vals(4) - vals(13);
			eb_d_2 = vals(5) - vals(14);
			eb_d_3 = vals(6) - vals(15);
			eb_delta_1 = mean([eb_d_1, eb_d_2, eb_d_3]);
			for j=(k+1):size(g,1)
				gene2 = g(j).label;
				idx1 = findstr(gene2, '(') + 1;
				idx2 = findstr(gene2, ')') - 1;
				gene2 = gene2(idx1:idx2);
				vals = g(j).values;
				ae_d_1 = vals(13) - vals(1);
				ae_d_2 = vals(14) - vals(2);
				ae_d_3 = vals(15) - vals(3);
				ae_delta_2 = mean([ae_d_1, ae_d_2, ae_d_3]);
				eb_d_1 = vals(4) - vals(13);
				eb_d_2 = vals(5) - vals(14);
				eb_d_3 = vals(6) - vals(15);
				eb_delta_2 = mean([eb_d_1, eb_d_2, eb_d_3]);
				add_gene_pair(db_obj, gene1, gene2, ae_delta_1, ae_delta_2, eb_delta_1, eb_delta_2, groups(i));
			end
		end
	end
else
	% subsequent run
	fid_out = fopen('pairs.txt','w');
	fprintf(fid_out, 'gene1\tgene2\tparentgrpno\n');
	for i=1:numel(groups)
		res = get_all_pairs(db_obj, groups(i));
		for i=1:numel(res)
			s = res(i);
			fprintf(fid_out, '%s\t%s\t%d\n', s.label, s.label_1, s.parent_group);
		end
	end
	fclose(fid_out);
end




