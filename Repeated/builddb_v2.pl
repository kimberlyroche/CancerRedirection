use strict;
use warnings;
use DBI;

my $create_db = 0;
my $create_groups_genes = 1;
my $create_genes_probesets = 0;

# I haven't done DBI in a while: http://perlmaven.com/simple-database-access-using-perl-dbi-and-sql
my $dbfile = "annotations.db";
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = "";
my $password = "";
my $dbh = DBI->connect($dsn, $user, $password, {
   PrintError       => 0,
   RaiseError       => 1,
   AutoCommit       => 1,
   FetchHashKeyName => 'NAME_lc',
}) or die "Well, fuck: ".$DBI::errstr;

if($create_db) {
	print "Creating database...\n";
	# make our tables
	# 	probeset_genes - probeset (VARCHAR), gene (VARCHAR) (COMPOSITE KEY)
	# 	genes_groups - gene (VARCHAR), group (VARCHAR) (COMPOSITE KEY)
	# these (apparently) have to be two separate do() calls
	my $sql = <<'END_SQL';
CREATE TABLE probeset_genes (
  probeset VARCHAR(50) COLLATE NOCASE,
  gene VARCHAR(50) COLLATE NOCASE,
  PRIMARY KEY (probeset, gene)
);
END_SQL
	$dbh->do($sql);
	$sql = <<'END_SQL';
CREATE TABLE genes_groups (
  gene VARCHAR(50) COLLATE NOCASE,
  bgroup VARCHAR(50) COLLATE NOCASE,
  PRIMARY KEY (gene, b
END_SQL
	$dbh->do($sql);
	print "Database create succeeded.\n";
}

my $counter = 1;
my $chop = 2;

if($create_groups_genes) {
	print "Adding gene-group mappings...\n";
	open(BROAD, "msigdb.v5.1.symbols.gmt");
	# my $limit = 5;
	while(<BROAD>) {
		# if($limit > 0) {
			print "\tAdding #".$counter."...\n";
			my $geneset = "";
			my @line_pieces = split(/\t/, $_);
			for my $i (0 .. $#line_pieces) {
				if($line_pieces[$i] =~ /^\s*(\S*)\s*?/) {
					$line_pieces[$i] = $1;
				}
			}
			$geneset = $line_pieces[0];
			my @temp_array = splice(@line_pieces, $chop, ($#line_pieces - $chop + 1));
			for my $i (0 .. $#temp_array) {
				$dbh->do('INSERT OR IGNORE INTO genes_groups(gene, bgroup) VALUES (?, ?)', undef, $temp_array[$i], $geneset);
			}
		# }
		$counter++;
		# $limit--;
	}
	close BROAD;
	print "Done adding gene-group mappings.\n";
}

if($create_genes_probesets) {
	print "Adding probeset-gene mappings...\n";
	$counter = 1;
	open(ANNOT, "MOUSE_ANNOTATIONSt.txt");
	while(<ANNOT>) {
		print "\tAdding #".$counter."...\n";
		# format as below:
		# ENSMUSG00000095180	ENSMUST00000184866	10608724		Rhox5	MGI:97538	reproductive homeobox 5
		# ENSMUSG00000095180	ENSMUST00000179626	10608724	GENCODE basic	Rhox5	MGI:97538	reproductive homeobox 5
		if($_ =~ /^ENSMUSG\d+\tENSMUST\d+\t(\d+)\t.*?\t(.+?)\t/) {
			$dbh->do('INSERT OR IGNORE INTO probeset_genes(probeset, gene) VALUES (?, ?)', undef, $1, $2);
		}
		$counter++;
	}
	close ANNOT;
	print "Done adding probeset-gene mappings.\n";
}

$dbh->disconnect;





