#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;
use File::Slurp qw(slurp);
use Encode;
use Web::Query;
use Encode;
use Data::Recursive::Encode;

my $html = decode_utf8 scalar slurp('./data/favorite.html');

my $result;
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
# Data::Recursive::Encode->decode_utf8($result);

my $data = $result;

use XML::Feed;
my $feed = XML::Feed->new('Atom');
$feed->title('Cside のお気に入り');
for my $data (@$data) {
    my $entry = XML::Feed::Entry->new('Atom');
    $entry->title($data->{title});
    $entry->id($data->{id});

    # TODO modified スルー中

    $entry->link($data->{url});
    $feed->add_entry($entry);

}
say $feed->as_xml;
