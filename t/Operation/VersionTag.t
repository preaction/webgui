# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $import          = WebGUI::Asset->getImportNode( $session );

my $oldRevision     = $import->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    title           => "Old revision",
}, time );

WebGUI::VersionTag->getWorking( $session )->commit; # we need a committed revision to get a diff

my $newRevision     = $oldRevision->addRevision( {
    title           => "New revision",
}, time + 2 );

my $newestRevision  = $newRevision->addRevision( {
    title           => "Newest revision",
}, time + 3 );

my $newAsset        = $import->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    title           => 'New Asset',
} );


#----------------------------------------------------------------------------
# Tests

plan tests => 2;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
$session->request->setup_body( {
    tagId       => WebGUI::VersionTag->getWorking( $session )->getId,
} );
my $output = WebGUI::Operation::VersionTag::www_viewChangesInTag( $session );

my @assetIds    = ( $newestRevision->getId, $newAsset->getId );
cmp_deeply(
    $output,
    all( map { regex(qr{\Q$_}) } @assetIds ),
    "www_viewChangesInTag contains all asset IDs",
);

cmp_deeply(
    $output,
    all(
        regex( qr{<del>Old</del><ins>Newest</ins> revision} ),
        regex( qw{<ins>New Asset</ins>} ),
    ),
    'www_viewChangesInTag contains all changes',
);



#vim:ft=perl
