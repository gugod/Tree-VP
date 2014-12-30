package Tree::VP;
use Moo;
use Tree::Binary;
use List::Priority;

has distance => (
    is => "ro",
    required => 1,
);

has values => (is => "rw");
has left  => ( is => "rw" );
has right => ( is => "rw" );

has mu => ( is => "rw" );
has distance_min => ( is => "rw" );
has distance_max => ( is => "rw" );

sub build {
    my ($self, $values) = @_;
    my $vp = shift @$values;
    my @v = ($vp);
    if (@$values) {
        my @dist = sort { $a->[1] <=> $b->[1] } map {[$_, $self->distance->($_, $vp)]} @$values;
        my $center = int( $#dist/2 );
        my $median = (@dist == 1)
        ? $dist[0][1] : (@dist % 2 == 1)
        ? $dist[$center][1] : ($dist[$center][1] + $dist[$center+1][1])/2;

        my (@left, @right, $min, $max);
        for (@dist) {
            if ($_->[1] == 0) {
                push @v, $_->[0];
            } elsif ($_->[1] < $median) {
                $min = $_->[1] if !defined($min);
                push @left, $_->[0];
            } else {
                push @right, $_->[0];
                $max = $_->[1];
            }
        }
        $self->mu($median);
        $self->distance_min( $min );
        $self->distance_max( $max || $min || 0 );
        $self->left(  Tree::VP->new( distance => $self->distance)->build( \@left )  ) if @left > 0;
        $self->right( Tree::VP->new( distance => $self->distance)->build( \@right ) ) if @right > 0;
    }
    $self->values(\@v);
    return $self;
}

sub search {
    my ($self, %args)= @_;
    my $result = { values => [] };

    $args{size} ||= 2;
    my $is_top_level = !defined($args{__pq});
    my $pq = $args{__pq} ||= List::Priority->new;
    my $v = $self->values->[0];
    my $d = $self->distance->($v, $args{query});

    $args{tau} = $self->distance_max unless defined $args{tau};
    if ($d < $args{tau}) {
        $pq->insert($d, $v);
        if ($pq->size() > $args{size}) {
            $pq->pop();
            $args{tau} = $pq->highest_priority;
        }
    }

    if (defined($self->mu)) {
        my $mu = $self->mu;
        if ($d < $args{tau}) {
            if ($self->left && $self->distance_min - $args{tau} < $d) {
                $self->left->search(%args);
                $args{tau} = $pq->highest_priority;
            }
            if ($self->right && $mu - $args{tau} < $d && $d < $self->distance_max + $args{tau}) {
                $self->right->search(%args);
            }
        } else {
            if ($self->right && $d < $self->distance_max + $args{tau}) {
                $self->right->search(%args);
                $args{tau} = $pq->highest_priority;
            }
            if ($self->left && $self->distance_min - $args{tau} < $d && $d < $mu + $args{tau}) {
                $self->left->search(%args);
            }
        }
    }

    if ($is_top_level) {
        while ( my $x = $pq->shift() ) {
            push @{$result->{values}}, $x;
        }
    }
    return $result;
}


1;

__END__

=head1 Tree::VP

=over 4

=item new( distance => sub { ... })

Construct the top-level tree object. The C<distance> function must take 2 arguments that are the 2 values from the
arrayref passed to C<build> method. It must return a number range from 0 to Inf, with "0" meaning that the 2 values are
the same, and larger number means that the given 2 values are further away in space.

=item build( ArrayRef[ Val ] )

Take a arrayref af values of whatever type that can be handled by the C<distance> function, and build the tree
structure.

=item search( query => Val, size => Int )

Take a "query", which is just a value of whatever type contained in the tree. And return HashRef that contains the
results of top-K nearest nodes according to the distance function. C<size> means the the upper-bound of result size.

=back
