package Trexyll;
use strict;
use warnings;
use File::Spec;

sub new {
    my ($class, @args) = @_;
    bless +{ @args }, $class;
}

sub config {
    my ($self) = @_;
    my $env = $ENV{TREXYLL_ENV} || $ENV{PLACK_ENV} || 'development';
    my $file = File::Spec->catfile( $self->base_dir(), 'config', "${env}.pl" );
    do $file  or die "no config file: ${file}";
}

1;
