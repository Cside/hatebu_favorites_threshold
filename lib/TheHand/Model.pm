package TheHand::Model;
use strict;
use warnings;
use utf8;
use feature qw(state);
use Sub::Retry;
use LWP::UserAgent;
use HTTP::Status qw(:constants);
use Class::Accessor::Lite (
    new => 1,
);
use URI::Template::Restrict;

use TheHand::Exception;
use TheHand::Logger;
use TheHand::Constants qw(HATENA_BOOKMARK_URI_TEMAPLTE);

sub to_rss {
    my ($self, %params) = @_;
    my ($username, $thredhold) = @params{qw(username threshold)};

    my $data = _scrape($username, $thredhold);

    return $data;
}

sub _scrape {
    my ($username, $threshold) = @_;

    state $client = LWP::UserAgent->new(
        timeout => 50,
        agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36',
    );

    state $uri_template = URI::Template::Restrict->new(HATENA_BOOKMARK_URI_TEMAPLTE);
    my $uri = $uri_template->process(
        username  => $username,
        threshold => $threshold,
    );

    my $res;
    retry 2, 1, sub {
        infof("GET $uri");
        $res = $client->get($uri);
    }, sub {
        my $needs_retry = !$res->is_success;
        if ($needs_retry) {
            critf('Failed to get %s. error: %s', $uri, $res->status_line);
        }
        return $needs_retry
    };

    unless ($res->is_success) {
        if ($res->code == HTTP_FORBIDDEN) {
            TheHand::Exception->throw(
                'warn',
                HTTP_FORBIDDEN,
                "This user's bookmarks is private."
            );
        }
        TheHand::Exception->throw(
            'crit',
            $res->code,
            $res->message,
        );
    }

    return $res->decoded_content;
}

1;
