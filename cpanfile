requires 'Cache::FileCache';
requires 'Class::Accessor::Lite';
requires 'Constant::Exporter';
requires 'Data::Dumper::OneLine';
requires 'Data::Util';
requires 'Encode';
requires 'HTTP::Status';
requires 'LWP::UserAgent';
requires 'Plack::Builder';
requires 'Plack::Request';
requires 'Plack::Response';
requires 'Smart::Args';
requires 'Sub::Retry';
requires 'Term::ANSIColor';
requires 'Time::Seconds';
requires 'URI::Template::Restrict';
requires 'Web::Query';
requires 'XML::Feed';
requires 'XML::Feed::Entry';
requires 'autodie';
requires 'feature';
requires 'parent';
requires 'perl', '5.10';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};
