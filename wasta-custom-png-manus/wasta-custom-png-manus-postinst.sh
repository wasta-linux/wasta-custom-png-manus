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
# LibreOffice Preferences Extension install (for all users)
# ------------------------------------------------------------------------------

# REMOVE "Wasta-English-Intl-Defaults" extension: remove / reinstall is only
#   way to update
EXT_FOUND=$(ls /var/spool/libreoffice/uno_packages/cache/uno_packages/*/wasta-english-intl-defaults.oxt* 2> /dev/null)

if [ "$EXT_FOUND" ];
then
    unopkg remove --shared wasta-english-intl-defaults.oxt
fi

# Install wasta-english-intl-defaults.oxt (Default LibreOffice Preferences)
echo
echo "*** Installing/Updating Wasta English Intl Default LO Extension"
echo
unopkg add --shared /usr/share/wasta-custom-png-manus/resources/wasta-english-intl-defaults.oxt


# IF user has not initialized LibreOffice, then when adding the above shared
#   extension, the user's LO settings are created, but owned by root so
#   they can't change them: solution is to just remove them (will get recreated
#   when user starts LO the first time).

for LO_FOLDER in /home/*/.config/libreoffice;
do
    LO_OWNER=$(stat -c '%U' $LO_FOLDER)

    if [ "$LO_OWNER" == "root" ];
    then
        echo
        echo "*** LibreOffice settings owned by root: resetting"
        echo "*** Folder: $LO_FOLDER"
        echo
    
        rm -rf $LO_FOLDER
    fi
done

# ------------------------------------------------------------------------------
# Set system-wide Paper Size
# ------------------------------------------------------------------------------
# Note: This sets /etc/papersize.  However, many apps do not look at this
#   location, but instead maintain their own settings for paper size :-(
paperconfig -p a4
# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------

echo
echo "*** Finished with wasta-custom-png-manus-postinst.sh"
echo

exit 0
