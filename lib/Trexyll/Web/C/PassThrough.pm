package Trexyll::Web::C::PassThrough;
use strict;
use warnings;
use utf8;
use JSON;
use Trexyll::Util;

sub request {
    my ($class, $c) = @_;
    my ($req, $res) = ( $c->req );
    my $api = $c->{args}{api};
    my $q = de $req->parameters->mixed;
    my $meth = lc $req->method;

    my $trello = $c->trello;

    my $api_res = $trello->$meth( $api, $q )->response;
    if ( $api_res->code != 200 ) {
        return $c->render_error_json(
            'proxy error',
            500,
            {
                original_response => {
                    status_code => $api_res->code,
                    status_line => $api_res->status_line,
                    headers     => [ split /\n/, $api_res->headers->as_string() ],
                    content     => $api_res->content,
                },
            },
        );
    }

    my %data = (
        original_status_code => $api_res->code,
        original_headers     => [ split /\n/, $api_res->headers->as_string() ],
        data                 => decode_json( $api_res->content ),
    );

    $res = $c->render_json( \%data );
}

1;
