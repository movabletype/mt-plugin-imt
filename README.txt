# iMT, a plugin for Movable Type

* Author: Six Apart
* Copyright: 2010 Six Apart
* License: GPL
* Site: http://www.movabletype.org/


## Overview

This plugin provides a more natural user interface for Apple's iPhone and iPod
touch products.

Once installed, you can access your Movable Type installation from your iPhone
or iPod touch and it should display the new user interface automatically. No
other configuration is required.

This plugin recognizes several mobile devices/browsers, including:

* iPhone (all models)
* iPod touch (all models)
* Opera Mini
* Palm Pre
* Android phones
* Google Nexus One

The plugin does not enable a mobile interface for Apple iPad. If however, you
want to use the iMT interface for iPad, you will need to add this configuration
setting to mt-config.cgi:

    iMTForiPad 1


## Installation

1. Move the iMT plugin directory to the MT `plugins` directory.
2. Move the iMT mt-static directory to the `mt-static/plugins` directory.

Should look like this when installed:

    $MT_HOME/
        plugins/
            iMT/
                (plugin files here)
        mt-static/
            plugins/
                iMT/
                    (plugin static files here)


## Support

This plugin is not an official Six Apart release, and as such support from Six
Apart for this plugin is not available.
