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

# connect to database
my $dbh = DBI->connect($dsn, $user, $pwd) or die my $DBI:errstr;
print "Database: $dbh\n";


