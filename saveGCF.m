function saveGCF(filename) 
	fig = gcf;
	fig.PaperUnits = 'inches';
	fig.PaperPosition = [0 0 10 10];
	fig.PaperPositionMode = 'manual';
	print(filename,'-dpng','-r0');
end