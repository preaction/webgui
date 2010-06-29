package WebGUI::Auth::TypeKey;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Auth';
use Authen::TypeKey;

=head1 NAME

WebGUI::Auth::TypeKey -- TypeKey auth for WebGUI

=head1 DESCRIPTION

Allow WebGUI to authenticate to TypeKey

=head1 METHODS

These methods are available from this class:

=cut

#----------------------------------------------------------------------------

=head2 new ( ... )

Create a new object

=cut

sub new {
    my $self    = shift->SUPER::new(@_);
    return bless $self, __PACKAGE__; # Auth requires rebless
}


1;
