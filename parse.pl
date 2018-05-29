#!/usr/bin/perl

use strict;
use warnings;

my $filename = 'oui.txt';
open(my $fh, '<:encoding(UTF-8)', $filename)
    or die "Could not open '$filename'\n";

open(my $outfile, '>', 'output_oui.txt')
    or die "Could not open 'output_oui.txt'\n";

while(my $row = <$fh>) {
    chomp($row);
    if ($row =~ /\S/) {
        my @arr = split(' ', $row);
        if ( $arr[0] =~ /[0-9a-fA-F]{6}/ ) {
            print $outfile "$arr[0] $arr[3] $arr[4]\n";
        }
    }
}

close $fh;
close $outfile;
