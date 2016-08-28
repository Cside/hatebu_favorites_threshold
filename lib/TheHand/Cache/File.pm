package TheHand::Cache::File;
use strict;
use warnings;
use utf8;
use feature qw(state);

use Cache::FileCache;
use Time::Seconds qw(ONE_DAY);

sub get_instance {
    state $cache = Cache::FileCache->new({
        namespace          => 'hatebu_favorites_threshold',
        default_expires_in => ONE_DAY,
    });
}


1;

