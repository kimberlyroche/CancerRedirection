genelist_significant = {'Gab1', 'Epcam', 'Wfdc18', 'Sparc', 'Postn', 'Myadm', 'Tbl3', 'Tacstd2', 'Perp', 'Itga6', 'Stat3', 'SEC31A', 'ANXA5', 'Acadl', 'Acox1', 'Acta2', 'Ahctf1', 'Aim1', 'Angptl2', 'Antxr2', 'App', 'Asah1', 'Atp1a1', 'Atp5b', 'Atp5d', 'Atp6ap2', 'Atp6v1a', 'Atpif1', 'Axl', 'Bmp1', 'Cald1', 'Casp8', 'Cast', 'Ccng1', 'Cct6a', 'Cpsf7', 'Cpt1a', 'Crebbp', 'Ctgf', 'Ctnnb1', 'Ctsd', 'Cyp1b1', 'Dag1', 'Dap', 'Ddx17', 'Ddx58', 'Ecm1', 'Esyt1', 'Fads3', 'Fbln2', 'Fgfr1', 'Flnb', 'Fn1', 'Fxyd3', 'Ganab', 'Gnb1', 'Gng12', 'Gns', 'Grn', 'H3f3b', 'Hadha', 'Hmgb1', 'Hspa5', 'Hspa8', 'Ifi44', 'Igfbp7', 'Itgb1', 'Klf3', 'Lmf2', 'Lrp1', 'Lrrc8c', 'Ly6e', 'Malat1', 'Mfsd11', 'Mmp14', 'Mpzl1', 'Msn', 'Myo10', 'Nisch', 'Nono', 'Notch2', 'Nr2f1', 'Parva', 'Pdgfc', 'Pdgfrb', 'Plxnb2', 'Prep', 'Psap', 'Rela', 'Rpl41', 'Rtp4', 'S100a10', 'S100a11', 'Sdc4', 'Sec61a1', 'Serinc1', 'Sgpl1', 'Sigmar1', 'Slc29a1', 'Slc2a1', 'Slc38a2', 'Slc39a14', 'Slc44a2', 'Slco2a1', 'Sppl2a', 'Stt3a', 'Tcf25', 'Tgfb3', 'Thbs1', 'Timp2', 'Timp3', 'Tmed7', 'Trps1', 'Usp22', 'Vamp8', 'Vdac3', 'Vdr', 'Wls', 'Zmiz1', 'Zyx'};

fprintf('Reading matrix into map object...\n');
readM_map();

database_path = 'annotations.db';
sqlite3_path = '/Users/kimroche/Documents/MATLAB/sqlite3/';
db_obj = DB(database_path, sqlite3_path);

readDEG();

fid = fopen('output/data_coreheatmap.txt', 'w');
fprintf(fid, 'id\tA1\tA2\tA3\tE1\tE2\tE3\tB1\tB2\tB3\n');
for j=1:numel(genelist_significant)
	x = genelist_significant{j};
	res = gene2probeset(db_obj, x);
	for k=1:numel(res)
		p = res(k).probeset;
		if probesetDEGsignificant(p, false, DEG_map, 1)
			fprintf(fid, '%s_%s', x, p);
			current_row = mapObj(p);
			fprintf(fid, '\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n', ...
				current_row(1), ...
				current_row(2), ...
				current_row(3), ...
				current_row(13), ...
				current_row(14), ...
				current_row(15), ...
				current_row(4), ...
				current_row(5), ...
				current_row(6) ...
			);
		end
	end
end
fclose(fid);
heatmaps('output', 'coreheatmap', 0, 0, 0, 30);