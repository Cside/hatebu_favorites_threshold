package TheHand::Controller;
use strict;
use warnings;
use feature 'state';
use utf8;
use lib 'lib';
use Plack::Request;
use Plack::Response;
use HTTP::Status qw(:constants status_message);
use Data::Util qw(is_integer is_instance);
use URI::Template::Restrict;

use TheHand::Model;
use TheHand::Logger;
use TheHand::Util qw(create_plain_text_res);
use TheHand::Constants qw(ACCEPTABLE_URI_TEMPLATE);

sub to_app {
    my ($class, $env) = @_;

    my $req = Plack::Request->new($env);
    return [200, [], []] if $req->path_info eq '/favicon.ico';

    my $atom = eval {
        my ($username, $thredhold, $error_res) = _extract_req_params($req);;
        return $error_res if $error_res;

        TheHand::Model->new->to_atom(
            username  => $username,
            threshold => $thredhold,
        );
    };

    if (my $error = $@) {
        if (is_instance $error, 'TheHand::Exception') {
            return create_plain_text_res(
                $error->status_code,
                $error->message,
            );
        }
        return create_plain_text_res(HTTP_INTERNAL_SERVER_ERROR, $error);
    }

    my $res = Plack::Response->new(200);

    $res->content_type('application/atom+xml; charset=utf-8');
    $res->body($atom);

    return $res->finalize;
};

sub _extract_req_params {
    my ($req) = @_;
    my $path_info = $req->path_info;

    state $uri_template = URI::Template::Restrict->new(ACCEPTABLE_URI_TEMPLATE);
    my %params = $uri_template->extract($req->uri);

    my $username = $params{username};
    unless ($username) {
        TheHand::Exception->throw(
            'warn',
            HTTP_BAD_REQUEST,
            "Usage:\n\tGET " . ACCEPTABLE_URI_TEMPLATE,
        );
    }

    my $threshold = $params{threshold}
                     ? is_integer($params{threshold})
                         ? $params{threshold}
                         : 1
                     : 1;
    return (
        $username,
        $threshold,
        undef,
    );
}

1;

