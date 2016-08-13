package TheHand::Constants::Error;
use strict;
use warnings;
use utf8;
use Constant::Exporter;

use Constant::Exporter (
    EXPORT => {
        ERROR_BOOKMARKS_IS_PRIVATE     => "This user's bookmarks is private.",
        ERROR_BOOKMARKS_IS_UNAVAILABLE => "Internal server error on b.hatena.ne.jp.",
    },
);

1;

