use v5.18;

use Tree::VP;
use List::MoreUtils qw<uniq>;
use Text::Levenshtein::XS ();
use Text::Levenshtein::Damerau::XS ();
use File::Slurp 'read_file';

sub distance {
    return Text::Levenshtein::XS::distance(@_);
    # return Text::Levenshtein::Damerau::XS::xs_edistance(@_);
}

my $dict = shift(@ARGV) || "/usr/share/dict/words";
my @words = uniq(map { lc($_) } read_file($dict, { chomp => 1, binmode => ":utf8" }));

say "collect " . (0+@words) . " words";

my $comparison;
my $vptree = Tree::VP->new( distance => sub {
                                $comparison++;
                                return distance(@_);
                            });
$vptree->build(\@words);

$| = 1;
print "(init with $comparison comparisons) ready\nyou type: ";
$comparison = 0;
while (<>) {
    chomp;
    my $q = $_;
    my $r = $vptree->search(query => $q, size => 5);
    say "my guess ($comparison comparisons): " . join " ", map { $_ . " (" . distance($_, $q) . ")" } @{$r->{values}};
    $comparison = 0;

    print "you type: ";
}
