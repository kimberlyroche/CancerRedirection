% generates 100-bin histograms for all 18 columns of the dataset (M)

input_filename = 'ABCDEF-rma-normalized.txt';
exp_len = 35556;
dimensions = [1 1 exp_len 18];
if ~exist('M','var')
	M = dlmread(input_filename, '\t', dimensions);
end
[rows,cols] = size(M);

m_min = min(min(M));
m_max = max(max(M));

buckets = linspace(m_min - 1, m_max + 1, 100);

figure('Visible', 'on');
color = [0.35 0.35 0.35];
blank_axes = true;

for i=1:18
	histogram(M(:,i), buckets, 'FaceColor', color, 'EdgeColor', color);
	if blank_axes
		axis off;
	end
	ylim([0 1600]);
	fig = gcf;
	fig.PaperUnits = 'inches';
	fig.PaperPosition = [0 0 10 10];
	fig.PaperPositionMode = 'manual';
	print(['output/histogram_col',num2str(i)],'-dpng','-r0');
end