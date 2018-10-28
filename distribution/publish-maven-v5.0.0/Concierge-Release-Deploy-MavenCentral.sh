#!/bin/bash


# for more infos see these links

# https://central.sonatype.org/pages/manual-staging-bundle-creation-and-deployment.html
# https://central.sonatype.org/pages/working-with-pgp-signatures.html
# https://lists.gnupg.org/pipermail/gnupg-users/2004-May/022471.html
# https://unix.stackexchange.com/questions/339077/set-default-key-in-gpg-for-signing


# How to upload in staging repo
# Login into https://oss.sonatype.org/



RELEASE=5.0.0



echo "Concierge-Release-Deploy-MavenCentral.sh"

# at the moment for R5.0.0 we simply sign with SOME privat key for testing upload to Sonartype
# we generate a JAR file for manual upload to Sonartype to check consistency of artifacts

if [ ! -d maven-central-upload ] ; then mkdir -p maven-central-upload ; fi

(
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

exit 0
