#!/usr/bin/env perl
use strict;
use warnings;

use utf8;
use 5.010000;
use lib 'lib';
use autodie;
use Time::Seconds qw(ONE_DAY);
use Encode;

use TheHand::Model;
use TheHand::Cache::File;

my ($method, $username, $threshold) = @ARGV;
exit unless $method && $username && $threshold;

my $key   = "favorites_html:$username:$threshold";
my $cache = TheHand::Cache::File->get_instance;

if ($method eq 'set') {
    my $decoded_html = TheHand::Model::scrape($username, $threshold);
    $cache->set($key, encode_utf8($decoded_html), ONE_DAY) if $decoded_html;
} else {
    my $encoded_html = $cache->get("favorites_html:$username:$threshold");
    say $encoded_html;
}

