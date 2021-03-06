#!/usr/bin/perl

use DBI;
use strict;
use warnings;

my $ARGC = @ARGV;
if ( $ARGC != 3 ) {
  die "To execute script: sudo ./<script> <database> <user> <pwd>";
} 

print "Starting scan... \n";

# define DBI constants
my $driver = "mysql";
my $database = $ARGV[0];
my $dsn = "DBI:$driver:database=$database"; 
my $user = $ARGV[1];
my $pwd = $ARGV[2];

# connect to DB
my $dbh = DBI->connect($dsn, $user, $pwd) or die my $DBI:errstr;

# Update familiar column of devices
sub update_dev {
  my $dev = $_[0];
  my $sth = $dbh->prepare("UPDATE devices  
	  		 SET familiar = familiar + 1
	                 WHERE mac_addr = ?");
  $sth->execute($dev) or print "Has already been put in\n";
  #print "Device familiarity Updated: " . $sth->rows . "\n";
}

# find the manufacturer name of current device
sub find_manuf {
  my $mac = $_[0];
  $mac =~ tr/a-z:/A-Z/d;
  $mac = substr($mac, 0, 6);
  my $manuf;
  my $sth = $dbh->prepare("SELECT manufacturer FROM oui
	  		   WHERE mac_addr = ?");
  $sth->execute($mac) or print "Could not find device manufacturer\n";
  if ( $manuf = $sth->fetchrow_array ) {
    return $manuf;
  }  
  return "N/A";
}

# add device to devices table;
sub add_dev {
  my $dev = $_[0];
  my $manuf_name = find_manuf($dev);
  my $sth = $dbh->prepare("INSERT INTO devices (mac_addr, familiar, manufacturer) 
	                 VALUES (?, 1, ?)");
  $sth->execute($dev, $manuf_name) or print "Has already been put in\n";
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
	  #print "Found Device: $mac\n";
	  return 1;
  }
  return 0;
}


# checking for results from tcpdump to see which responses are from devices
# with valid MAC addresses 
my $num_dev = 0;
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

# EXECUTE COMMAND (tcpdump) 
my @devices = `sudo tcpdump -i mon1 -e -s 256 type mgt subtype probe-req -c 10 2>&1`; 
chomp @devices;

# parse through results
foreach my $device ( @devices ) {
  my @arr1 = split(' ', $device); 
  # check if line contains timestamp, if so, it has MAC addr
  if ( $arr1[0] =~ /\b\d{1,3}:\d{1,3}:\d{1,3}.\d{1,6}\b/ ) { 
    containsMAC(@arr1);
  }
}

print "Num of Devices Found: $num_dev\n";

print "Done Scanning.\n";

