package TheHand::Util;
use strict;
use warnings;
use utf8;
use parent qw(Exporter);
use HTTP::Status qw(status_message);

our @EXPORT_OK = qw(create_plain_text_res);

sub create_plain_text_res {
    my ($status_code, $message) = @_;
    my $res = Plack::Response->new($status_code);

    my $body  = status_message($status_code);
       $body .= "\n$message" if $message;

    $res->content_type('text/plain');
    $res->body($body);
    return $res->finalize;;
}

1;

