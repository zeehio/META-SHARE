#!/bin/bash
# This script runs the metashare testsuite. It is written
# IMPORTANT: This script creates a new firefox profile in which the popup
# blocker is disabled.
# This profile is not removed automatically (FIXME) because firefox does not
# offer a command line to remove profiles (as far as I know)
# This means that if you run this on your own computer you will need to
# remove the firefox profile "firefox_profile" by yourself.
# How to remove a Firefox profile?
# You only need to close firefox and open it. A dialog
# will appear for you to choose the profile you want, with an option
# to delete any profile you have. Please delete the "firefox_profile".
# Your settings are usually saved in the "default" profile, so do not remove
# that profile.

# Copy test configuration
mkdir -p "storage" || exit 1
echo $(pwd)
cp metashare/local_settings.test metashare/local_settings.py || exit 1
cp metashare/initial_data.test.json metashare/initial_data.json || exit 1

# Start Xvfb
export DISPLAY=":99.0"
Xvfb "$DISPLAY" -ac -screen 0 1024x768x16 &
sleep 10

# Prepare firefox profile
rm -rf "$PWD/firefox_profile"
firefox -CreateProfile "firefox_profile $PWD/firefox_profile" || exit 1
tar xzf firefox_profile_template.tgz || exit 1
cp -pr firefox_profile_template/* "$PWD/firefox_profile" || exit 1
rm -rf firefox_profile_template


# Initialize database
rm -f metashare/testing.db
source venv/bin/activate || exit 1
pip install coverage || exit 1
python metashare/manage.py syncdb --noinput || exit 1
rm metashare/initial_data.json || exit 1

# Run testsuite:
metashare/start-solr.sh || exit 1
sleep 10
(cd metashare && coverage run --source=metashare manage.py test $1) || exit 1
deactivate || exit 1
metashare/stop-solr.sh || exit 1

