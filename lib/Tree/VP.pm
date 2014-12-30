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

has mu => ( is => "rw" );
has distance_min => ( is => "rw" );
has distance_max => ( is => "rw" );

sub BUILD {
    my ($self) = @_;
    my $nodes = [@{ $self->nodes }];
    my $vp = shift @$nodes;
    $self->value($vp);
    if (@$nodes) {
        my @dist = sort { $a->[1] <=> $b->[1] } map {[$_, $self->distance->($_, $vp)]} @$nodes;
        my $center = int( $#dist/2 );
        my $median = (@dist % 2 == 1) ? $dist[$center]->[1] : ($dist[$center]->[1] + $dist[$center+1]->[1])/2;

        $self->distance_min( $dist[0]->[1] );
        $self->distance_max( $dist[@dist-1]->[1] );

        $self->mu($median);
        my @left = map { $_->[0] } splice(@dist, 0, $center+1);
        my @right = map { $_->[0] } @dist;

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

