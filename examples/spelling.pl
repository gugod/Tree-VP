use v5.18;

use Tree::VP;
use List::MoreUtils qw<uniq>;
use Text::Levenshtein::XS 'distance';
use File::Slurp 'read_file';

my @words = grep { /^\p{Letter}+$/ } read_file "/usr/share/dict/words", binmode => ":utf8", chomp => 1;
@words = map { lc($_); $_ } @words;
@words = uniq(@words);

say "collect " . (0+@words) . " words";

my $vptree = Tree::VP->new( distance => \&distance );
$vptree->build(\@words);

$| = 1;
print "ready\nyou type: ";
while (<>) {
    chomp;
    my $q = $_;
    my $r = $vptree->search(query => $q, size => 8);
    say "my guess: " . join " ", map { $_ . " (" . distance($_, $q) . ")" } @{$r->{values}};
    print "you type: ";
}
