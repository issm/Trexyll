package Trexyll::Web::C::Custom;
use strict;
use warnings;
use utf8;
use JSON;
use Trexyll::Util;

sub request {
    my ($class, $c) = @_;
    my ($req, $res) = ( $c->req );
    my $custom_api = $c->{args}{custom_api};
    my $trello = $c->trello;

    (my $custom_path = $req->env->{PATH_INFO}) =~ s!^/c/!/!;
    my ($custom, $cap, $is_405) = $c->{custom_router}->match( $req->method, $custom_path );

    unless ( $custom ) {
        return $c->render_error_json( 'not found', 404 );
    }

    my ($api_qb, $api_target) = ( $custom->{query}, $custom->{target} );
    my $api_meth = lc( $req->method );
    my $api_q = ( defined $api_qb && ref( $api_qb ) eq 'CODE' )
        ? $api_qb->( $custom, $req, $cap )
        : $req->parameters->mixed;
    if ( defined $api_target && ref( $api_target ) eq 'CODE' ){
        $api_target = $api_target->( $custom, $api_q, $cap );
    }
    my $api_res = $trello->$api_meth( $api_target, $api_q );

    if ( ref( $api_res ) eq 'Role::REST::Client::Response' ) {
        $api_res = $api_res->response;
    }

    if ( $api_res->code != 200 ) {
        return $c->render_original_api_error_json( $api_res, 500 );
    }

    my %data = (
        original_status_code => $api_res->code,
        original_headers     => [ split /\n/, $api_res->headers->as_string() ],
        data                 => decode_json( $api_res->content ),
    );

    $res = $c->render_json( \%data );
}

1;
