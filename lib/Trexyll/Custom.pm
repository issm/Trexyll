package Trexyll::Custom;
use strict;
use warnings;

sub register {
    my ($class, %args) = @_;
    return $class->new( %args );
}

sub load_file {
    my ($class, $file) = @_;
    my $c = do $file;
    return $c;
}

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub path { $_[0]->{path} }

sub method { $_[0]->{method} }

1;
