package TheHand::Logger;
use strict;
use warnings;
use feature qw(say);
use parent qw(Exporter);
our @EXPORT = qw(infof warnf errorf critf dumper);

use Term::ANSIColor qw(colored);
use Data::Dumper::OneLine;

sub infof  { _log('blue',   '[INFO]',     @_) }
sub warnf  { _log('yellow', '[WARN]',     @_) }
sub errorf { _log('red',    '[CRITICAL]', @_) }
{
    no warnings 'once';
    *critf = \&errorf;
}

sub dumper { Dumper($_[0]) }

sub _log {
    my ($color, $prefix, $template, @args) = @_;
    say STDERR colored(
        join(' ', $prefix, sprintf($template, @args)),
    $color);
}

1;
