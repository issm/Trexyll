package Trexyll::Web;
use strict;
use warnings;
use parent qw/Trexyll Plack::Component/;
use Plack::Request;
use JSON;
use File::Basename;
use File::Find ();
use Router::Boom::Method;
use Trexyll::Web::Dispatcher;
use Trexyll::Util;
use Trexyll::Custom;
use Time::HiRes ();

my $custom_router = Router::Boom::Method->new();
{
    File::Find::find(
        sub {
            my $f = $File::Find::name;
            return unless ( -f $f  &&  basename( $f ) =~ /\.pl$/ );
            my $c = Trexyll::Custom->load_file( $File::Find::name );
            if ( ref $c eq 'Trexyll::Custom' ) {
                my $path = $c->path;
                $path = [$path]  if ref( $path ) eq '';
                for my $p ( @$path ) {
                    $custom_router->add( $c->method, $p => $c );
                }
            }
        },
        (
            __PACKAGE__->base_dir() . '/custom',
            @{ __PACKAGE__->config->{'custom.path'} || [] },
        ),
    );
}

sub req { $_[0]->{req} }

sub call {
    my ($class, $env) = @_;
    return $class->handle_request( $env );
}

sub handle_request {
    my ($class, $env) = @_;
    my $t0 = Time::HiRes::time;
    my $req = Plack::Request->new( $env );
    my $self = $class->new(
        req           => $req,
        custom_router => $custom_router,
    );
    my $res = Trexyll::Web::Dispatcher->dispatch( $self );
    $res->header( 'X-Response-Time' => int( (Time::HiRes::time - $t0) * 1000 ) );
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

sub render_original_api_error_json {
    my ($self, $api_res, $code) = @_;
    return $self->render_error_json(
        'proxy error',
        $code || 500,
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

1;
