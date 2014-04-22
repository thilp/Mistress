package Mistress::Obj::Dist;
# ABSTRACT: Represents a CPAN distribution to be tested by Mistress.

use Moo;
use MooX::Types::MooseLike::Base qw( Str InstanceOf );
use Digest::MD5;
use Safe::Isa;
use Path::Class;
use Carp 'confess';
use Mistress::Util 'pcf_r';

use namespace::clean;

our $VERSION = '0.001'; # VERSION



# These regexes are used in different places: be cautious if you change them.
my ( $REGEX_DIST_SUFFIX, $REGEX_TARBALL );

BEGIN {
    $REGEX_DIST_SUFFIX = qr{
        - [0-9]+ (?: \. [0-9]+ )*   # version number
        (?: -TRIAL )?               # possible dev release
        \. tar \. (?: [gx]z | bz2 ) # file extension
        $                           # nothing after
    }x;
    $REGEX_TARBALL = qr{
        ^                           # nothing before (this is a basename)
        [A-Z] [A-Za-z0-9-]+         # dist name
        $REGEX_DIST_SUFFIX
    }x;
}

sub _file_is_dist_tarball {
    my $file = shift;
    $file->basename =~ $REGEX_TARBALL
}

sub BUILDARGS {
    my $class = shift;
    my $path  = pcf_r(shift);
    _file_is_dist_tarball($path)
      or confess "$path is not a valid dist tarball filename";
    return { tarball => $path };
}


has name => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => 1,
);

sub _build_name {
    my $self = shift;
    (my $name = $self->tarball->stringify ) =~ s{ $REGEX_DIST_SUFFIX }[]x;
    $name =~ s{ - }[::]xg;
    return $name;
}


has tarball => (
    is       => 'ro',
    isa      => InstanceOf['Path::Class::File'],
    required => 1,
);


has md5 => (
    is      => 'rwp',
    isa     => Str,
    lazy    => 1,
    builder => 1,
);

# Static MD5 engine, since each Dist use it (at most) only once.
my $MD5; BEGIN { $MD5 = Digest::MD5->new }

sub _build_md5 {
    my $self = shift;
    $MD5->addfile( $self->tarball->openr );
    my $hash = $MD5->hexdigest;
    $MD5->reset;
    return $hash;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Mistress::Obj::Dist - Represents a CPAN distribution to be tested by Mistress.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 ATTRIBUTES

=head2 name

Stores the distribution name, which is the same as the tarball's basename
without the version number and where C<::> replaces C<->.

=head2 tarball

The path to this distribution's tarball, as a read-only L<Path::Class::File>
object.

=head2 md5

The MD5 fingerprint of this distribution's tarball, as an hexadecimal string.
B<Read-only>: it is automatically computed with L<Digest::MD5> from the
C<tarball> attribute.

=head1 METHODS

=head2 new( $path )

Returns a new Mistress::Obj::Dist object. Croaks if any of the following
conditions is not met:

=over 4

=item *

C<$path> is a L<Path::Class::File> object B<or> a string that can be converted to a Path::Class::File object using C<Path::Class::file()>;

=item *

C<$path>'s basename is not matched by the Mistress regex C<< / ^ [A-Z] [A-Za-z0-9-]+ - [0-9]+ (?: \.[0-9]+ )* \.tar\.(?: [gx]z | bz2 ) $ /x >>;

=item *

C<$path> can be read.

=back

=head1 AUTHOR

Thibaut Le Page <thilp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Thibaut Le Page.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
