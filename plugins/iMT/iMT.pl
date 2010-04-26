# Copyright 2007 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id$

package MT::Plugin::iMT;

use MT 4;
use base qw( MT::Plugin );

my $enabled = 0;
my $orig_alt_tmpl_path;

our $VERSION = '1.11';
my $plugin = __PACKAGE__->new({
    name        => "iPhone / iPod touch UI Support",
    author_name => "<a href='http://www.iwalt.com/'>Walt Dickinson</a>, <a href='http://bradchoate.com/'>Brad Choate</a>",
    description => "Provides an iPhone and iPod touch-friendly UI for Movable Type. Once enabled, navigate to your MT installation from your iPhone (or iPod touch) to use this interface.",
    version     => $VERSION,
    registry => {
        applications => {
            cms => {
                methods => {
                    iphone_main => \&iphone_main,
                    edit_entry => \&iphone_edit_entry,
                    edit_comment => \&iphone_edit_comment,
                    delete_confirm => \&iphone_delete_confirm,
                    set_comment_status => \&iphone_set_comment_status,
                    view => \&iphone_view,
                    # save_entry => \&iphone_save_entry,
                },
            },
        },
        callbacks => {
            template_param => \&page_param,
            'template_param.list_comment' => \&iphone_list_comment_param,
        },
    },
});
MT->add_plugin($plugin);

sub init {
    $orig_alt_tmpl_path = MT->config('AltTemplatePath');
}

