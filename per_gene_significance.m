% for every MGI gene with probesets present in the matrix, calculates the absolute value of the (average difference between E1,2,3 and B1,2,3) / (average difference between E1,2,3 and A1,2,3)
%	high ratios should indicate individual genes that are very divergent in E-B and very similar in A-E

% 1 = do NOT discretize data
% 2 = discretize matrix data with ceil()
discrete_flag = 1;

% 0 = just generate geneScores and ratios data structures
% 1 = calculate ratio for all genes (saved in geneScores struct array); output top 1% to per_gene_significance.txt tab-delimited list
% 2 = calculate ratio for all genes (saved in geneScores struct array); for each of significant groups, map the member genes ratio on the distribution so we can see where the genes that make up these groups cluster
mode_flag = 0;

signif_groups = { ...
	{ 'REACTOME_SOS_MEDIATED_SIGNALLING', 'Cdk1', 'Mapk1', 'Mapk3', 'Grb2', 'Hras', 'Raf1', 'Sos1', 'Map2k1', 'Nras', 'Irs2', 'Kras', 'Irs1', 'Ywhab', 'Map2k2' }, ...
	{ 'BIOCARTA_CERAMIDE_PATHWAY', 'Bcl2', 'Mapk1', 'Mapk3', 'Nfkb1', 'Rela', 'Raf1', 'Tnfrsf1a', 'Map2k1', 'Mapk8', 'Bax', 'Casp8', 'Map3k1', 'Cycs', 'Aifm1', 'Traf2', 'Map2k4', 'Bad', 'Ripk1', 'Smpd1', 'Fadd', 'Tradd', 'Nsmaf' }, ...
	{ 'REACTOME_NOTCH_HLH_TRANSCRIPTION_PATHWAY', 'Rbpj', 'Notch2', 'Crebbp', 'Kat2b', 'Notch4', 'Kat2a', 'Maml1', 'Maml2', 'Maml3', 'Notch3', 'Snw1', 'Mamld1' }, ...
	{ 'MOOTHA_FFA_OXYDATION', 'Acsl1', 'Hadh', 'Nbn', 'Cpt1a', 'Acaa2', 'Acadm', 'Hadhb', 'Acat1', 'Acadvl', 'Echs1', 'Eci1', 'Decr1', 'Hsd17b10', 'Hadha', 'Acadl', 'Acadsb', 'Crat', 'Cpt2', 'Amacr', 'Acads', 'Ncaph2', 'Lmf2' }, ...
	{ 'REACTOME_PROCESSIVE_SYNTHESIS_ON_THE_LAGGING_STRAND', 'Pcna', 'Fen1', 'Pola1', 'Rpa1', 'Rpa3', 'Prim1', 'Lig1', 'Pold1', 'Rpa2', 'Prim2', 'Pold4', 'Pold2', 'Pold3', 'Pola2', 'Dna2' }, ...
	{ 'LANDIS_BREAST_CANCER_PROGRESSION_UP', 'Id2', 'Sox4', 'Ell2', 'Litaf', 'Tpd52', 'Kcnn4', 'Xbp1', 'Vdr', 'Aldoc', 'Fam134b', 'Aim1', 'Nucb2', 'Galnt3', 'Dap', 'Ebp', 'Lcn2', 'Serp1', 'Atp6v1a', 'Cd82', 'Ehf', 'Acsl4', 'Cldn7', 'Lsr', 'Rnf149', 'Tfap2c', 'Irf6', 'Lrrfip1', 'Atp6ap2', 'Cyb561', 'Cmas', 'Wwc1', 'Cldn3', 'Spint1', 'Dsg2', 'Irx3', 'Srp19', 'Strbp', 'Pqlc1', 'Fxyd3', 'Shroom3', 'Chmp2b', 'Golph3' }, ...
	{ 'GOTZMANN_EPITHELIAL_TO_MESENCHYMAL_TRANSITION_UP', 'Jun', 'Ccl2', 'Inhba', 'Gadd45b', 'Brca1', 'Serpine1', 'Mcm3', 'Fn1', 'Itgb1', 'S100a6', 'Mki67', 'Csf1', 'Ctgf', 'Cenpa', 'Furin', 'Timp1', 'Odc1', 'Top1', 'Cyp1b1', 'Tgfb3', 'Chek1', 'Timp3', 'Edn1', 'Hmgb1', 'Plk4', 'Pafah1b1', 'Col1a1', 'Pdgfa', 'Pla2g4a', 'Rbl1', 'Ncam1', 'Smad1', 'Ccl7', 'Col4a2', 'Clu', 'Traf3', 'Col3a1', 'Dck', 'Col4a1', 'Nr2f1', 'Pros1', 'Inhbb', 'Col5a2', 'Tnc', 'Ly75', 'Igfbp7', 'Col18a1', 'Cdh2', 'Cct6a', 'Gata2', 'Ppic', 'Oat', 'Smarcd1', 'Map4', 'Fbln2', 'Chrnb1', 'Tpp2', 'Rbbp6', 'Glg1', 'Rpsa', 'Acta2', 'Zfx', 'Pkp1', 'Snai1', 'Tead2', 'Mpdz' }, ...
	{ 'INGA_TP53_TARGETS', 'Cdkn1a', 'Fos', 'Ier3', 'Gadd45a', 'Pcna', 'Mdm2', 'Thbs1', 'Igfbp3', 'Pmaip1', 'Sesn1', 'Bax', 'Sfn', 'Ccng1', 'Tnfrsf10b', 'Bbc3' }, ...
	{ 'NIKOLSKY_BREAST_CANCER_21Q22_AMPLICON', 'Col18a1', 'Col6a1', 'Lss', 'Col6a2', 'Slc19a1', 'Adarb1', 'Pcnt', 'Pcbp3', 'Mcm3ap', 'Pofut2', 'Dip2a', 'Ftcd', 'Ybey' }, ...
	{ 'REACTOME_POL_SWITCHING', 'Pcna', 'Rfc4', 'Pola1', 'Prim1', 'Rfc3', 'Pold1', 'Prim2', 'Rfc5', 'Rfc2', 'Pold4', 'Pold2', 'Pold3', 'Pola2' }, ...
	{ 'CROMER_METASTASIS_DN', 'Epas1', 'S100a11', 'Sdc4', 'Tuba4a', 'Rab31', 'Cav1', 'Aldoa', 'Plec', 'Lmna', 'Svil', 'Sfn', 'Pfkp', 'Nck1', 'Ckb', 'Flnb', 'Pa2g4', 'Itga3', 'Klf5', 'Impa2', 'Psmd8', 'Atp5a1', 'Dusp7', 'Jup', 'Ddb2', 'Phlda2', 'Cul1', 'Acta1', 'Baiap2', 'Hspa2', 'Tpbg', 'Vdac3', 'Eif3k', 'Tnfrsf10b', 'Bmp1', 'Nop2', 'Mbd2', 'Gstp1', 'Mink1', 'Nop16', 'Cav2', 'Itgb4', 'Aldh4a1', 'Mrps12', 'Celsr1', 'Vsnl1', 'Ube2m', 'Serpinb5', 'Card10', 'Lad1', 'Afg3l2', 'Atp5d', 'Dtx2', 'Mast4', 'Cebpz', 'Igsf3', 'Ttll12', 'Pkp1', 'St6galnac2', 'Sh3gl1', 'Mall', 'Gjb3', 'Trim29', 'Col17a1', 'Fxyd3', 'Ppp4c', 'Slc20a2', 'Evpl', 'Prss3', 'Prodh', 'Klk10', 'Ube3c', 'Tmem183a', 'Isg20l2', 'Kazn', 'Tnnt3', 'Trim16', 'Ticam1', 'Flad1' }, ...
	{ 'SA_PROGRAMMED_CELL_DEATH', 'Bcl2', 'Bcl2l1', 'Bcl2l11', 'Bcl10', 'Bid', 'Bax', 'Casp9', 'Apaf1', 'Bak1', 'Bad', 'Casp8ap2' }, ...
	{ 'BOGNI_TREATMENT_RELATED_MYELOID_LEUKEMIA_DN', 'Ccnd1', 'Myb', 'Pim2', 'Ccng2', 'Ddx17', 'Srsf6', 'Cd2ap', 'Ddr1', 'Ccng1', 'Acox1', 'Cdh2', 'Tnfrsf10b', 'Rgl2', 'Sec62', 'Ppt2', 'Fbxo21', 'Cdk8', 'Zfyve26', 'Rxrb', 'Prep', 'Tbc1d5', 'Nr2c1', 'Mrpl28', 'Sec24a', 'Nktr', 'Vti1b', 'Vps52', 'Fscn2' }, ...
	{ 'KEGG_SNARE_INTERACTIONS_IN_VESICULAR_TRANSPORT', 'Stx11', 'Vamp3', 'Vamp5', 'Vamp8', 'Stx6', 'Stx3', 'Vamp1', 'Stx1a', 'Vamp2', 'Stx7', 'Stx16', 'Snap25', 'Bet1', 'Stx12', 'Bnip1', 'Snap23', 'Stx2', 'Use1', 'Vamp4', 'Ykt6', 'Gosr2', 'Gosr1', 'Bet1l', 'Snap29', 'Stx8', 'Vti1b', 'Stx17', 'Sec22b', 'Vamp7', 'Stx18', 'Vti1a', 'Stx1b', 'Snap47', 'Stx19' }, ...
	{ 'FLECHNER_BIOPSY_KIDNEY_TRANSPLANT_OK_VS_DONOR_DN', 'Fos', 'Myc', 'Bax', 'Rbms1', 'Nf2', 'Xrcc6', 'Eif2ak2', 'Blmh', 'Pcf11', 'Brd2', 'Gpaa1', 'Krt7', 'Atp5b', 'Ap1b1', 'Usp22', 'Gss', 'Usp9x', 'Paxip1', 'Tmem11', 'Rhbdf1', 'Cadm4', 'C1ql1' }, ...
	{ 'MOSERLE_IFNA_RESPONSE', 'Stat1', 'Cxcl10', 'Tnfsf10', 'Ifit1', 'Rsad2', 'Ifit3', 'Mx1', 'Ifit2', 'Ifitm1', 'Ifih1', 'Oas2', 'Usp18', 'Ifi44', 'Rtp4', 'Ddx60', 'Ddx58', 'Ifi44l', 'Cd274', 'Cmpk2', 'Epsti1', 'Samd9l', 'Zc3hav1' }, ...
	{ 'HUANG_DASATINIB_RESISTANCE_UP', 'Anxa1', 'Lyn', 'Egfr', 'Ell2', 'Psmb9', 'Ifit3', 'Tgfbr2', 'Ext1', 'Tgfbi', 'Psmb8', 'Cdc42ep3', 'Upp1', 'Jag1', 'Cav1', 'Prnp', 'Kctd12', 'Il15ra', 'Ndc80', 'F2rl1', 'Plau', 'Elk3', 'Ephb2', 'Rac2', 'Met', 'Tnfrsf21', 'Dusp10', 'Cotl1', 'Myo10', 'F3', 'Epha2', 'Cald1', 'Cast', 'Zyx', 'Itga5', 'Pcdh7', 'Fstl1', 'Lamb3', 'Tfpi', 'Msn', 'Lima1', 'Gng12', 'Inpp1', 'Socs5', 'Pdgfc', 'Ptrf', 'Fxyd5', 'Col5a1', 'Nnmt', 'Pgm1', 'Rexo2', 'Dpyd', 'Dcbld2', 'Ube2e3', 'Arhgap29', 'Snai2', 'Antxr2', 'Samd9l', 'Cav2', 'Osmr', 'St5', 'Maml2', 'Rai14', 'Sh3kbp1', 'Ripk4', 'Agps', 'Map7d1', 'Ppp1r18', 'Ccdc50', 'Parva', 'Layn', 'Popdc3', 'Larp6', 'Gbp3' }, ...
	{ 'KEGG_BASE_EXCISION_REPAIR', 'Pcna', 'Fen1', 'Hmgb1', 'Lig1', 'Pole2', 'Pold1', 'Ung', 'Parp1', 'Apex1', 'Pold4', 'Pold2', 'Pole', 'Pold3', 'Pole3', 'Mbd4', 'Polb', 'Parp3', 'Ogg1', 'Lig3', 'Parp2', 'Neil3', 'Nthl1', 'Mutyh', 'Mpg', 'Tdg', 'Parp4', 'Xrcc1', 'Neil1', 'Pole4', 'Apex2', 'Poll', 'Neil2' }, ...
	{ 'PID_CERAMIDE_PATHWAY', 'Myc', 'Tnf', 'Nfkbia', 'Bcl2', 'Mapk1', 'Birc3', 'Mapk3', 'Nfkb1', 'Akt1', 'Igf1', 'Rela', 'Raf1', 'Prkcd', 'Tnfrsf1a', 'Map2k1', 'Map4k4', 'Rb1', 'Bid', 'Mapk8', 'Bax', 'Casp8', 'Map3k1', 'Pdgfa', 'Ctsd', 'Eif2ak2', 'Cycs', 'Asah1', 'Egf', 'Map2k2', 'Aifm1', 'Traf2', 'Map2k4', 'Prkcz', 'Pawr', 'Madd', 'Bad', 'Ripk1', 'Smpd1', 'Prkra', 'Fadd', 'Tradd', 'Nsmaf', 'Cradd', 'Ksr1', 'Smpd3', 'Sphk2', 'Bag4', 'Eif2a' }, ...
	{ 'MILI_PSEUDOPODIA_CHEMOTAXIS_DN', 'Fos', 'Dusp1', 'Nrp1', 'Txnip', 'Tgif1', 'Il6st', 'Socs3', 'Serpine1', 'Vcl', 'Btg1', 'Mapk14', 'Timp2', 'Fn1', 'Cd9', 'Itgb1', 'Gsk3b', 'Igf1r', 'App', 'Adrb2', 'Zfp36', 'Klf6', 'Slc20a1', 'Thbs1', 'Pdgfra', 'Ddit3', 'Slc2a1', 'Kcnn4', 'Map4k4', 'Ldlr', 'Ppt1', 'Nfkbiz', 'S100a10', 'Lamc1', 'Trps1', 'Prnp', 'Acvr1', 'Zmynd8', 'Ilf3', 'Nrp2', 'Gla', 'Ctsb', 'Timp3', 'Pik3ip1', 'Ptgs1', 'Grn', 'Fgfr1', 'Slc11a2', 'Fosb', 'Ly6e', 'Plat', 'Hmgcs1', 'Slc16a1', 'Hspa8', 'Abcc5', 'Tapbp', 'Sgms1', 'Rtn4', 'P2rx4', 'Nedd4l', 'Rgs3', 'Tlr2', 'Lrp1', 'Aplp2', 'Lgmn', 'Eif2ak3', 'Klf3', 'Gnb1', 'Ctnna1', 'Adora2b', 'Ogt', 'Npc1', 'Cux1', 'Sun2', 'Flnb', 'Ckap4', 'Mmp14', 'F3', 'Chuk', 'Slc4a7', 'Cald1', 'Ddr1', 'Nfib', 'Axl', 'Itga3', 'Psap', 'Calu', 'Angptl2', 'Slc1a4', 'Plagl2', 'Adar', 'Psmd1', 'Slc38a2', 'Itga5', 'Srebf2', 'Nono', 'Abcc1', 'Slc39a14', 'Slc29a1', 'Hspa5', 'Gns', 'H3f3b', 'Col4a1', 'Serinc3', 'Rara', 'Dag1', 'Akap1', 'Gspt1', 'Clic1', 'Zmiz1', 'Serpinf1', 'Pdgfrb', 'P4ha1', 'Dgkz', 'Ctnnb1', 'Atp1a1', 'Acly', 'Ube2b', 'Tnfsf9', 'Sfpq', 'Qsox1', 'Fus', 'Epb41l2', 'Rrbp1', 'Plxnb2', 'Clcf1', 'Snx5', 'Hmgcr', 'Fzd7', 'Ero1l', 'Atpif1', 'Sema4c', 'Esyt1', 'Lox', 'Ptprf', 'Myo9b', 'Abca2', 'Tap2', 'Fgf7', 'Baiap2', 'Diaph1', 'Slc7a6', 'Wls', 'Son', 'Rpn1', 'Ndel1', 'Fzd2', 'Ecm1', 'Atox1', 'Sri', 'Slc12a4', 'P4ha2', 'Gpaa1', 'Gnb2l1', 'Col5a1', 'Tpbg', 'Phb2', 'Gprc5b', 'Pgm1', 'Fam53b', 'Dnaja2', 'Bcl9', 'Col4a5', 'Pla2g7', 'Ube2i', 'Pde7a', 'Neu1', 'Atp10a', 'Slc6a6', 'Sgpl1', 'Pdia3', 'Matn2', 'Chka', 'Tln1', 'Rbm39', 'Dgat1', 'Pdia6', 'Lhfpl2', 'Bmp1', 'Mpzl1', 'Slc19a1', 'Rpn2', 'Myl6b', 'Degs1', 'Thrap3', 'Pfkl', 'Pld3', 'Bcap31', 'Ptpra', 'Bclaf1', 'Aqp1', 'Rpl12', 'Tmem109', 'Esd', 'Slc23a2', 'Rpl30', 'Slc44a2', 'Pabpn1', 'Man2b1', 'Plod1', 'Mmp11', 'Fbln2', 'Clta', 'Col16a1', 'Sema3b', 'Scpep1', 'Rps10', 'Pdia5', 'Gaa', 'Dhrs7', 'Ap2a2', 'Wdr26', 'Slc19a2', 'Sigmar1', 'Ccnt2', 'Actl6a', 'Lrrc8c', 'Ddost', 'Htt', 'Clstn1', 'Tra2a', 'Arfgap3', 'Abca3', 'Twsg1', 'Glg1', 'Dzip1', 'Chst12', 'Serinc1', 'Rnps1', 'Pvr', 'Stt3a', 'Hsd17b12', 'Dido1', 'Wwp2', 'Lrp12', 'Elovl1', 'Anxa7', 'Osbpl9', 'Polg', 'Cds2', 'Pkd1', 'Sel1l', 'Clcn4', 'Tubgcp4', 'Tcf25', 'Rpl41', 'Rictor', 'Nisch', 'Naga', 'Mogs', 'Ltbp4', 'Kdelc1', 'Pi4kb', 'Lamb2', 'Adamts5', 'Rab5b', 'Mtch2', 'Por', 'Pim3', 'Metrnl', 'Kdm6b', 'Ggnbp2', 'Agfg2', 'Tor1b', 'Scamp2', 'Pofut1', 'Usp7', 'Sec61a1', 'Matr3', 'Mast4', 'Abca7', 'Rbx1', 'Atrn', 'Impact', 'Ganab', 'Mapk8ip3', 'Txndc5', 'Slco2a1', 'Sema3f', 'Fads3', 'Ankrd11', 'Tmem57', 'Thbs3', 'Fam171a1', 'Cpsf7', 'Rgmb', 'Malat1', 'Igsf3', 'Zdhhc5', 'Tm9sf2', 'Nagk', 'Cspg4', 'Usp14', 'Sbno2', 'Puf60', 'Dgcr2', 'Col4a6', 'Clcn7', 'Sfswap', 'Sf3b3', 'Slc39a7', 'Krit1', 'Dhx30', 'Akr1b10', 'Mpg', 'Chpf', 'Bop1', 'Pnpla7', 'Ndfip2', 'Sod3', 'Adnp2', 'Per3', 'Arhgap17', 'Smg5', 'Pcdh1', 'Dpf2', 'Cnot3', 'Poldip3', 'Lime1', 'Dolk', 'Tmem43', 'Tm9sf1', 'Steap3', 'Plxna3', 'Ahctf1', 'Mst1', 'Ggcx', 'Fibp', 'Emilin1', 'Slc35a2', 'Slc20a2', 'Cd109', 'Zzef1', 'Sptlc1', 'Trmt6', 'Slc38a10', 'Tmed7', 'Lmbrd1', 'Grasp', 'Gmpr2', 'Sun1', 'Npr2', 'Rps24', 'Rcn3', 'Sfi1', 'Naglu', 'Adamtsl4', 'Slc12a9', 'Rnf166', 'Pofut2', 'Msln', 'Ephb4', 'Cldn9', 'Vasn', 'Usp53', 'Tmem33', 'C1galt1c1', 'Ppil2', 'B3gat3', 'Sned1', 'Naa40', 'Zkscan1', 'Syvn1', 'Slc38a4', 'Sec61a2', 'Rpf2', 'Letmd1', 'Slc10a3', 'Pan3', 'Nceh1', 'Igsf8', 'Slc2a10', 'Cnnm2', 'Spns1', 'Mfsd10', 'Edem2', 'Abhd12', 'Rnf10', 'Gmcl1', 'Alg1', 'Slc30a6', 'Ppp6r3', 'Eral1', 'Chpf2', 'Shq1', 'Hiatl1', 'Clcn6', 'Atp13a1', 'Noc2l', 'Snx14', 'Riok1', 'Med15', 'Ncaph2', 'Trim41', 'Ttc19', 'Tmem186', 'Tm2d3', 'Scfd1', 'Ranbp3', 'Abcc10', 'Matn4', 'Ccny', 'Gcn1l1', 'Dnttip1', 'Sppl2a', 'Snhg3', 'Brms1', 'Rpap1', 'Nhlrc3', 'Mfsd11', 'Zc3h4', 'Snrnp48', 'Pigm', 'Atat1', 'Zfyve27', 'Trim35', 'Rusc2', 'Pcdh19', 'Dcbld1', 'Plekhm2', 'Pcnxl3', 'Gpr108', 'Tyw1', 'Pi16', 'Armc9', 'Mfsd9' }
};

