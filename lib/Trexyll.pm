package Trexyll;
use strict;
use warnings;
use File::Basename;
use File::Spec;
use File::Slurp;
use WWW::Trello::Lite;
use TOML;

sub new {
    my ($class, @args) = @_;
    bless +{ @args }, $class;
}

sub base_dir {
    File::Spec->rel2abs( File::Spec->catdir( (dirname(__FILE__), '..' ) ) );
}

sub config {
    my ($self) = @_;
    my $env = $ENV{TREXYLL_ENV} || $ENV{PLACK_ENV} || 'development';
    my $file = File::Spec->catfile( dirname( __FILE__ ), '..', 'config', "${env}.pl" );
    do $file  or die "no config file: ${file}";
}

sub trello {
    my ($self) = @_;
    my $conf = $self->config->{'trello.api'} || {};
    my $toml = File::Slurp::slurp( $conf->{authz_file} );
    my $trello = WWW::Trello::Lite->new( %{ from_toml( $toml ) } );
    return $trello;
}

1;
