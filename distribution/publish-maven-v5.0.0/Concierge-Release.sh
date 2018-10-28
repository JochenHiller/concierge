#!/bin/bash

RELEASE=5.0.0
RELEASE_TAG=v5.0.0
CONCIERGE_VERSION=concierge-incubation-$RELEASE
CONCIERGE_ARCHIVE=$CONCIERGE_VERSION.tar.gz

echo "Concierge-Release.sh"

if [ "$1" == "clean" ] ; then
  echo "Clean all generated resources ..."
  rm -f .DS_Store
  rm -f $CONCIERGE_ARCHIVE
  rm -rf ./dist
  rm -rf ./publish
  # cleanup also local m2 repo for the generated artifacts
  rm -rf ~/.m2/repository/org/eclipse/concierge/*
  exit 1
fi

# download dist 5.0.0 to use well known artifacts
(
DOWNLOAD_BASE_URL="http://eclipse.org/downloads/download.php?mirror_id=1&file=/concierge/download/releases"
if [ ! -f $CONCIERGE_ARCHIVE ] ; then
  echo "Downloading Released Version $CONCIERGE_ARCHIVE ..."
  curl -L -o $CONCIERGE_ARCHIVE "$DOWNLOAD_BASE_URL/$CONCIERGE_ARCHIVE" >/dev/null 2>&1 
fi
if [ ! -d dist ] ; then mkdir -p dist ; fi
cd dist
rm -rf $CONCIERGE_VERSION
tar xzf ../$CONCIERGE_ARCHIVE
cd ..
)

# build again the code from release tag
(
(
cd ../..
# rebuild, tests not needed as release yet done
./gradlew clean build -x test publishMavenJavaPublicationToMavenLocal
)
if [ ! -d publish ] ; then mkdir -p publish ; fi
cd publish
# copy all generated local artifacts, do not include tests project
cp -r ~/.m2/repository/org/eclipse/concierge/* .
rm -rf org.eclipse.concierge.tests.integration
cd ..
# do not publish the nodebug version
rm -rf dist/concierge-incubation-$RELEASE/framework/*nodebug*


# copy artifacts from release distribution to publish
# fix lastest update to the timestamp of distribution
# framework
for b in \
	org.eclipse.concierge \
; do
  mv dist/concierge-incubation-$RELEASE/framework/$b-*.jar publish/$b/$RELEASE/$b-$RELEASE.jar
  mv publish/$b/maven-metadata-local.xml publish/$b/maven-metadata-local.xml.ORI
  cat publish/$b/maven-metadata-local.xml.ORI | \
  	sed -e 's|<lastUpdated>.*</lastUpdated>|<lastUpdated>20151029184259</lastUpdated>|g' \
  	>publish/$b/maven-metadata-local.xml
  rm publish/$b/maven-metadata-local.xml.ORI
done
# bundles
for b in \
	org.eclipse.concierge.extension.permission \
	org.eclipse.concierge.service.packageadmin \
	org.eclipse.concierge.service.permission \
	org.eclipse.concierge.service.startlevel \
	org.eclipse.concierge.service.xmlparser \
	org.eclipse.concierge.shell \
; do
  mv dist/concierge-incubation-$RELEASE/bundles/$b-*.jar publish/$b/$RELEASE/$b-$RELEASE.jar
  mv publish/$b/maven-metadata-local.xml publish/$b/maven-metadata-local.xml.ORI
  cat publish/$b/maven-metadata-local.xml.ORI | \
  	sed -e 's|<lastUpdated>.*</lastUpdated>|<lastUpdated>20151029184259</lastUpdated>|g' \
  	>publish/$b/maven-metadata-local.xml
  rm publish/$b/maven-metadata-local.xml.ORI
done
# cleanup not needed data anymore
rm -rf ./dist
)

exit 0