siggroup_sz = numel(signif_groups);

% get every unique gene from the database with its probeset(s)
if ~exist('genelist','var')
	fprintf('Querying list of all Broad-associated genes...\n');
	database_path = 'annotations.db';
	sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
	db_obj = DB(database_path, sqlite3_path);
	genelist = getAllGenes(db_obj);
end

fprintf('Reading mouse matrix into map...\n');
readM_map();

if ~exist('geneScores','var') || ~exist('ratios','var')
	geneScores = containers.Map('KeyType','char','ValueType','any');
	ratios = [];
	numerators = [];
	denominators = [];

	glist_sz = numel(genelist);

	fprintf('Calculating gene AE/BE ratios...\n');
	for i=1:glist_sz
		pids = strsplit(genelist(i).probesets, ',');
		pids_sz = numel(pids);
		delta_ae = [];
		delta_be = [];
		if pids_sz > 0
			found = 0;
			for j=1:pids_sz
				if isKey(mapObj, pids{j})
					found = found + 1;
					current_row = mapObj(pids{j});
					if(discrete_flag == 2)
						current_row = ceil(current_row);
					end
					delta_ae = [delta_ae (current_row(13) - current_row(1))];
					delta_ae = [delta_ae (current_row(14) - current_row(2))];
					delta_ae = [delta_ae (current_row(15) - current_row(3))];
					delta_be = [delta_be (current_row(13) - current_row(4))];
					delta_be = [delta_be (current_row(14) - current_row(5))];
					delta_be = [delta_be (current_row(15) - current_row(6))];
				end
			end
			if found > 0
				mean_ae = mean(delta_ae);
				mean_be = mean(delta_be);
				ratio = abs(mean_be / mean_ae);
				geneScores(genelist(i).gene) = struct( ...
					'pids', genelist(i).probesets, ...
					'mean_ae', mean_ae, ...
					'mean_be', mean_be, ...
					'ratio', ratio ...
				);
				if mod(i, 1000) == 0
					fprintf('Iteration %d...\n', i);
				end
				ratios = [ratios ratio];
				numerators = [numerators mean_be];
				denominators = [denominators mean_ae];
			else
				geneScores(genelist(i).gene) = struct([]);
			end
		end
	end

	fprintf('Saving distribution images...\n');
	histogram(ratios);
	saveGCF('ratios');

	histogram(log2(ratios));
	saveGCF('log2_ratios');

	histogram(numerators);
	saveGCF('mean_E-B');

	histogram(denominators);
	saveGCF('mean_A-E');
