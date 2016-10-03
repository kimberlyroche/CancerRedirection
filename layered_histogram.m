function test(datasets, total_min, total_max, bins, filename_append)
	% datasets should be a cell array of cluster columns (cell array of matrices)
	% datasets = {	[A 35556 rows x 3 cols] [B 35556 rows x 3 cols]	}
	figure('Visible','off');
	clf;
	block_width = 10;
	edges = linspace(total_min, total_max, bins);
	resolution_inches = 10;

	if numel(datasets) > 1
		histograms = {};
		max_n = 0;
		for i=1:size(datasets,2)
			[n, edges] = histcounts(datasets{i}, edges);
			histograms{i} = n;
			max_local_n = max(n);
			if max_local_n > max_n
				max_n = max_local_n;
			end
		end

		threshold = 100;
		no_significant_diff = true;
		for i=1:bins-1
			local_min = max_n;
			local_max = 0;
			for j=1:size(histograms,2)
				this_hist = histograms{j};
				this_bin = this_hist(i);
				if this_bin < local_min
					local_min = this_bin;
				end
				if this_bin > local_max
					local_max = this_bin;
				end
			end
			diff = abs(local_max - local_min);
			if diff > threshold
				no_significant_diff = false;
				break;
			end
		end

		colors = { [1 0 0] [0 0 1] [0 1 0] };
		if ~no_significant_diff
			axis([0 bins*block_width 0 max_n]);
			hold on;
			grid on;
			for i=1:size(datasets,2)
				this_hist = histograms{i};
				for j=1:bins-1
					patch([block_width*(j-1) block_width*j block_width*j block_width*(j-1)], [0 0 this_hist(j) this_hist(j)], colors{i});
				end
			end
			hold off;
			alpha(0.5);
			set(gca, 'XTick', linspace(0, 1000, 11));
			xticklabels = {0};
			for xlab=1:10
				xticklabels = [xticklabels, sprintf('%5.3f', edges(xlab * 10))];
			end
			set(gca, 'XTickLabel', xticklabels);
			set(gca, 'FontSize', 12);

			fig = gcf;
			fig.PaperUnits = 'inches';
			fig.PaperPosition = [0 0 resolution_inches resolution_inches];
			fig.PaperPositionMode = 'manual';
			print('output/layeredhistogram','-dpng','-r600');
		end
	else
		[n, edges] = histcounts(datasets{1}, edges);
		max_n = max(n);
		axis([0 bins*block_width 0 max_n]);
		hold on;
		grid off;
		for j=1:bins-1
			patch([block_width*(j-1) block_width*j block_width*j block_width*(j-1)], [0 0 n(j) n(j)], [0.5 0.5 0.5]);
		end
		hold off;
		alpha(0.75);
		set(gca,'xtick',[]);
		set(gca,'xticklabel',[]);
		set(gca,'ytick',[]);
		set(gca,'yticklabel',[]);

		fig = gcf;
		fig.PaperUnits = 'inches';
		fig.PaperPosition = [0 0 resolution_inches resolution_inches];
		fig.PaperPositionMode = 'manual';
		print(['output/layeredhistogram_',filename_append],'-dpng','-r600');
	end
end