use strict;
use warnings;
use DBI;

print "Creating database...\n";
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
  PRIMARY KEY (gene, bgroup)
);
END_SQL
$dbh->do($sql);

print "Database create succeeded.\nReading probeset-gene pairs...\n";
# build up the probeset-gene table
my $file = "MOUSE_ANNOTATIONSt.txt";
my @probesetIDs = ();
my @genenames = ();
open(DATA, $file);
while(<DATA>) {
	if($_ =~ /^.*?\t.*?\t(.*?)\t.*?\t(.*?)\t.*?\t.*$/) {
		my $m1 = $1;
		my $m2 = $2;
		if($m1 !~ /^\s*$/ && $m2 !~ /^\s*$/) {
			push(@probesetIDs, $1);
			push(@genenames, $2);
		}
	}
}
close DATA;
print "Adding probeset-gene pairs to database...\n";
for my $i (0 .. $#probesetIDs) {
	$dbh->do('INSERT OR IGNORE INTO probeset_genes(probeset, gene) VALUES (?, ?)', undef, $probesetIDs[$i], $genenames[$i]);
}
$sql = "DELETE FROM probeset_genes WHERE probeset='Affy MoGene 1_0 probeset' AND gene='MGI symbol'";
$dbh->do($sql);

print "Probeset-gene pairs successfully added.\nReading gene-Broad groupings...\n";
# build up the probeset-gene table
$file = "msigdb.v5.1.symbols.gmt";
@genenames = ();
my @groupnames = ();
open(DATA, $file);
while(<DATA>) {
	if($_ =~ /^(.*?)\t.*?\t(.*)$/) {
		my $group = $1;
		my $m2 = $2;
		my @genes = split('\t', $m2);
		for my $i (0 .. $#genes) {
			push(@groupnames, $group);
			push(@genenames, $genes[$i]);
		}
	}
}
close DATA;
print "Adding gene-Broad groupings to database...\n";
for my $i (0 .. $#genenames) {
	$dbh->do('INSERT OR IGNORE INTO genes_groups(gene, bgroup) VALUES (?, ?)', undef, $genenames[$i], $groupnames[$i]);
}
print "Gene-Broad groupings successfully added.\n";

$dbh->disconnect;

