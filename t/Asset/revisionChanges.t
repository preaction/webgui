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

# Test the getRevisionDiff( ) function and related functions
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
    menuTitle       => "Old",
    snippet         => "Old text is good to have even when we replace it with new text",
    usePacked       => 0,
    mimeType        => "text/plain",
    ownerUserId     => "3",
    groupIdView     => "7",
    groupIdEdit     => "3",
} );

my $newRevision     = $oldRevision->addRevision( {
    title           => "New revision",
    menuTitle       => "New",
    snippet         => "New text is good to have even when we replace it with old text",
    usePacked       => 1,
    mimeType        => "text/html",
    ownerUserId     => "1",
    groupIdView     => "7",
    groupIdEdit     => "2",
}, time + 10 );

#----------------------------------------------------------------------------
# Tests

plan tests => 7;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# test getRevisionChanges to get a functional diff
my $expectedChanges = {
        title       => "[Old]{New} revision",
        menuTitle   => "[Old]{New}",
        snippet     => "[Old]{New} text is good to have even when we replace it with [new]{old} text",
        usePacked   => "[Yes]{No}",     # getValueAsHtml here
        mimeType    => "[text/plain]{text/html}",
        ownerUserId => "[Admin]{Visitor}", # getValueAsHtml here
        groupIdEdit => "[Admins]{Registered Users}", # getValueAsHtml here
};

my $changes = $newRevision->getRevisionChanges( $oldRevision->get('revisionDate') );
is( ref $changes, 'HASH' );
cmp_deeply(
    $changes,
    $expectedChanges,
    "All changes are shown",
);

my $changes = $newRevision->getRevisionChanges();
is( ref $changes, 'HASH' );
cmp_deeply(
    $changes,
    $expectedChanges,
    "getRevisionChanges defaults to previous revision"
);

#----------------------------------------------------------------------------
# test getRevisionChangesAsHtml to get a pretty diff for users
# IMPLEMENTOR NOTE: 
# local %String::Diff::DEFAULT_MARKS = ( ... );
# $self->getRevisionDiff( @_[1..-1] );
# Thank me later
$expectedChanges = {
        title       => "<del>Old</del><ins>New</ins> revision",
        menuTitle   => "<del>Old</del><ins>New</ins>",
        snippet     => "<del>Old</del><ins>New</ins> text is good to have even when we replace it with <del>new</del><ins>old</ins> text",
        usePacked   => "<del>Yes</del><ins>No</ins>",
        mimeType    => "<del>text/plain</del><ins>text/html</ins>",
        ownerUserId => "<del>Admin</del><ins>Visitor</ins>",
        groupIdEdit => "<del>Admins</del><ins>Registered Users</ins>",
};

my $changes = $newRevision->getRevisionChangesAsHtml( $oldRevision->get('revisionDate') );
is( ref $changes, 'HASH' );
cmp_deeply( $changes, $expectedChanges, 'getRevisionChangesAsHtml uses HTML tags instead of []{}' );


#----------------------------------------------------------------------------
# test www_viewRevisionChanges

# Use the HTML expected changes
$session->request->setup_body({
    func                => 'viewRevisionChanges',
    revisionDate        => $newRevision->get('revisionDate'), # Tells WebGUI to load this revision
    oldRevisionDate     => $oldRevision->get('revisionDate'),
});
my $output  = $newRevision->www_viewRevisionChanges;
cmp_deeply(
    $output,
    all( map { regexp(qr{\Q$_}) } values %$expectedChanges ),
    "www_viewRevisionChanges contains all HTML changes"
);
#vim:ft=perl