end

k = keys(geneScores);

if mode_flag == 1
	% print top 1% genes list
	if ~exist('sorted_ratios','var')
		sorted_ratios = sort(ratios);
	end

	idx_cutoff = ceil(numel(sorted_ratios) - 0.01 * numel(sorted_ratios));
	val_cutoff = sorted_ratios(idx_cutoff);
	fprintf('Cutoff value = %f...\n', val_cutoff);

	top_one_percent = true;
	genes_EB_up = 0;
	genes_EB_dn = 0;

	fprintf('Outputing signficance results to "output/per_gene_significance.txt"...\n');
	fid = fopen('output/per_gene_significance.txt', 'w');
	fprintf(fid, 'MGI Gene Name\tRatio\tAverage A-E Delta\tAverage E-B Delta\tPID\tA1\tA2\tA3\tE1\tE2\tE3\tB1\tB2\tB3\tTrend in E from B\tGroups\n');
	for i=1:geneScores.Count
		if ~isempty(geneScores(k{i}))
			if (~top_one_percent || (top_one_percent && geneScores(k{i}).ratio > val_cutoff))
				trend = 0;
				if geneScores(k{i}).mean_be > 0
					trend = 1;
					genes_EB_up = genes_EB_up + 1;
				else
					genes_EB_dn = genes_EB_dn + 1;
				end
				pids = strsplit(geneScores(k{i}).pids, ',');
				pids_sz = numel(pids);

				for j=1:pids_sz
					if j == 1
						fprintf(fid, '%s\t%.4f\t%.4f\t%.4f\t', ...
							k{i}, ...
							geneScores(k{i}).ratio, ...
							geneScores(k{i}).mean_ae, ...
							geneScores(k{i}).mean_be ...
						);
					else
						fprintf(fid, '\t\t\t\t');
					end
					fprintf(fid, '%s', pids{j});
					if isKey(mapObj, pids{j})
						current_row = mapObj(pids{j});
						% a1, a2, a3
						fprintf(fid, '\t%.4f', current_row(1));
						fprintf(fid, '\t%.4f', current_row(2));
						fprintf(fid, '\t%.4f', current_row(3));
						% e1, e2, e3
						fprintf(fid, '\t%.4f', current_row(13));
						fprintf(fid, '\t%.4f', current_row(14));
						fprintf(fid, '\t%.4f', current_row(15));
						% b1, b2, b3
						fprintf(fid, '\t%.4f', current_row(4));
						fprintf(fid, '\t%.4f', current_row(5));
						fprintf(fid, '\t%.4f', current_row(6));
					else
						fprintf(fid, '\t\t\t\t\t\t\t\t\t');
					end
					if j == 1
						% E - B trend
						if trend == 1
							fprintf(fid, '\tUP');
						else
							fprintf(fid, '\tDN');
						end
						% get groups
						assoc_groups = gene2group(db_obj, k{i});
						bgroup_sz = numel(assoc_groups);
						for m=1:bgroup_sz
							member = false;
							for n=1:siggroup_sz
								if strcmp(upper(assoc_groups(m).bgroup), signif_groups{n}{1})
									member = true;
								end
							end
							if member
								fprintf(fid, '\t%s', upper(assoc_groups(m).bgroup));
							end
						end
						for m=1:bgroup_sz
							member = false;
							for n=1:siggroup_sz
								if ~strcmp(upper(assoc_groups(m).bgroup), signif_groups{n}{1})
									member = true;
								end
							end
							if member
								fprintf(fid, '\t%s', lower(assoc_groups(m).bgroup));
							end
						end
					end
					fprintf(fid, '\n');
				end
			end
		end
	end
	fclose(fid);

	fprintf('Genes UP in E from B = %d\n', genes_EB_up);
	fprintf('Genes DN in E from B = %d\n', genes_EB_dn);
elseif mode_flag == 2
	for i=1:siggroup_sz
		clf;
		hold on;
		ksdensity(log2(ratios));
		for j=2:numel(signif_groups{i})
			gene = signif_groups{i}{j};
			gene_score = log2(geneScores(gene).ratio);
			fprintf('gene = %s, ratio = %.4f\n', gene, log2(geneScores(gene).ratio));
			plot(gene_score, 0.01, 'r.', 'MarkerSize', 10);
		end
		hold off;
		t = title(signif_groups{i}{1});
		set(t, 'interpreter', 'none');
		saveGCF(['group',num2str(i)]);
	end
end







