#!/bin/bash

CURRENTDIR=$(pwd)
BASEDIR=$(cd $(dirname .gitignore) ; pwd)
echo "This will install dependencies required by META-SHARE."

echo "Checking python version..."

EXPECTED_PYTHON_VERSION="Python 2.7"

# Check which python version to use
if [ -e "$BASEDIR/opt/bin/python" ] ; then
  PYTHON="$BASEDIR/opt/bin/python"
  echo "Using locally installed python version $PYTHON"
else
  PYTHON=python
fi

PYTHON_VERSION=$($PYTHON --version 2>&1)
PREFIX_MATCH=$(expr "$PYTHON_VERSION" : "\($EXPECTED_PYTHON_VERSION\)")

if [ "$PREFIX_MATCH" != "" ] ; then
  echo "$PYTHON_VERSION found, OK."
else
  if [ "$PYTHON" == "python" ] ; then
    echo "expected $EXPECTED_PYTHON_VERSION, but found $PYTHON_VERSION"
    echo "trying to install a local version in $BASEDIR/opt"
    cd "$BASEDIR/installable-packages"
    echo "Downloading python:"
    wget "https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz" || exit 1
    echo "Verifying python"
    md5sum -c "Python-2.7.8.sig" || exit 1
    tar xzf "Python-2.7.8.tgz" || exit 1
    cd "Python-2.7.8" || exit 1
    ./configure --prefix="$BASEDIR/opt" || exit 1
    make || exit 1
    make install || exit 1
  else
    echo "expected $EXPECTED_PYTHON_VERSION, but found $PYTHON_VERSION in local install"
    echo "something is messed up, aborting."
    exit 1
  fi  
fi

if [ "$PYTHON" != "python" ] ; then
  echo "Python was installed locally -- make sure to include $BASEDIR/opt/bin at the beginning of your PATH!"
fi

echo "Create the virtual environment for package installation:"
# Select current version of virtualenv:
VENV_VERSION="1.11.6"
VENV_DIR="${BASEDIR}/venv"
URL_BASE="http://pypi.python.org/packages/source/v/virtualenv"

echo "Download virtualenv..."
wget "$URL_BASE/virtualenv-${VENV_VERSION}.tar.gz"
tar xzf "virtualenv-${VENV_VERSION}.tar.gz"
echo "Create the virtual environment:"
"$PYTHON" "virtualenv-${VENV_VERSION}/virtualenv.py" "${VENV_DIR}"
# Don't need this anymore.
rm -rf "virtualenv-${VENV_VERSION}" "virtualenv-${VENV_VERSION}.tar.gz"

echo "Python virtual environment created"

echo "Install metashare python dependencies"
"${VENV_DIR}/bin/pip" install -r "${BASEDIR}/requirements.txt"

echo
echo
echo "Installation of META-SHARE dependencies complete."

