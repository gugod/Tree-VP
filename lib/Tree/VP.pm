package Tree::VP;
use Moo;
use Tree::Binary;

has distance => (
    is => "ro",
    required => 1,
);

has nodes => (
    is => "ro",
    required => 1,
);

has value => ( is => "rw" );
has left  => ( is => "rw" );
has right => ( is => "rw" );

has dist_median => ( is => "rw" );
has dist_min => ( is => "rw" );
has dist_max => ( is => "rw" );

sub BUILD {
    my ($self) = @_;
    my $nodes = [@{ $self->nodes }];
    my $vp = shift @$nodes;
    $self->value($vp);
    if (@$nodes) {
        my @dist = sort { $a->[1] <=> $b->[1] } map {[$_, $self->distance->($_, $vp)]} @$nodes;
        my $median = $dist[@dist/2]->[1];

        $self->dist_min( $dist[0]->[1] );
        $self->dist_max( $dist[@dist-1]->[1] );
        $self->dist_median($median);

        my (@left, @right);
        for (@dist) {
            if ($_->[1] < $median) {
                push @left, $_->[0];
            } else {
                push @right, $_->[0];
            }
        }
        $self->left(  Tree::VP->new( distance => $self->distance, nodes => \@left )  ) if @left > 0;
        $self->right( Tree::VP->new( distance => $self->distance, nodes => \@right ) ) if @right > 0;
    }
    return $self;
}


1;

__END__

=head1 Tree::VP

=over 4

=item new( distance => sub { ... }, nodes => [...] )

=back

