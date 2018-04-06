#!/usr/bin/perl

use DBI;
use strict;
use warnings;

print "Starting scan... \n";

# define DBI constants
my $driver = "mysql";
my $database = "Gearlab";
my $dsn = "DBI:$driver:database=$database"; 
my $user = "root";
my $pwd = "mikki";
# connect to DB
my $dbh = DBI->connect($dsn, $user, $pwd) or die my $DBI:errstr;
print "$dbh\n";

# add device to devices table;
sub update_dev {
  my $dev = $_[0];
  my $sth = $dbh->prepare("UPDATE devices  
	  		 SET familiar = familiar + 1
	                 WHERE mac_addr = ?");
  $sth->execute($dev) or print "Has already been put in\n";
  #print "Device familiarity Updated: " . $sth->rows . "\n";
}

# Update familiar column of devices
sub add_dev {
  my $dev = $_[0];
  my $sth = $dbh->prepare("INSERT INTO devices (mac_addr, familiar) 
	                 VALUES (?, 1)");
  $sth->execute($dev) or print "Has already been put in\n";
  #print "Number of rows added: " . $sth->rows . "\n";
}

# Delete a device from devices table
sub del_dev {
  my $dev = $_[0];
  my $sth = $dbh->prepare("DELETE FROM devices WHERE 
	                  mac_addr = ?");
  $sth->execute($dev) or print "Device not in table\n";
  #print "Number of rows deleted: " . $sth->rows . "\n";
}

# See if device is already in devices table
sub find_dev {
  my $dev = $_[0]; 
  my $mac = 0; my $time = 0;
  my $sth = $dbh->prepare("SELECT * FROM devices WHERE 
	                  mac_addr = ?");
  $sth->execute($dev) or return 0;
  if ( ($mac, $time) = $sth->fetchrow_array ) {
	  #print "Found Device: $mac  $time \n";
	  return 1;
  }
  return 0;
}

# define device constants
my @devices = `sudo tcpdump -i mon1 -e -s 256 type mgt subtype probe-req -c 10 2>&1`; 
my $num_dev = 0;
chomp @devices;


sub containsMAC {
  my @devinfo = @_;
  my $found = 0;
  #find MAC addr
  foreach my $info ( @devinfo ) {
    if ( $info =~ /([0-9A-Fa-f]{2}([:-]|$)){4}/ ) {
      $info =~ s/SA://; 
      if ( find_dev($info) ) {
	      update_dev($info);
      } else {
	      add_dev($info);
      }
      $num_dev++;
    }
  }
}      

foreach my $device ( @devices ) {
  my @arr1 = split(' ', $device); 
  # check if line contains timestamp, if so, it has MAC addr
  if ( $arr1[0] =~ /\b\d{1,3}:\d{1,3}:\d{1,3}.\d{1,6}\b/ ) { 
    containsMAC(@arr1);
  }
}

=begin comment
if ( find_dev("XX:XX:XX:XX:XX:XY") ) {
	#del_dev();
  update_dev("XX:XX:XX:XX:XX:XY");
} else {
  add_dev("XX:XX:XX:XX:XX:XY");
}
=cut 

print "Num of Devices Found: $num_dev\n";

print "Done Scanning.\n";

