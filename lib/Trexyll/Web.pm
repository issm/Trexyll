package Trexyll::Web;
use strict;
use warnings;
use parent qw/Trexyll Plack::Component/;
use Plack::Request;
use JSON;
use Trexyll::Web::Dispatcher;
use Trexyll::Util;

sub req { $_[0]->{req} }

sub call {
    my ($class, $env) = @_;
    return $class->handle_request( $env );
}

sub handle_request {
    my ($class, $env) = @_;
    my $req = Plack::Request->new( $env );
    my $self = $class->new(
        req => $req,
    );
    my $res = Trexyll::Web::Dispatcher->dispatch( $self );
    return $res->finalize();
}

sub render_json {
    my ($self, $data, $code) = @_;
    my $json = encode_json( $data );
    my $res = $self->req->new_response( $code || 200 );
    $res->content_type( 'application/json' );
    $res->content( $json );
    return $res;
}

sub render_error_json {
    my ($self, $msg, $code, $data) = @_;
    #my $json = encode_json( Data::Recursive::Encode->encode_utf8( $data ) );
    my $res = $self->render_json(
        { message => $msg, %{ $data || {} } },
        $code || 500
    );
    return $res;
}

1;
