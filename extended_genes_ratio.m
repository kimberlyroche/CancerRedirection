addpath(genpath('/Applications/MATLAB_R2015a.app/toolbox/MIToolbox'));

% pulled from csv output of ratios_histograms_lists.m, not too sophisticated
genes_orig = { ...
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

% pulled from Chenyang's GeneMania spreadsheet GENEMANIA_CANCER_MOUSE_PATHWAY_ANALYSIS_V4 > NEW_GENELIST tab
% genes_new = { ...
% 	{ 'REACTOME_SOS_MEDIATED_SIGNALLING', 'Rassf5', 'Shoc2', 'Gab1', 'Igf1r', 'Kcnk3', 'Il4ra', 'Ptprr', 'Tlk2', 'Pik3r3' }, ...
% 	{ 'BIOCARTA_CERAMIDE_PATHWAY', 'Dusp6', 'Cebpb', 'Atg5', 'Pea15a', 'Ywhaq' }, ...
% 	{ 'REACTOME_NOTCH_HLH_TRANSCRIPTION_PATHWAY', 'Notch1', 'Dll1', 'Egfl7', 'Taf5l', 'Gli3', 'Ncor2', 'Jag2', 'Cntn1', 'Dll4', 'Aph1a', 'Phf2', 'Tada2a' }, ...
% 	{ 'MOOTHA_FFA_OXYDATION', 'Etfa', 'Ech1', '5033411D12Rik', 'Hsdl2', 'Plin5', 'Slc25a20', 'Etfb', 'Eci2', 'Ivd', 'Ptgr2', 'Hibadh', 'Hibch', 'Acad12', 'Etfdh', 'Clybl', 'Dbt', 'D2hgdh', 'Lmf1' }, ...
% 	{ 'REACTOME_PROCESSIVE_SYNTHESIS_ON_THE_LAGGING_STRAND', 'Tipin', 'Timeless', 'Blm', 'Fam96b', 'Rmi1' }, ...
% 	{ 'LANDIS_BREAST_CANCER_PROGRESSION_UP', 'Epcam', 'Esrp1', 'Ceacam1', 'Rhpn2', 'Wfdc18', '1600029D21Rik', 'Sh3bgrl2', 'Tm9sf3', 'Cdcp1', 'Erbb3', 'Crb3', 'Tmem30b', 'Serinc3', 'Arhgef5', 'Knop1', 'Krt18', 'Krt8', 'Arfgap3' }, ...
% 	{ 'GOTZMANN_EPITHELIAL_TO_MESENCHYMAL_TRANSITION_UP', 'Sparc', 'Postn', 'Col1a2', 'Lox', 'Nid1', 'Smc2', 'Fbn1', 'Ect2', 'Hspg2', 'Eln', 'Mcm4', 'C330027C09Rik', 'Lum', 'Ccna2', 'Myadm', 'Thbs2', 'Mad2l1' }, ...
% 	{ 'INGA_TP53_TARGETS', 'Errfi1', 'Dctn2', 'Ccnd2', 'Dhcr24', 'Tbl3', 'Casp3', 'Bnc1', 'Schip1', 'Moap1', 'Rpl11', 'Mtbp', 'Atf7' }, ...
% 	{ 'NIKOLSKY_BREAST_CANCER_21Q22_AMPLICON', 'Col6a3', 'Eny2', 'Gem', 'Rabgap1', 'Rnps1', 'Clstn1', 'Akap9', 'Rbm10', 'Tgm2', 'Tnik' }, ...
% 	{ 'REACTOME_POL_SWITCHING', 'Prpf38a', 'Poldip3', 'Wdhd1', 'Rel', 'Chaf1a', 'Chtf18', 'Cnot8', 'Rqcd1', 'Mrpl38', 'Cnot6', 'Enoph1', 'Lsm6', 'Metap2', 'Uso1', 'Stk40', 'Kctd13' }, ...
% 	{ 'CROMER_METASTASIS_DN', 'Flot2', 'Krt6a', 'Krt14', 'Tacstd2', 'Krt17', 'Dynll1', 'Dsp', 'Perp', 'Pkp3', 'Lama3', 'Ckm', 'Itga6', 'Dtx3', 'Dsc1', 'Dnm1', 'Eml1', 'Cand2' }, ...
% 	{ 'SA_PROGRAMMED_CELL_DEATH', 'Bok', 'Bik', 'Sp100', 'Card11', 'Dnm1l', 'Bcl2l14', 'Bmf', 'Bcl2l10', 'Hrk' }, ...
% 	{ 'BOGNI_TREATMENT_RELATED_MYELOID_LEUKEMIA_DN', 'Rala', 'Cdk4', 'Hipk2', 'Nlk', 'Ppp2r5a', 'Nrip1', 'Poldip2', 'Rara', 'Ptprm', 'Ppp2r5c', 'Wdr77', 'Synpo', 'Exoc1', 'Creb3l4' }, ...
% 	{ 'KEGG_SNARE_INTERACTIONS_IN_VESICULAR_TRANSPORT', 'Stx4a', 'Azi1', 'Aimp1', 'Clip2', 'Stx5a', 'Napa', 'Lztfl1', 'Uaca', 'Gcc1', 'Ift57', 'Tmcc2', 'Vps16', 'Vps53', 'Exoc5', 'Abi2', 'Stxbp6' }, ...
% 	{ 'FLECHNER_BIOPSY_KIDNEY_TRANSPLANT_OK_VS_DONOR_DN', 'Dcc', 'Ddx52', 'Cxxc1', 'Rps9', 'Grlf1', 'Dnajc1', 'A2m', 'Snx9', 'Plscr1', 'Snx33', 'Slc17a9', 'Apbb2' }, ...
% 	{ 'MOSERLE_IFNA_RESPONSE', 'Oasl2', 'Irf7', 'Parp9', 'Parp14', 'Dhx58', 'Stat2', 'Mx2', 'Slfn8', 'Trim25', 'Zbp1', 'Gbp6', 'Xaf1', 'Isg15' }, ...
% 	{ 'HUANG_DASATINIB_RESISTANCE_UP', 'Tgfbr1', 'Gbp2', 'Igtp', 'Irgm2', 'Irgm1', 'Gbp7', 'Ifi47', 'Tgfb1', 'Ilk', 'Tap1', 'Ly6a', 'Cyb5r3', 'Tpm4', 'Il15'}, ...
% 	{ 'KEGG_BASE_EXCISION_REPAIR', 'Aplf', 'Snrpf', 'Msh6', 'Lrsam1', 'Chrac1', 'Exo1', 'Stk19', 'Dr1', 'Aptx', 'Polm', 'Gen1', 'Dntt', 'Lig4', 'Rev3l', 'Tle1', 'Ercc5' }, ...
% 	{ 'PID_CERAMIDE_PATHWAY', 'Mcl1', 'Cflar', 'Trpc4ap', 'Traf1', 'Fas', 'Ikbkg', 'Stat3', 'Tnfrsf1b', 'Lamtor2', 'Brap', 'Bcl2l2', 'Braf', 'Casp2', 'Mapk8ip3', 'Lrdd', 'Bcl2a1a' }, ...
% 	{ 'MILI_PSEUDOPODIA_CHEMOTAXIS_DN' }
% };

% pulled from Chenyang's GeneMania spreadsheet GENEMANIA_CANCER_MOUSE_PATHWAY_ANALYSIS_V5 > GENELIST_FINAL tab
genes_new = { ...
	{ 'REACTOME_SOS_MEDIATED_SIGNALLING', 'Igf1r', 'Rassf5', 'Gab1' }, ...
	{ 'BIOCARTA_CERAMIDE_PATHWAY', 'Cebpb' }, ...
	{ 'REACTOME_NOTCH_HLH_TRANSCRIPTION_PATHWAY', 'Notch1' }, ...
	{ 'MOOTHA_FFA_OXYDATION', 'Dbt', 'Slc25a20', 'Ivd', 'D2hgdh', 'Ech1', 'Ptgr2' }, ...
	{ 'REACTOME_PROCESSIVE_SYNTHESIS_ON_THE_LAGGING_STRAND', 'Blm', 'Timeless' }, ...
	{ 'LANDIS_BREAST_CANCER_PROGRESSION_UP', 'Epcam' }, ...
	{ 'GOTZMANN_EPITHELIAL_TO_MESENCHYMAL_TRANSITION_UP', 'Mad2l1', 'Hspg2', 'Eln', 'Lum', 'Col1a2', 'Fbn1', 'Postn', 'Nid1' }, ...
	{ 'INGA_TP53_TARGETS', 'Casp3', 'Ccnd2' }, ...
	{ 'NIKOLSKY_BREAST_CANCER_21Q22_AMPLICON' }, ...
	{ 'REACTOME_POL_SWITCHING', 'Chtf18', 'Metap2', 'Cnot8' }, ...
	{ 'CROMER_METASTASIS_DN', 'Itga6', 'Pkp3', 'Krt6a', 'Lama3', 'Ckm' }, ...
	{ 'SA_PROGRAMMED_CELL_DEATH', 'Bcl2l14', 'Bok', 'Card11' }, ...
	{ 'BOGNI_TREATMENT_RELATED_MYELOID_LEUKEMIA_DN', 'Nlk', 'Ptprm' }, ...
	{ 'KEGG_SNARE_INTERACTIONS_IN_VESICULAR_TRANSPORT', 'Stx4a', 'Stxbp6', 'Aimp1', 'Uaca', 'Vps53' }, ...
	{ 'FLECHNER_BIOPSY_KIDNEY_TRANSPLANT_OK_VS_DONOR_DN', 'Dcc' }, ...
	{ 'MOSERLE_IFNA_RESPONSE', 'Gbp6', 'Isg15', 'Mx2', 'Irf7', 'Trim25' }, ...
	{ 'HUANG_DASATINIB_RESISTANCE_UP', 'Tgfbr1', 'Ilk', 'Ly6a', 'Irgm1' }, ...
	{ 'KEGG_BASE_EXCISION_REPAIR', 'Dntt', 'Exo1', 'Chrac1', 'Lig4', 'Lrsam1', 'Ercc5' }, ...
	{ 'PID_CERAMIDE_PATHWAY', 'Traf1', 'Bcl2a1a', 'Braf', 'Ikbkg', 'Mcl1', 'Cflar', 'Lrdd', 'Tnfrsf1b' }, ...
	{ 'MILI_PSEUDOPODIA_CHEMOTAXIS_DN', 'COL4A2', 'MANF', 'LEPREL2', 'HSP90B1', 'NID1', 'NUCB1', 'TPP1', 'COL6A2' }
};

build_group_links = false;

if build_group_links

	if ~exist('groupMap','var')
		load('groups_data.mat');
		% load('groups_data.mat'); % Palmetto
	end

	k = keys(groupMap);
	k_sz = numel(k);

	output = fopen('Results 02 - NEWGENE_FINAL (20)/significance.txt','w');
	% output = fopen('significance.txt','w'); % Palmetto

	% for g=1:numel(genes_orig)
	for g=1:1
		grp_rel_map = containers.Map('KeyType','char','ValueType','int32');
		grp_name = genes_orig{g}(1);
		grp_name = grp_name{1};
		% fprintf('group name: %s\n', grp_name);
		extended = [genes_orig{g}(2:numel(genes_orig{g})), genes_new{g}(2:numel(genes_new{g}))];
		extended_sz = numel(extended);
		for h=1:k_sz
		% for h=1:200
			test_grp = groupMap(k{h});
			if strcmp(lower(grp_name), lower(k{h})) ~= 1
				% fprintf('test group name: %s\n', k{h});
				grp_sz = numel(test_grp);
				for i=1:grp_sz
					for j=1:extended_sz
						gene_from_grp = test_grp(i).label;
						idx1 = findstr(gene_from_grp, '(') + 1;
						idx2 = findstr(gene_from_grp, ')') - 1;
						gene_string = lower(gene_from_grp(idx1:idx2));
						if strcmp(gene_string, lower(extended{j})) == 1
							if isKey(grp_rel_map, k{h})
								grp_rel_map(k{h}) = grp_rel_map(k{h}) + 1;
							else
								grp_rel_map(k{h}) = 1;
							end
						end
					end
				end
			end
		end
		k2 = keys(grp_rel_map);
		k2_sz = numel(k2);
		for g=1:k2_sz
			fprintf(output, '%d\t%s\t%d\t%s\t%d\n', grp_rel_map(k2{g}), grp_name, extended_sz, k2{g}, grp_sz);
		end
	end

	fclose(output);

else

	% MI(A,E)/MI(E,B) ratios - output of ratios_histograms_lists.m
	ratios = dlmread('mi_ratios.txt');
	perc_arr = prctile(ratios, 1:100);

	readM_map();

	% query the database (if possible? plugin installed?)
	database_path = 'annotations.db';
	sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
	db_obj = DB(database_path, sqlite3_path);

	not_found_list = {};
	fid = fopen('extended_genes_significance.txt','w');
	fprintf(fid, 'Group Name\tNum Genes\tOriginal MI Ratio\tOriginal MI A-E\tOriginal MI E-B\tPercentile\tNum Genes\tExtended-only MI Ratio\tExtended-only MI A-E\tExtended-only MI E-B\tPercentile\tNum Genes\tCombined MI Ratio\tCombined MI A-E\tCombined MI E-B\tPercentile\n');

	for g=1:numel(genes_orig) % assuming _orig and _new groups are of same #
		A_combined = []; B_combined = []; E_combined = [];
		fprintf(fid, '%s\t', genes_orig{g}{1});
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
					genes_in_arr = genes_in_arr + 1;
					temp_A = [];
					temp_B = [];
					temp_E = [];
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
		% combined ratio
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

	if numel(not_found_list) > 0
		fprintf(fid, '\nGenes/probesets not found:\n');
		for i=1:numel(not_found_list)
			fprintf(fid, '%s\n', not_found_list{i});
		end
	end

	fprintf(fid, '\n');
	fclose(fid);

end





