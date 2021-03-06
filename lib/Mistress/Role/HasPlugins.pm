package Mistress::Role::HasPlugins;
# ABSTRACT: Module::Pluggable in fewer keystrokes.

use Moo::Role;
use List::Util 'all';
use Module::Pluggable
  search_path => ['Mistress::Plugin'],
  sub_name    => '_list_plugins';

use namespace::clean;

# VERSION

=head1 SYNOPSIS

    # Here is a plugin (in Mistress::Plugin) that does Role::A:
    package Mistress::Plugin::DoSomeA;
    use Moo;
    with 'Mistress::Role::A';

    # Here is another plugin (still in Mistress::Plugin) that does Role::B:
    package Mistress::Plugin::DoSomeB;
    use Moo;
    with 'Mistress::Role::B';

    # Here is yet another plugin (still etc.) that does Role::A *and* Role::B:
    package Mistress::Plugin::DoBothAB;
    use Moo;
    with 'Mistress::Role::A', 'Mistress::Role::B';

    # Here is a class that uses plugins (all stored in Mistress::Plugin),
    # but *only* those which do *both* Role::A and Role::B:
    package Mistress::Whatever;
    use Moo;
    with 'Mistress::Role::HasPlugins'; # <-- that's me!

    # later in the same class ...
    my @plugins = $self->plugins(qw/ A B /); # 'Mistress::Plugin::DoBothAB'

=head1 DESCRIPTION

This role is a wrapper around L<Module::Pluggable> to simplify plugin
discrimination based on what role is implemented by each plugin.

It provides a C<plugins> method that works just like the Module::Pluggable's
one, but with an additional filtering step: it discards plugins that do not
implement Mistress roles specified as arguments (without their
C<Mistress::Role::> prefix). See the L<SYNOPSIS> for a detailed example.

=cut

sub plugins {
    my $self = shift;

    if (@_) {
        grep {
            my $p = $_;
            all { $p->does( 'Mistress::Role::' . $_ ) } @_
        } $self->_list_plugins;
    }
    else {
        $self->_list_plugins;
    }
}

1;
