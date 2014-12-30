package Tree::VP;
use Moo;
use Tree::Binary;

has distance => (
    is => "ro",
    required => 1,
);

has values => (
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
    my $values = [@{ $self->values }];
    my $vp = shift @$values;
    $self->value($vp);
    if (@$values) {
        my @dist = sort { $a->[1] <=> $b->[1] } map {[$_, $self->distance->($_, $vp)]} @$values;
        my $center = int( $#dist/2 );
        my $median = (@dist % 2 == 1) ? $dist[$center]->[1] : ($dist[$center]->[1] + $dist[$center+1]->[1])/2;

        $self->distance_min( $dist[0]->[1] );
        $self->distance_max( $dist[@dist-1]->[1] );

        $self->mu($median);
        my @left = map { $_->[0] } splice(@dist, 0, $center+1);
        my @right = map { $_->[0] } @dist;

        $self->left(  Tree::VP->new( distance => $self->distance, values => \@left )  ) if @left > 0;
        $self->right( Tree::VP->new( distance => $self->distance, values => \@right ) ) if @right > 0;
    }
    return $self;
}


1;

__END__

=head1 Tree::VP

=over 4

=item new( distance => sub { ... }, values => [...] )

Construct the tree structure from the list of values. The distance function takes 2 arguments that are the 2 values from
the "values" arrayref. It should return a number range from 0 to Inf, with "0" meaning that the 2 values are the same,
and larger number means that the given 2 values are further away in space.

=back

