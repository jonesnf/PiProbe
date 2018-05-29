#!/usr/bin/perl

use DBI;
use strict;
use warnings;

print "Clearing Database... \n";

# define DBI constants
my $driver = "mysql";
my $database = "Gearlab";
my $dsn = "DBI:$driver:database=$database"; 
my $user = "root";
my $pwd = "mikki";
# connect to DB
my $dbh = DBI->connect($dsn, $user, $pwd) or die my $DBI:errstr;
print "$dbh\n";


# Delete a device from devices table
sub del_dev {
  my $table = $ARGV[0];
  print "$table\n";
  my $sth;
  if ( $table eq "oui") {
    $sth = $dbh->prepare("DELETE FROM oui WHERE mac_addr != ''");
  } else {
    $sth = $dbh->prepare("DELETE FROM devices WHERE mac_addr != ''");
  }
  $sth->execute() or print "Could not delete entries\n";
  print "Number of rows deleted: " . $sth->rows . "\n";
}

del_dev();
