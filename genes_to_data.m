genes_of_interest = {'Cdk1', 'Mapk1', 'Mapk3', 'Grb2', 'Hras', 'Raf1', 'Sos1', 'Map2k1', 'Nras', 'Irs2', 'Kras', 'Irs1', 'Ywhab', 'Map2k2'};

genes_of_interest = {'1110002E22Rik', '1700024B05Rik', '1700040F17Rik', '1700093K21Rik', '4930524N10Rik', '4933416C03Rik', '6030498E09Rik', '6720427I07Rik', '9430007A20Rik', '9530002B09Rik', 'A530084C06Rik', 'AI481877', 'Abracl', 'Actb', 'Actg1', 'Adam3', 'Adat2', 'Adgrf1', 'Aim1', 'Akr1cl', 'Amer3', 'Ankrd37', 'Anxa5', 'Aox2', 'Apoc1', 'Arrdc1', 'Ash2l', 'Atat1', 'Atp5e', 'Atxn2l', 'BC018473', 'BC147527', 'Bcar3', 'Btnl7-ps', 'Ccdc83', 'Cd300e', 'Cdc14b', 'Cdh10', 'Cdv3', 'Cma2', 'Cpsf2', 'Cyp24a1', 'Cyp2c40', 'Cyp2c69', 'Cyp3a59', 'Dcaf5', 'Ddx59', 'Defb42', 'Dgcr2', 'Dok6', 'Dusp7', 'Dydc1', 'Efcab3', 'Epb42', 'Ercc5', 'Esrp1', 'Fbxl22', 'Ftsj3', 'Gm10286', 'Gm10378', 'Gm10420', 'Gm10653', 'Gm11249', 'Gm11599', 'Gm11687', 'Gm11975', 'Gm12057', 'Gm12091', 'Gm12176', 'Gm12365', 'Gm12366', 'Gm12695', 'Gm12715', 'Gm12922', 'Gm12933', 'Gm13040', 'Gm13043', 'Gm13057', 'Gm13101', 'Gm13119', 'Gm13498', 'Gm14168', 'Gm14746', 'Gm17061', 'Gm18025', 'Gm20503', 'Gm21811', 'Gm22620', 'Gm22725', 'Gm22801', 'Gm23419', 'Gm25241', 'Gm25973', 'Gm26124', 'Gm26226', 'Gm26397', 'Gm26442', 'Gm26674', 'Gm28437', 'Gm28438', 'Gm3286', 'Gm37009', 'Gm37025', 'Gm37504', 'Gm4753', 'Gm5070', 'Gm5087', 'Gm5135', 'Gm5174', 'Gm5558', 'Gm5697', 'Gm5786', 'Gm5921', 'Gm6139', 'Gm6311', 'Gm6351', 'Gm6433', 'Gm6576', 'Gm7222', 'Gm7682', 'Gm7982', 'Gm7995', 'Gm8225', 'Gm8399', 'Gm8520', 'Gm9013', 'Gm9801', 'Gm9890', 'Gne', 'Gng10', 'Hdhd2', 'Helz', 'Hephl1', 'Hist1h4f', 'Ighv1-21', 'Ighv1-26', 'Ighv1-33', 'Ighv5-12-4', 'Incenp', 'Irf4', 'Kif15', 'Klra8', 'Klrb1a', 'Lelp1', 'Lilra6', 'Llgl1', 'Macrod2os2', 'Mafg', 'Mcpt9', 'Mdm1', 'Mgarp', 'Mir34c', 'Mir410', 'Mir664', 'Mir692-1', 'Mir6935', 'Mrgprc2-ps', 'Ms4a4b', 'Msn', 'Msx1', 'Ndufaf5', 'Neto1', 'Nps', 'Nthl1', 'Nup133', 'Obox3', 'Obox3-ps2', 'Obox3-ps3', 'Obox3-ps5', 'Obox3-ps6', 'Olfr1049', 'Olfr108', 'Olfr1087', 'Olfr1155', 'Olfr1233', 'Olfr1245', 'Olfr1268-ps1', 'Olfr1352', 'Olfr1382', 'Olfr1512', 'Olfr272', 'Olfr452', 'Olfr597', 'Olfr639', 'Olfr812', 'Olfr935', 'Olr1', 'P2ry12', 'Palmd', 'Pdgfd', 'Plppr5', 'Pramef25', 'Pramel6', 'Prmt5', 'Prr9', 'Prx', 'Ptpn22', 'Rcc2', 'Reps2', 'Rfx3', 'Rhox4a', 'Rhox4a2', 'Rhox4b', 'Rhox4c', 'Rhox4d', 'Rhox4e', 'Rhox4f', 'Rhox4g', 'Rpl21-ps5', 'Rpp25', 'Rpp25l', 'Rps14', 'Rps2', 'Rps2-ps10', 'Rps2-ps11', 'Rps2-ps13', 'Rps2-ps5', 'Rps2-ps6', 'Rwdd2a', 'Sbf1', 'Scd2', 'Sept9', 'Serinc2', 'Shox2', 'Slc22a22', 'Slc9a1', 'Smim9', 'Snora36b', 'Snora64', 'Snord100', 'Snord57', 'Sorbs2', 'Spag16', 'Sparc', 'Specc1', 'St3gal2', 'Tagln2', 'Tcp11x2', 'Tcrg-C1', 'Tcrg-C2', 'Tcrg-C3', 'Tdpoz1', 'Tekt5', 'Tex29', 'Tex36', 'Tktl2', 'Tmbim7', 'Tmed11', 'Tmem145', 'Tmem30c', 'Tmsb15a', 'Tmsb4x', 'Trav14n-3', 'Trhr', 'Trp53tg5', 'Txn-ps1', 'Tyw3', 'Ube2e1', 'Ubqlnl', 'Vmn1r115', 'Vmn1r229', 'Vmn1r32', 'Vmn2r121', 'Vmn2r22', 'Zfp101', 'Zfp354b', 'Zfp389', 'Zfp518a', 'mt-Co3', 'mt-Nd3', 'mt-Tg'};

fprintf('Reading mouse matrix into map...\n');
readM_map();

fprintf('Querying list of all Broad-associated genes...\n');
database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

fid = fopen('output/genes_to_data.txt', 'w');
fprintf(fid, 'gene\ta1\ta2\ta3\tb1\tb2\tb3\tc1\tc2\tc3\td1\td2\td3\te1\te2\te3\tf1\tf2\tf3\n');
for i=1:numel(genes_of_interest)
	res = gene2probeset(db_obj, genes_of_interest{i});
	fprintf('Querying "%s"...\n', genes_of_interest{i});
	fprintf(fid, '%s', genes_of_interest{i});
	for j=1:numel(res)
		if j > 1
			fprintf(fid, '%s', [genes_of_interest{i}, '_', num2str(j)]);
		end
		if isKey(mapObj, res(j).probeset)
			current_row = mapObj(res(j).probeset);
			for k=1:18
				fprintf(fid, '\t%.4f', current_row(k));
			end
		else
			for k=1:18
				fprintf(fid, '\t');
			end
		end
		fprintf(fid, '\n');
	end
end
fclose(fid);