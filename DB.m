classdef DB
	properties
		db_path = '';
	end
	methods
		function obj = DB(db_path, sqlite3_path)
			addpath(genpath(sqlite3_path));
			obj.db_path = db_path;
		end
		function r = probeset2gene(obj, probeset_label)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT gene FROM probeset_genes WHERE probeset=?', probeset_label);
			sqlite3.close();
		end
		function r = probesetbygene(obj)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT gene, GROUP_CONCAT(probeset,",") pids FROM probeset_genes GROUP BY gene');
			sqlite3.close();
		end
		function r = gene2probeset(obj, gene_label)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT probeset FROM probeset_genes WHERE gene=?', gene_label);
			sqlite3.close();
		end
		function r = gene2group(obj, gene_label)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT bgroup FROM genes_groups WHERE gene=? ORDER by bgroup ASC', gene_label);
			sqlite3.close();
		end
		function r = group2gene(obj, group_label)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT gene FROM genes_groups WHERE bgroup=?', group_label);
			sqlite3.close();
		end
		function r = probeset2group(obj, probeset_label)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT bgroup FROM genes_groups WHERE gene IN (SELECT gene FROM probeset_genes WHERE probeset=?)', probeset_label);
			sqlite3.close();
		end
		function r = group2probeset(obj, group_label)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT probeset FROM probeset_genes WHERE gene IN (SELECT gene FROM genes_groups WHERE bgroup=?)', group_label);
			sqlite3.close();
		end
		function r = group2probeset_gene_pairs(obj, group_label)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT gene, GROUP_CONCAT(probeset,",") AS pids FROM probeset_genes WHERE gene IN (SELECT gene FROM genes_groups WHERE bgroup=?) GROUP BY gene', group_label);
			sqlite3.close();
		end
		function r = getNgroups(obj, offset, N)
			db_id = sqlite3.open(obj.db_path);
			% removed ORDER BY RANDOM()
			r = sqlite3.execute(db_id, 'SELECT DISTINCT bgroup FROM genes_groups LIMIT ? OFFSET ?', N, offset);
			sqlite3.close();
		end
		function r = getAllGenes(obj)
			db_id = sqlite3.open(obj.db_path);
			r = sqlite3.execute(db_id, 'SELECT gene, GROUP_CONCAT(probeset) AS probesets FROM probeset_genes GROUP BY gene');
			sqlite3.close();
		end
		function r = count_probeset2gene(obj, probeset_label)
			db_id = sqlite3.open(obj.db_path);
			res = sqlite3.execute(db_id, 'SELECT COUNT(gene) AS num FROM probeset_genes WHERE probeset=?', probeset_label);
			r = res.num;
			sqlite3.close();
		end
		function r = count_gene2probeset(obj, gene_label)
			db_id = sqlite3.open(obj.db_path);
			res = sqlite3.execute(db_id, 'SELECT COUNT(probeset) AS num FROM probeset_genes WHERE gene=?', gene_label);
			r = res.num;
			sqlite3.close();
		end
		function r = add_gene_pair(obj, gene1_label, gene2_label, g1_ae_delta, g2_ae_delta, g1_eb_delta, g2_eb_delta, group)
			db_id = sqlite3.open(obj.db_path);
			sqlite3.execute(db_id, 'INSERT OR IGNORE INTO genes(label, ae_delta, eb_delta) VALUES(?, ?, ?)', gene1_label, g1_ae_delta, g1_eb_delta);
			sqlite3.execute(db_id, 'INSERT OR IGNORE INTO genes(label, ae_delta, eb_delta) VALUES(?, ?, ?)', gene2_label, g2_ae_delta, g2_eb_delta);
			%{
			res = sqlite3.execute(db_id, 'SELECT id FROM genes WHERE label=? LIMIT 1', gene1_label);
			g1_id = res.id;
			res = sqlite3.execute(db_id, 'SELECT id FROM genes WHERE label=? LIMIT 1', gene2_label);
			g2_id = res.id;
			res = sqlite3.execute(db_id, 'SELECT occurance FROM pairs WHERE (g1_id=? AND g2_id=?) OR (g1_id=? AND g2_id=?)', g1_id, g2_id, g2_id, g1_id);
			if(numel(res) > 0)
				if(g1_id < g2_id)
					sqlite3.execute(db_id, 'UPDATE pairs SET occurance=(occurance+1) WHERE g1_id=? AND g2_id=?', g1_id, g2_id);
				else
					sqlite3.execute(db_id, 'UPDATE pairs SET occurance=(occurance+1) WHERE g1_id=? AND g2_id=?', g2_id, g1_id);
				end
			else
				if(g1_id < g2_id)
					sqlite3.execute(db_id, 'INSERT INTO pairs(g1_id, g2_id, occurance, parent_group) VALUES(?, ?, 1, ?)', g1_id, g2_id, group);
				else
					sqlite3.execute(db_id, 'INSERT INTO pairs(g1_id, g2_id, occurance, parent_group) VALUES(?, ?, 1, ?)', g2_id, g1_id, group);
				end
			end
			%}
			sorted_gene_labels = sort({gene1_label, gene2_label});
			if(strcmp(sorted_gene_labels{1}, gene1_label) == 1)
				sqlite3.execute(db_id, 'INSERT OR IGNORE INTO pairs(g1_id, g2_id, parent_group) VALUES((SELECT id FROM genes WHERE label=? LIMIT 1), (SELECT id FROM genes WHERE label=? LIMIT 1), ?)', gene1_label, gene2_label, group);
			else
				sqlite3.execute(db_id, 'INSERT OR IGNORE INTO pairs(g1_id, g2_id, parent_group) VALUES((SELECT id FROM genes WHERE label=? LIMIT 1), (SELECT id FROM genes WHERE label=? LIMIT 1), ?)', gene2_label, gene1_label, group);
			end
			sqlite3.close();
		end
		function r = get_all_pairs(obj, group)
			db_id = sqlite3.open(obj.db_path);
			if(strcmp(group, '') == 1)
				r = sqlite3.execute(db_id, 'SELECT g1.label, g2.label, p.parent_group FROM (pairs p LEFT JOIN genes g1 ON g1.id=p.g1_id) LEFT JOIN genes g2 ON g2.id=p.g2_id');
			else
				r = sqlite3.execute(db_id, 'SELECT g1.label, g2.label, p.parent_group FROM (pairs p LEFT JOIN genes g1 ON g1.id=p.g1_id) LEFT JOIN genes g2 ON g2.id=p.g2_id WHERE p.parent_group=?', group);
			end
			sqlite3.close();
		end
	end
end
