package TheHand::Constants;
use strict;
use warnings;
use utf8;
use Constant::Exporter;

use Constant::Exporter (
    EXPORT_OK => {
        ACCEPTABLE_URI_TEMPLATE      => '/users/{username}/favorites.rss?threshold={threshold}',
        HATENA_BOOKMARK_URI_TEMAPLTE => 'http://b.hatena.ne.jp/{username}/favorite?threshold={threshold}&fragment=main',
    },
);

1;
