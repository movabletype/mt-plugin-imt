///////////////////////////////////////////////////////////////////////////////
// Copyright © 2010 Six Apart Ltd.
// This program is free software: you can redistribute it and/or modify it
// under the terms of version 2 of the GNU General Public License as published
// by the Free Software Foundation, or (at your option) any later version.
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// version 2 for more details.  You should have received a copy of the GNU
// General Public License version 2 along with this program. If not, see
// <http://www.gnu.org/licenses/>.

// Global

function confirmLogout( msg )
{
    if( !confirm( msg ) )
        return false;
    return true;
}


// Home

function revealWeblogs( id )
{
    var new_post_links = TC.elementOrId( id );
    if( !new_post_links )
        return false;
    TC.removeClassName( new_post_links, 'hidden' )
    return false;
}

function concealWeblogs( id )
{
    var new_post_links = TC.elementOrId( id );
    if( !new_post_links )
        return false;
    TC.addClassName( new_post_links, 'hidden' )
    return false;
}


// Editor

function focusTitle()
{
    var title = TC.elementOrId( 'title' );
    if( !title )
        return false;
    title.focus();
    return true;
}

function setDirty() { dirty = true; }
function clearDirty() { dirty = false; }


// Comment

function publishComment()
{
    submitForm( 'hidden-form', { status: 2, from: 'edit_comment', to: 'list_comments' } );
    return false;
}

function unpublishComment()
{
    submitForm( 'hidden-form', { status: 1, from: 'edit_comment', to: 'list_comments' } );
    return false;
}

function deleteComment( status, msg )
{
    if( !confirm( msg ) )
        return false;
    submitForm( 'hidden-form', { status: status, from: 'edit_comment', to: 'list_comments' } );
    return false;
}


// TrackBack

function publishTrackback()
{
    submitForm( 'hidden-form', { status: 2 } );
    return false;
}

function unpublishTrackback()
{
    submitForm( 'hidden-form', { status: 1 } );
    return false;
}

function deleteTrackback( status, msg )
{
    if( !confirm( msg ) )
        return false;
    submitForm( 'hidden-form', { status: status } );
    return false;
}


// Utilities

function submitForm( f, params )
{
    var f = TC.elementOrId( f );
    if( !f )
        return false;
    if( params )
    {
        var inputs = f.getElementsByTagName( "input" );
        for( var i = 0; i < inputs.length; i++ )
        {
            var input = inputs[ i ];
            if( TC.defined( params[ input.name ] ) && params[ input.name ] != null )
                input.value = params[ input.name ];
        }
    }
    f.submit();
    return false;
}
