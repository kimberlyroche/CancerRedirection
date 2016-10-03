DB.m
	queries for stub SQLite database

readM.m
	read Affymetrix mouse dataset into 35556 x 18 matrix variable M

build_groupMap.m
	builds group_data.mat

build_bgroup_mi_distributions.m
	builds distribs_mi_broad.mat

build_random_mi_distributions.m
	builds distribs_mi_random.mat

groupMap.mat
	a map of Broad gene set names to arrays of structs; each struct contains a label (gene name + probeset IDs) and expression level values for 18 columns (a1 through f3, in order)
	[
		'3_5_CYCLIC_NUCLEOTIDE_PHOSPHODIESTERASE_ACTIVITY' ->
			[
				struct {
					label: '10441680 (Pde10a)'
   					values: 6.5612  6.5918  6.9070  6.3745  6.6404  6.9715  7.3152  6.5101  6.4954  6.5686  6.4366  6.3212  6.9327  6.5149  6.5708  6.5974  6.3702  6.4804
				},
				struct {
					label: '10484283 (Pde1a)'
   					values: 4.8401  4.9353  4.7353  5.9289  5.4241  5.4251  4.7318  4.8245  4.7497  5.0587  4.8714  4.9736  4.9316  4.7608  4.7304  5.2761  5.1566  5.0022
				},
				...
			],
		'3_5_EXONUCLEASE_ACTIVITY' ->
			...
	]

distribs_mi_broad.mat
	mutual information values between cell classes (A, B, C, D, E, F) for all Broad Inst. gene sets
	13311 rows correspond to Broad Inst. gene sets (ordered alphabetically; identical ordering to keys of groupMap)
	15 columns, in order, are: AxB AxC AxD AxE AxF BxC BxD BxE BxF CxD CxE CxF DxE DxF ExF
	e.g. row 1, col 1 is the mutual information between a1-a2-a3 and b1-b2-b3 for the gene set '3_5_CYCLIC_NUCLEOTIDE_PHOSPHODIESTERASE_ACTIVITY'

distribs_mi_random.mat
	mutual information values between cell classes (A, B, C, D, E, F) for randomly generated sample sets
	12527 rows correspond to sample sets have the same size distribution as the Broad gene sets larger than the minimum group size (10)
	15 columns are same as column in distribs_mi_broad.mat

heatmaps.m
	generates heatmaps for individual Broad gene sets or a heatmap of shared genes (slow!)

histograms.m
	generates histograms for expression level values for each of 18 columns in dataset

histogramstack.m
	generates rendering of histograms for all 18 columns in dataset, spread based on dimension of greatest dissimilarity using multidimensional scaling

mi_groupsize.m
	plots mutual information measurements between a1xa2 and a1xb1 against increasing set size, showing effect of set size on mutual information between a pair of similar and a pair of less similar sets

ratios_histograms_lists.m
	see comments within file about 'render_figure' modes 0, 1, 2

build_pair_network.m
	requires a stub SQLite database with tables "genes" and "pairs"
		CREATE TABLE "genes" (
			`label`	TEXT NOT NULL UNIQUE,
			`ae_delta`	REAL NOT NULL DEFAULT 0,
			`eb_delta`	REAL NOT NULL DEFAULT 0,
			`id`	INTEGER PRIMARY KEY AUTOINCREMENT
		)
		CREATE TABLE "pairs" (
			`g1_id`	INTEGER,
			`g2_id`	INTEGER,
			`parent_group`	INTEGER,
			PRIMARY KEY(g1_id,g2_id,parent_group)
		)

	outputs a file "pairs.txt" with gene 1 name, gene 2 name, and parent group (containing the pair) suitable for import into Cytoscape