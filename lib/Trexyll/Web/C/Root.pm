package Trexyll::Web::C::Root;
use strict;
use warnings;
use utf8;

sub hello {
    my ($class, $c) = @_;
    my ($req, $res) = ( $c->req );
    $res = $c->render_json( { hello => 'trexyll'} );
}

1;
