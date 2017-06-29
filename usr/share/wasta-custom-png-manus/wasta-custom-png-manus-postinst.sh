#!/bin/bash

# ==============================================================================
# wasta-custom-png-manus-postinst.sh
#
#   This script is automatically run by the postinst configure step on
#       installation of wasta-custom-png-manus. It can be manually re-run, but
#       is only intended to be run at package installation.  
#
#   2014-04-25 rik: initial script
#   2015-06-14 whm: reset the menu hover-delay from 200 back to 0 for better
#       menu operation on slow Lenovo x1??e laptops. Reinstall gimp (that was
#       removed in wasta-base-setup, and install gnote.
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Check to ensure running as root
# ------------------------------------------------------------------------------
#   No fancy "double click" here because normal user should never need to run
if [ $(id -u) -ne 0 ]
then
	echo
	echo "You must run this script with sudo." >&2
	echo "Exiting...."
	sleep 5s
	exit 1
fi

# ------------------------------------------------------------------------------
# Initial Setup
# ------------------------------------------------------------------------------

echo
echo "*** Beginning wasta-custom-png-manus-postinst.sh"
echo

# ------------------------------------------------------------------------------
# Dconf / Gsettings Default Value adjustments
# ------------------------------------------------------------------------------
echo
echo "*** Updating dconf / gsettings default values"
echo

# Values in /usr/share/glib-2.0/schemas/z_20_wasta-custom-xyz.gschema.override
#   will override Mint defaults.  Below command compiles them to be the defaults
#   for the current machine.
#
# '|| true;' sends any "error" to null (for Cinnamon 1.8-, will get error that some
#   org.cinnamon.muffin key not found, but will not cause a problem, so
#   suppressing errors to not worry user.)

glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null || true;

# ------------------------------------------------------------------------------
# Configuring Wasta Menus Defaults
# ------------------------------------------------------------------------------
echo
echo "*** Configuring Wasta Menus Default App List"
echo

# When wasta-menus runs, it generates the default desktop files in
#   /usr/share/wasta-base-setup/wasta-menus/applications based on values from
#   /usr/share/wasta-menus/wasta-menus-default-apps.txt
# 
# wasta-base-setup has a wasta-linux default wasta-menus-default-apps.txt linked
#   to /usr/share/wasta-menus.  We will now overwrite this link so that we
#   point to this regional wasta-custom-xyz instead.
#
# wasta-base-setup is set so that if a symlink already exists, it will NOT
#   overwrite it.  So this way a "wasta-custom-xyz" regional package will be
#   able to override.  This isn't pretty, but works.
#
# IF a system has 2 different wasta-custom-xyz packages that BOTH attempt to
#   symlink the default wasta-menus-default-apps.txt list, then "the last one
#   installed will win".

mkdir -p /usr/share/wasta-menus/
ln -sf /usr/share/wasta-custom-png-manus/wasta-menus/wasta-menus-default-apps-png-manus.txt \
    /usr/share/wasta-menus/wasta-menus-default-apps.txt

# Reset the menu hover-delay from 200 back to 0 (works better on slow Lenovo x1??e machines)
echo
echo "*** Setting Main Menu Hover Delay (back to 0)"
echo

sed -i -e 's@\(\"default\" \:\) 200@\1 0@' \
    /usr/share/cinnamon/applets/menu@cinnamon.org/settings-schema.json

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------

echo
echo "*** Finished with wasta-custom-png-manus-postinst.sh"
echo

exit 0
