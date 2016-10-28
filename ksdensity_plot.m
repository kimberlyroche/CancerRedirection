% 'mi_ratios.txt' is the just the list of MI(A,E)/MI(E,B) ratios values, output of ratios_histograms_lists.m,
%	so we have the whole population/distribution from which to judge percentile
ratios = dlmread('mi_ratios.txt');

% lines = [mean(ratios), ratios(numel(ratios)-19:numel(ratios))'];
lines = [ratios(numel(ratios)-19:numel(ratios))'];
% adjusted MI ratio of worst and best affected groups after addition of extended gene lists
% changed = [3.550, 10.581];
changed = [5.536, 15.812];

max_y = 0.0175;
mean_ratios = mean(ratios);
x_bottom = mean_ratios - 20;
x_top = mean_ratios + 20;
x_bottom = -15;
x_top = 20;
resolution = 10;
marker_size = 16;

[f, xi] = ksdensity(ratios);
figure('Visible','on');
hold on;
plot(xi, f, 'Color', 'black', 'LineWidth', 2);
for i=1:numel(lines)
	% line([lines(i) lines(i)],[0 max_y],'Marker','.','LineStyle','-','Color','red')
	plot(lines(i), max_y,'Marker','.','Color','red','MarkerSize',marker_size);
end
for i=1:numel(changed)
	% line([changed(i) changed(i)],[0 max_y],'Marker','.','LineStyle','-','Color','blue')
	plot(changed(i), max_y,'Marker','.','Color','blue','MarkerSize',marker_size);
end
hold off;
axis([x_bottom x_top 0 1]);
% set(gca,'xtick',[]);
% set(gca,'xticklabel',[]);
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);

saveGCF('output/test.png');