#!/bin/bash

RELEASE=5.0.0

echo "Concierge-Release-Deploy-MavenCentral.sh"

# at the moment for R5.0.0 we simply sign with SOME private key for testing upload to Sonatype
# we generate a JAR file for manual upload of an artifact to Sonatype to check consistency

# will not work on CI as GPG keys are missing

(
  if [ ! -d maven-central-upload ] ; then mkdir -p maven-central-upload ; fi

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
    cd publish/$b/$RELEASE
    rm -f *.asc
    gpg -ab $b-$RELEASE.pom
    gpg -ab $b-$RELEASE.jar
    gpg -ab $b-$RELEASE-sources.jar
    gpg -ab $b-$RELEASE-javadoc.jar
    # verify    
    gpg --verify $b-$RELEASE.pom.asc $b-$RELEASE.pom
    gpg --verify $b-$RELEASE.jar.asc $b-$RELEASE.jar
    gpg --verify $b-$RELEASE-sources.jar.asc $b-$RELEASE-sources.jar
    gpg --verify $b-$RELEASE-javadoc.jar.asc $b-$RELEASE-javadoc.jar
    jar cvf ../../../maven-central-upload/$b-$RELEASE-upload.jar *.pom *.asc *.jar
    cd ../../..
  done
)
