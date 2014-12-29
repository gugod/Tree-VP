#!/usr/bin/env perl
use strict;
use warnings;

use Text::Levenshtein 'distance';
use Data::Dumper;

use Tree::VP;

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
     distance => \&distance,
);

print Dumper($t);
