#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;
use Time::Seconds qw(ONE_MINUTE);

while (1) {
    system(qw(script/make_file_cache.pl set Cside 5));
    sleep(ONE_MINUTE);
    system(qw(script/make_file_cache.pl set Cside 10));
    sleep(ONE_MINUTE);
    system(qw(script/make_file_cache.pl set Cside 15));
    sleep(ONE_MINUTE);
    system(qw(script/make_file_cache.pl set Cside 20));
    sleep(15 * ONE_MINUTE);
}