sub iphone_list_comment_param {
    return unless $enabled;
    my $cb = shift;
    my ($app, $param, $tmpl) = @_;

    if (my $pager_json = $param->{'pager_json'}) {
        # Fix parameters for pagination of comments (app listing method
        # no longer provides these, but populates a json value that is
        # handled by a javascript routine to display pagination in MT4).
        require JSON;
        my $pager = JSON::jsonToObj($pager_json);
        my $offset = $pager->{offset};
        my $limit = $pager->{limit};
        if ($offset) {
            $param->{prev_offset}     = 1;
            $param->{prev_offset_val} = $offset - $limit;
            $param->{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
        }
        my $next_offset = ( $offset || 0 ) + $limit;
        if ($next_offset < $pager->{listTotal}) {
            $param->{next_offset}     = 1;
            $param->{next_offset_val} = $next_offset;
        }
    }
}

sub init_request {
    my $plugin = shift;
    my ($app) = @_;

    $enabled = 0;

    # user agent test; if iPhone and CMS app, switch template directory
    if ($app->isa('MT::App::CMS')) {
        # A bit of User Agent sniffing to determine if MT should
        # be using our AppleWebKit mobile interface.
        # Using keyword detection guidance provided by Apple:
        #    http://trac.webkit.org/projects/webkit/wiki/DetectingWebKit
        # Adjusted 'Mobile/' to 'Mobile[ /]' to match for Nexus One which
        #   supplies no device identifier following the 'Mobile' keyword
        # Disabled iMT by default for iPad; can be overridden using
        #   'iMTForiPad' config setting.
        if (my $agent = $ENV{HTTP_USER_AGENT}) {
            my $is_iphone = ($agent =~ /AppleWebKit/ && ( $agent =~ m!Mobile[ /]! || $agent =~ /Pre/ )) || ($agent =~ m!Opera Mini/!);
            if ($is_iphone && (! $app->config('iMTForiPad'))) {
                if ($agent =~ /iPad/) {
                    $is_iphone = 0;
                }
            }
            if ($is_iphone) {
                $enabled = 1;

                # Redirect 'dashboard' or 'default' modes to iphone_main
                $app->mode('iphone_main')
                    if ($app->mode eq 'default') || ($app->mode eq 'dashboard');

                $app->config('AltTemplatePath', $plugin->path . "/tmpl");
                return;
            }
        }
    }
    $app->config('AltTemplatePath', $orig_alt_tmpl_path);
}

sub iphone_view {
    my $app = shift;
    if ($enabled && ($app->param('_type') eq 'entry')) {
        # We replace the 'view' mode since after saving an entry,
        # we get redirected back to a view mode.
        return iphone_edit_entry($app, @_);
    }
    else {
        return undef;
    }
}

sub iphone_main {
    my $app = shift;
    my $param = {};
    $param->{blog_id} = $app->param('blog_id');
    $app->build_blog_selector($param);
    use Data::Dumper;
    $app->trace(Dumper($param));

    my $mt4 = MT->version_number < 5;
    my ($loop_name, $name, $id);
    if ($mt4) {
        $loop_name = 'top_blog_loop';
        $name = 'top_blog_name';
        $id = 'top_blog_id';
    }
    else {
        $loop_name = 'fav_blog_loop';
        $name = 'fav_blog_name';
        $id = 'fav_blog_id';
    }
    my $blog_loop = $param->{$loop_name} || [];
    foreach (@$blog_loop) {
        $_->{blog_name} = $_->{$name};
        $_->{blog_id} = $_->{$id};
    }
    $param->{blogs} = $blog_loop;
    $param->{user_has_weblog} = 1 if @$blog_loop;
    $app->load_tmpl('main.tmpl', $param);
}

sub iphone_set_comment_status {
    my $app = shift;
    my $id = $app->param('id');
    my $blog_id = $app->param('blog_id');
    $app->param('_type', 'comment');
    $app->return_args('__mode=list_comments&id=' . $id . '&blog_id=' . $blog_id);
    my $status = $app->param('status');
    if ( $status eq 'delete' ) {
        return $app->delete();
    }
    elsif ( $status eq 'junk' ) {
        return $app->handle_junk();
    }
    elsif ( $status eq '2' ) {
        return $app->approve_item();
    }
    else {
        return $app->unapprove_item();
    }
}

sub iphone_delete_confirm {
    my $app = shift;

    my $blog_id = $app->param('blog_id');
    my $type = $app->param('_type') || 'entry';
    my $param = {
        blog_id => $blog_id,
        id => $app->param('id'),
        type => $type,
        return => 'edit_entry',
        id_loop => [ $app->param('id') ],
        script_parent_url => $app->uri,
    };
    return $app->build_page('delete_confirm.tmpl', $param);
}

sub iphone_edit_comment {
    my $app = shift;
    $app->param('_type', 'comment');
    return $app->edit_object();
}

# sub iphone_save_entry {
#     my $app = shift;
#     return $app->save_entry(@_) unless $enabled;
# 
#     if ($app->param('preview_entry')) {
#         return $app->preview_entry(@_);
#     }
#     return $app->save_entry(@_);
# }

sub iphone_edit_entry {
    my $app = shift;

    $app->param('_type', 'entry');
    my $tmpl = $app->edit_object();

    my $sel_cats = $tmpl->param('selected_category_loop') || [];
    my @cat_loop;
    my $curr_cats = '';
    my $curr_cat_ids = '';
    my %selected;
    foreach my $sel (@$sel_cats) {
        my $cat = MT::Category->load($sel) or next;
        $curr_cats .= ', ' if $curr_cats ne '';
        $curr_cat_ids .= ',' if $curr_cat_ids ne '';
        $curr_cats .= $cat->label;
        $curr_cat_ids .= $cat->id;
        $selected{$cat->id} = 1;
    }

    my $c_data = $app->_build_category_list(
        blog_id => $app->blog->id,
        type    => 'category',
    );
    for my $row (@$c_data) {
        my $spacer = $row->{category_label_spacer} || '';
        push @cat_loop, {
            category_id => $row->{category_id},
            category_label => $spacer . MT::Util::encode_html($row->{category_label}),
            category_is_selected => $selected{$row->{category_id}} ? 1 : 0,
        };
    }
    $tmpl->param('category_loop', \@cat_loop);
    $tmpl->param('current_categories', $curr_cats);
    $tmpl->param('current_category_ids', $curr_cat_ids);
    return $tmpl;
}

sub page_param {
    return unless $enabled;

    my $cb = shift;
    my ($app, $param, $tmpl) = @_;
    $param->{portal_label} = MT->translate("Movable Type");
    $param->{user_id} = $app->user && $app->user->id;
    $param->{script_base_url} = $param->{script_parent_url} = $app->uri;
    $param->{page_mode} = $app->mode;
    $param->{static_uri} = $app->static_path . $plugin->{envelope} . '/';
}

1;
