package Trexyll::Util;
use strict;
use warnings;
use utf8;
use parent 'Exporter';
use Data::Dumper;
use Encode;
use Data::Recursive::Encode;

our @EXPORT = qw/D Dc en de/;

sub D  { Dumper @_ }
sub Dc { "[32m" . (D @_) . "[0m" }

sub en {
    my ($data, $charset_to) = @_;
    $data = ''  unless defined $data;
    $charset_to = 'utf-8'  unless defined $charset_to;
    my $ref = ref $data;
    # SCALAR
    if ($ref eq '') {
        return encode($charset_to, $data);
    }
    # ARRAY / HASH
    elsif ($ref =~ /^(ARRAY|HASH)$/) {
        return Data::Recursive::Encode->encode($charset_to, $data);
    }
    # Hash::MultiValue
    elsif ($ref eq 'Hash::MultiValue') {
        my $flatten = [$data->flatten];
        $flatten = Data::Recursive::Encode->encode($charset_to, $flatten);
        return Hash::MultiValue->new(@$flatten);
    }
}

sub de {
    my ($data, $charset_from) = @_;
    $data = ''  unless defined $data;
    $charset_from = 'utf-8'  unless defined $charset_from;
    my $ref = ref $data;
    # SCALAR
    if ($ref eq '') {
        try {
            return decode($charset_from, $data);
        }
        catch {
            return $data;
        };
    }
    # ARRAY / HASH
    elsif ($ref =~ /^(ARRAY|HASH)$/) {
        try {
            return Data::Recursive::Encode->decode($charset_from, $data);
        }
        catch {
            return $data;
        };
    }
    # Hash::MultiValue object
    elsif ($ref eq 'Hash::MultiValue') {
        try {
            my $flatten = [$data->flatten];
            $flatten = Data::Recursive::Encode->decode($charset_from, $flatten);
            return Hash::MultiValue->new(@$flatten);
        }
        catch {
            return $data;
        };
    }
}

1;
