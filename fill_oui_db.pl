#!/usr/bin/perl

use strict;
use warnings;
use DBI;

# Database constants
my $driver = "mysql";
my $database = "Gearlab";
my $dsn = "DBI:$driver:database=$database";
my $user = "root";
my $pwd = "mikki";

print "Connecting to Database: '$database'...\n";
# connect to database
my $dbh = DBI->connect($dsn, $user, $pwd) or die my $DBI:errstr;
print "Database: $dbh\n";

# open oui file
my $ouifile = "oui.txt";
open (my $fh, '<', $ouifile)
	or die "Could not open '$ouifile'\n";

print "Opened input file: '$ouifile'\n";
print "Writing to database...\n";

# parse per line, and enter into database
while (my $row = <$fh>) {
	chomp($row);
	my @macinfo = split(' ', $row);	
	my $info_size = @macinfo;
	my $manuf = "N/A";
	if ( defined $macinfo[2] ) {
	    $manuf = $macinfo[1] . " " . $macinfo[2];
	} elsif ( defined $macinfo[1] ) {
	    $manuf = $macinfo[1];
	} else {
	    $manuf = "N/A";
	}
	my $sth = $dbh->prepare("INSERT INTO oui (mac_addr, manufacturer)
	       	VALUES (?, ?)"); 
	$sth->execute($macinfo[0], $manuf) or print "Could not enter into database\n";
}


