use strict;
use warnings;

my $limit = 1;
my %groups_genes = ();
my $chop = 2;

open(BROAD, "msigdb.v5.1.symbols.gmt");
while(<BROAD>) {
	if($limit > 0) {
		my $geneset = "";
		my @line_pieces = split(/\t/, $_);
		$geneset = $line_pieces[0];
		my @temp_array = splice(@line_pieces, $chop, ($#line_pieces - $chop + 1));
		$groups_genes{$geneset} = [ @temp_array ];
		$limit--;
	}
}
close BROAD;

open(ANNOT, "MOUSE_ANNOTATIONSt.txt");
while(my ($key, @value) = each(%groups_genes)) {
	# @value just seems to return first item in array so not of much use
	print $key."\n";
	for my $i (0 .. $#{$groups_genes{$key}}) {
		seek(ANNOT, 0, 0);
		my $gene_name = ${$groups_genes{$key}}[$i];
		while(<ANNOT>) {
			if($_ =~ /^ENSMUSG\d+\tENSMUST\d+\t(\d+)\t(.*?)\t$gene_name\t/i) {
				print $gene_name."\t".$1."\n";
			}
		}
	}
}
close ANNOT;