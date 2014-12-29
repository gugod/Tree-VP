#!/usr/bin/env perl
use strict;
use warnings;

use Text::Levenshtein 'distance';
use Data::Dumper;
use Data::Printer;
use Tree::VP;
$Data::Dumper::Sortkeys=1;

sub hamming_distance {
    my ($str1, $str2) = @_;
    my $d = 0;
    for (0..length($str1)-1) {
        if (substr($str1, $_, 1) ne substr($str2, $_, 1)) {
            $d += 1;
        }
    }
    return $d;
}

 my @str = (
     '0000',
     '0111',
     '1110',
     '0011',
     '0001',
     '1100',

     # 'culture',
     # 'democracy',
     # 'metaphor',
     # 'irony',
     # 'hypothesis',
     # 'science',
     # 'fastuous',
     # 'integrity',
     # 'synonym',
     # 'empathy'
 );

 my $t = Tree::VP->new(
     nodes => \@str,
     distance => \&hamming_distance,
);

print Dumper( $t );
