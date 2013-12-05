package Trexyll::Web::C::Validator;
use strict;
use warnings;
use utf8;
use JSON;
use Trexyll::Util;

sub check {
    my ($class, $c) = @_;
    my ($req, $res) = ( $c->req );

    my $trello = $c->trello;
    my $api = sprintf 'tokens/%s', $trello->token;
    my $api_res = $trello->get( $api )->response;
    my $res_code;
    my %data = (
        result => undef,
        original_response => {
            status_code => $api_res->code,
            status_line => $api_res->status_line,
            headers     => [ split /\n/, $api_res->headers->as_string() ],
            content     => $api_res->content,
        },
    );
    if ( $api_res->code == 200 ) {
        $res_code = 200;
        $data{result} = 'ok';
    }
    else {
        $res_code = 511;
        $data{result} = 'fail';
    }

    return $c->render_json( \%data, $res_code );
}

1;
