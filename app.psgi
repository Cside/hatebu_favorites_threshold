#!/usr/bin/env perl
use 5.10.0;
use strict;
use warnings;
use lib 'lib';
use Plack::Builder;
use TheHand::Controller;

builder {
    sub { TheHand::Controller->to_app($_[0]) },
};
