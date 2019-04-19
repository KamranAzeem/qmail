#!/bin/bash

SCRIPT_PATH=$(dirname $0)
# AR_URL=https://github.com/roffe/autorespond-2.0.6.git
AR_URL=http://notes.sagredo.eu/files/qmail/tar/autorespond-2.0.5.tar.gz

# Note: Do not set AR_URL to any value if you want to use the autorespond software part of this repository.




echo
echo "------------------------------------------------------------------------------------"
echo



# If it is a github repo, then we do a git clone,
#   , else we use a local copy.

REGEX='^http.*.git$'
# Note: double brackets!
if [[ ${AR_URL} =~ $REGEX ]]; then
  echo "The URL for autorespond seems to be a git repo! Cloning git repo: ${AR_URL} ..."
  ( 
    cd /usr/local/src
    git clone ${AR_URL}
  ) 
  AR_DIRECTORY=$(basename ${AR_URL} .git)
fi


REGEX='^http.*.tar.gz$'
if [[ ${AR_URL} =~ $REGEX ]]; then
  echo "The URL for autorespond seems to be a regular URL! Downloading software from: ${AR_URL} .... "
  ( 
    cd /usr/local/src
    curl -sLO ${AR_URL}
    tar xzf $(basename ${AR_URL})
  ) 

  AR_DIRECTORY=$(basename ${AR_URL} .tar.gz)
fi

# If AR_URL is empty then we use the local copy of autorespond
if [ -z ${AR_URL+x} ]; then
  echo "AR_URL not defined. Using a local copy of autorespond-2.0.5 ..."
  cp -a ../software/autorespond-2.0.5.tar.gz /usr/local/src/
  (
  cd /usr/local/src
  tar xzf autorespond-2.0.5.tar.gz 
  )
  AR_DIRECTORY=autorespond-2.0.5

fi

echo

# compile and install
(
cd /usr/local/src/${AR_DIRECTORY}
make
make install
)

