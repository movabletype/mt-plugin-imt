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
