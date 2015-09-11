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
LATEST_PYTHON="2.7.10"
LATEST_PYTHON_MD5="d7547558fd673bd9d38e2108c6b42521"

if [ "$PREFIX_MATCH" != "" ] ; then
  echo "$PYTHON_VERSION found, OK."
else
  if [ "$PYTHON" == "python" ] ; then
    echo "expected $EXPECTED_PYTHON_VERSION, but found $PYTHON_VERSION"
    echo "trying to install a local version in $BASEDIR/opt"
    # sudo apt-get build-dep python
    wget "https://www.python.org/ftp/python/$LATEST_PYTHON/Python-$LATEST_PYTHON.tgz" || exit 1
    echo "Verifying python"
    echo "$LATEST_PYTHON_MD5  Python-$LATEST_PYTHON.tgz" | md5sum -c - || exit 1
    tar xzf "Python-$LATEST_PYTHON.tgz" || exit 1
    cd "Python-$LATEST_PYTHON" || exit 1
    ./configure --prefix="$BASEDIR/opt" || exit 1
    make || exit 1
    make install || exit 1
    cd ".."
    rm -rf "Python-$LATEST_PYTHON"
    PYTHON="$BASEDIR/opt/bin/python"
  else
    echo "expected $EXPECTED_PYTHON_VERSION, but found $PYTHON_VERSION in local install"
    echo "something is messed up, aborting."
    exit 1
  fi  
fi

echo "Create the virtual environment for package installation:"
# Select current version of virtualenv:
VENV_DIR="${BASEDIR}/venv"
VENV_VERSION="13.1.2"
VENV_MD5="b989598f068d64b32dead530eb25589a"
URL_BASE="https://pypi.python.org/packages/source/v/virtualenv"

echo "Download virtualenv..."
wget "$URL_BASE/virtualenv-${VENV_VERSION}.tar.gz" || exit 1
echo "Verify virtualenv..."
echo "${VENV_MD5}  virtualenv-${VENV_VERSION}.tar.gz" | md5sum -c - || exit 1
echo "Extracting virtualenv"
tar xzf "virtualenv-${VENV_VERSION}.tar.gz" || exit 1
echo "Create the virtual environment:"
"$PYTHON" "virtualenv-${VENV_VERSION}/virtualenv.py" "${VENV_DIR}"
# Don't need this anymore.
rm -rf "virtualenv-${VENV_VERSION}" "virtualenv-${VENV_VERSION}.tar.gz"

echo "Python virtual environment created"

#sudo apt-get install libsqlite3-dev
echo "Install metashare python dependencies"
"${VENV_DIR}/bin/pip" install -r "${BASEDIR}/requirements.txt" || exit 1

echo
echo
echo "Installation of META-SHARE dependencies complete."

