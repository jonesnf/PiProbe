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
  my $sth = $dbh->prepare("DELETE FROM devices WHERE mac_addr != ''");
  $sth->execute() or print "Device not in table\n";
  #print "Number of rows deleted: " . $sth->rows . "\n";
}


=begin comment
if ( find_dev("XX:XX:XX:XX:XX:XY") ) {
	#del_dev();
  update_dev("XX:XX:XX:XX:XX:XY");
} else {
  add_dev("XX:XX:XX:XX:XX:XY");
}
=cut 
del_dev();
print "Database Cleared.\n";

