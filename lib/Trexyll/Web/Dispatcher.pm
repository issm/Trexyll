package Trexyll::Web::Dispatcher;
use strict;
use warnings;
use Router::Boom::Method;
use Module::Find qw/useall/;
use Try::Tiny;

my $controller_class_prefix = 'Trexyll::Web::C';

useall( $controller_class_prefix );

my $router = Router::Boom::Method->new();
{
    $router->add( [qw/GET/], '/hello' => 'Root#hello' );

    # /-/
    $router->add( [qw/GET POST PUT DELETE/], '/-/{api:.*}' => 'PassThrough#request' );

    # /v/
    $router->add( [qw/GET/], '/v/check' => 'Validator#check' );

    # /c/
    $router->add( [qw/GET POST PUT DELETE/], '/c/{custom_api:.*}' => 'Custom#request' );
}

sub dispatch {
    my ($class, $c) = @_;
    my ($req, $res) = ( $c->req );
    my ($dest, $cap, $is_405) = $router->match( $req->method, $req->env->{PATH_INFO} );
    if ( $dest ) {
        my ($controller, $action) = split /#/, $dest;
        my $C = "${controller_class_prefix}::${controller}";
        $c->{args} = $cap;
        try {
            $res = $C->$action( $c, $req );
        } catch {
            my $msg = shift;
            $res = $c->render_error_json( $msg, 500 );
        };
        return $res;
    }
    else {
        return $c->render_error_json( 'not found', 404 );
    }
}

1;
