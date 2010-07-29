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

# Test getting diffs of entire version tags
#
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
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

plan tests => 1;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $tag = WebGUI::VersionTag->getWorking( $session );

my $changes = $tag->getChangesAsHtml;
is( ref $changes, 'HASH' );
cmp_deeply(
    $changes,
    {
        $newestRevision->getId => {
            title       => '<del>Old</del><ins>Newest</ins> revision',
        },
        $newAsset->getId => {
            title       => '<ins>New Asset</ins>',
        },
    },
    'changes is hash of hashes of diffs from before the tag to the latest revision in the tag',
);

#vim:ft=perl
