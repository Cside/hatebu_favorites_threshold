package TheHand::Model;
use strict;
use warnings;
use utf8;
use feature qw(state);
use Encode;
use Sub::Retry;
use LWP::UserAgent;
use HTTP::Status qw(:constants);
use Class::Accessor::Lite (
    new => 1,
);
use URI::Template::Restrict;
use Web::Query;
use XML::Feed;
use XML::Feed::Entry;
use TheHand::Cache::File;

use TheHand::Exception;
use TheHand::Logger;
use TheHand::Constants qw(HATENA_BOOKMARK_URI_TEMAPLTE);

sub to_atom {
    my ($self, %params) = @_;
    my ($username, $threshold) = @params{qw(username threshold)};

    my $html = _get_from_cache($username, $threshold);
    TheHand::Exception->throw(
        'crit',
        HTTP_INTERNAL_SERVER_ERROR,
        "cache is not found. username: $username, threshold: $threshold",
    ) unless $html;

    my $data = _parse_html($html);

    return _to_atom($data, $username);
}

sub _get_from_cache {
    my ($username, $threshold) = @_;

    my $key   = "favorites_html:$username:$threshold";
    my $cache = TheHand::Cache::File->get_instance;

    my $encoded_html = $cache->get("favorites_html:$username:$threshold");
    return $encoded_html ? decode_utf8($encoded_html) : undef;
}

sub _parse_html {
    my ($html) = @_;

    my $result = [];
    Web::Query->new_from_html($html)->find('ul.main-entry-list > li')->each(sub {
        my $h3 = $_->find('h3.entry-title');
        my $entry_link = $h3->find('a.entry-link');
    
        push @$result, {
            id        => $_->attr('data-eid'),
            title     => $entry_link->text,
            url       => $entry_link->attr('href'),
            bookmarks => $h3->find('span.users span')->text,
            favorites => $_->find('ul.entry-comment > li')->size,
        };
    });

    return $result;
}

sub _to_atom {
    my ($data, $username) = @_;

    my $feed = XML::Feed->new('Atom');
    $feed->title("$username のお気に入り");

    for my $data (@$data) {
        my $entry = XML::Feed::Entry->new('Atom');
        $entry->title(sprintf '%s (%dusers, %dfavs)', @$data{qw(title bookmarks favorites)});
        $entry->id($data->{id});
    
        # XXX $entry->modified($modified) スルー中
    
        $entry->link($data->{url});
        $feed->add_entry($entry);
    }

    # return encode_utf8 $feed->as_xml;
    return $feed->as_xml;
}

sub scrape {
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
    retry 1, 1, sub {
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
            sprintf('Failed to GET %s. %s.', $uri, $res->message),
        );
    }

    return $res->decoded_content;
}

1;
