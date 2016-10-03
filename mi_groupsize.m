% renders the graphs of max entropy and average or sampled mutual information for a given group size

addpath(genpath('/Applications/MATLAB_R2015a.app/toolbox/MIToolbox'));

input_filename = 'ABCDEF-rma-normalized.txt';
exp_len = 35556;
dimensions = [1 1 exp_len 18];
if ~exist('M','var')
	M = dlmread(input_filename, '\t', dimensions);
end
[rows,cols] = size(M);

a1 = M(:,1);
a2 = M(:,2);
a3 = M(:,3);

b1 = M(:,4);
b2 = M(:,5);
b3 = M(:,6);

max_h = log2(rows);
mi1 = mi(a1, a2);
mi2 = mi(a1, b1);

fprintf('MI A1, A2: %6.5f (%4.3f)\n', mi1, (mi1/max_h));
fprintf('MI A1, B1: %6.5f (%4.3f)\n', mi2, (mi2/max_h));

marker_size =15;
line_width = 1;
red = [1 0 0];
blue = [0 0 1];
black = [0 0 0];
limit = 500;

figure('Visible','on');
axis square;
hold on;
line([0 limit], [mi1 mi1], 'Color', [230 200 200]/255, 'LineWidth', line_width);
line([0 limit], [mi2 mi2], 'Color', [200 200 230]/255, 'LineWidth', line_width);

render_average = true;
for n=1:limit
	fprintf('n=%d\n', n);
	num_samples = 100;
	average1 = 0;
	average2 = 0;
	for x=1:num_samples
		ix = randperm(rows);
		sample_set_a1 = a1(ix(1:n));
		sample_set_a2 = a2(ix(1:n));
		sample_set_b1 = b1(ix(1:n));
		mi1 = mi(sample_set_a1, sample_set_a2);
		mi2 = mi(sample_set_a1, sample_set_b1);
		average1 = average1 + mi1;
		average2 = average2 + mi2;
		if ~render_average
			plot(n, mi1, '.', 'Color', red, 'MarkerSize', marker_size);
			plot(n, mi2, '.', 'Color', blue, 'MarkerSize', marker_size);
		end
	end
	average1 = average1 / num_samples;
	average2 = average2 / num_samples;
	max_h = log2(n);
	if render_average
		plot(n, average1, '.', 'Color', red, 'MarkerSize', marker_size);
		plot(n, average2, '.', 'Color', blue, 'MarkerSize', marker_size);
	end
	plot(n, max_h, '.', 'Color', black, 'MarkerSize', marker_size);
end
hold off;

fig = gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 8 8];
fig.PaperPositionMode = 'manual';
if render_average
	print(['output/mi_groupsize_',num2str(limit),'_averaged'],'-dpng','-r0');
else
	print(['output/mi_groupsize_',num2str(limit)],'-dpng','-r0');
end
