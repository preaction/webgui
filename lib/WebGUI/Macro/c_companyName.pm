package WebGUI::Macro::c_companyName;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;

#-------------------------------------------------------------------
sub process {
	my ($output);
	$output = $_[0];
        $output =~ s/\^c\;/$session{setting}{companyName}/g;
	return $output;
}

1;

