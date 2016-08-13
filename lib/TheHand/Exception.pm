package TheHand::Exception;
use strict;
use warnings;
use utf8;
use Smart::Args;
use TheHand::Logger;
use Class::Accessor::Lite (
    rw => [qw( status_code message )],
);

sub throw {
    my ($class, $log_level, $status_code, $message) = @_;

    TheHand::Logger->can("${log_level}f")->($message);

    my $self = bless {
        status_code => $status_code,
        message     => $message,
    }, $class;

    die $self;
}

1;
