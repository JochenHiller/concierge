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
  rm -rf ./signed
  rm -rf ./maven-central-upload
  # cleanup also local m2 repo for the generated artifacts
  rm -rf ~/.m2/repository/org/eclipse/concierge/*
  exit 0
fi

if [ "$1" == "sign" ] ; then
  # now sign jars. We do that just to check that IF and HOW it can be done
  # we actually do NOT publish the artifacts
  # the size of signed JAR file is about 6-30 kB bigger, due to key and signed classes

  # we assume all artifacts to be published are in ./publish
  if [ ! -d signed ] ; then mkdir -p signed ; fi

  # for all bundles
  for b in \
	org.eclipse.concierge \
	org.eclipse.concierge.extension.permission \
	org.eclipse.concierge.service.packageadmin \
	org.eclipse.concierge.service.permission \
	org.eclipse.concierge.service.startlevel \
	org.eclipse.concierge.service.xmlparser \
	org.eclipse.concierge.shell \
    ; do
    # we copy jar file as unsiged jar file to compare easily
    cp publish/$b/$RELEASE/$b-$RELEASE.jar signed/$b-$RELEASE-unsigned.jar 
    # JAR FILES: Submit unsigned-jar.jar and save signed output to signedfile.jar
    # this step will ONLY work when running on CI server
    curl -o signed/$b-$RELEASE-signed.jar \
         -F file=@publish/$b/$RELEASE/$b-$RELEASE.jar http://build.eclipse.org:31338/sign
  done

  exit 0
fi


if [ "$1" == "build" ] ; then

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
# set proxy only in CI server
GRADLE_PROXY_SETTINGS=""
if [ "$JENKINS_URL" == "https://ci.eclipse.org/concierge/" ] ; then
  GRADLE_PROXY_SETTINGS=""
  GRADLE_PROXY_SETTINGS="$GRADLE_PROXY_SETTINGS -Dhttp.proxyHost=proxy.eclipse.org"
  GRADLE_PROXY_SETTINGS="$GRADLE_PROXY_SETTINGS -Dhttp.proxyPort=9898"
  GRADLE_PROXY_SETTINGS="$GRADLE_PROXY_SETTINGS -Dhttp.nonProxyHosts=*.eclipse.org"
  GRADLE_PROXY_SETTINGS="$GRADLE_PROXY_SETTINGS -Dhttps.proxyHost=proxy.eclipse.org"
  GRADLE_PROXY_SETTINGS="$GRADLE_PROXY_SETTINGS -Dhttps.proxyPort=9898"
  GRADLE_PROXY_SETTINGS="$GRADLE_PROXY_SETTINGS -Dhttps.nonProxyHosts=*.eclipse.org"
fi

cd ../..
# rebuild, tests not needed as release yet done
./gradlew $GRADLE_PROXY_SETTINGS clean build -x test publishMavenJavaPublicationToMavenLocal
)
if [ ! -d publish ] ; then mkdir -p publish ; fi
cd publish
# copy all generated local artifacts, do not include tests project
cp -r ~/.m2/repository/org/eclipse/concierge/* .
rm -rf org.eclipse.concierge.tests.integration
cd ..
# do not publish the nodebug version
rm -rf dist/concierge-incubation-$RELEASE/framework/*nodebug*

echo "Setup ./publish folder to create all maven artifacts..."

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

# end of build command
exit 0
fi

echo "Usage: ./Concierge-Release.sh {clean | build | sign}"
exit 1
