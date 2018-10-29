# Release Eclipse Concierge and Publish to Eclipse Nexus / Maven Central

## Overview

The Eclipse Concierge Release 5.0.0 was published to Eclipse Nexus and Maven Central a while after publishing the release as .zip/tar.gz file.
This documentation describes how it does work. This is also preparation for R5.1.0 publishing to Eclipse Nexus and Maven Central as well.

In general we extended the Gradle build that way:
* Extend the Gradle build to include metadata for Maven Central (name, description, licenses, developers, scm)
  * See minimum requirements: https://central.sonatype.org/pages/requirements.html
* Generate as part of build also -sources.jar and -javadoc.jar
* Configure proxy settings while running the build (to download JavaDoc packages for JavaSE 5)
* Run a normal build on tag v5.0.0, without running test cases: `/gradlew clean build -x test publishToLocalMavenRepo`
* Prepare artifacts for manual upload to Maven Central, see folder `distribution/publish-maven-v5.0.0/publish`
* All has been done in the helper script `Concierge-Release.sh`
  * `Concierge-Release.sh clean` Clean all generated files, incl. local .m2 repo artifacts: 
  * `Concierge-Release.sh build` Build all artifacts using old distribution zip
  * `Concierge-Release.sh sign` Sign all artifacts using a local GPG key. Just to compare signed and unsigned JAR versions. Runs only on Eclipse CI server.  
  
In addition we checked how to sign JAR files, see `Concierge-Release.sh`. This does work well but increases JAR size about 8-30 kB, so we decided to provide non-signed JARs for smaller footprint on embedded devices.

## Publishing to Eclipse Nexus

We published the R5.0.0 on Eclipse Nexus that way:
* Extend the Gradle build files to add repos for "repo.eclipse.org"
  * see https://docs.gradle.org/current/userguide/maven_plugin.html#uploading_to_maven_repositories
* Let webmaster configure access to Eclipse Nexus
  * See https://wiki.eclipse.org/Services/Nexus#Deploying_to_repo.eclipse.org_with_Gradle
  * See https://bugs.eclipse.org/bugs/show_bug.cgi?id=540567
* Configure Gradle build to use authentication for Eclipse Nexus
* Publish to Maven: `./gradlew publishMavenJavaPublicationToMavenRepository`

See published release artifacts at: https://repo.eclipse.org/content/repositories/concierge-releases/


## Publishing to Maven Central

We published the R5.0.0 on Maven Central that way:
* Create an issue for Sonatype to create Maven central group id `org.eclipse.concierge`
  * See https://issues.sonatype.org/browse/OSSRH-43650
  * A staged repository has been created
* We asked webmaster to create a GPG key for publishing artifacts to Maven Central
  * See https://bugs.eclipse.org/bugs/show_bug.cgi?id=540505
* Verified if generated artifacts are valid on manual upload to staged repository
* See `Concierge-Release-Deploy-MavenCentral.sh` as temporary script to prepare artifacts


For more information on Maven Central see also:
* https://maven.apache.org/repository/guide-central-repository-upload.html
* https://central.sonatype.org/pages/ossrh-guide.html
* https://central.sonatype.org/pages/gradle.html
* https://central.sonatype.org/pages/manual-staging-bundle-creation-and-deployment.html
* https://central.sonatype.org/pages/working-with-pgp-signatures.html
* https://lists.gnupg.org/pipermail/gnupg-users/2004-May/022471.html
* https://unix.stackexchange.com/questions/339077/set-default-key-in-gpg-for-signing
* How to upload in staging repo: Login into https://oss.sonatype.org/


## Open Issues

* Use GPG key from Eclipse Foundation to sign and publish to Maven Central

```
mvn gpg:sign-and-deploy-file \
	-Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2/ \
	-DrepositoryId=ossrh \
	-DpomFile=ossrh-test-1.2.pom \
	-Dfile=ossrh-test-1.2.jar
mvn gpg:sign-and-deploy-file \
	-Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2/ \
	-DrepositoryId=ossrh ˜
	-DpomFile=ossrh-test-1.2.pom \
	-Dfile=ossrh-test-1.2-sources.jar \
	-Dclassifier=sources
mvn gpg:sign-and-deploy-file \
	-Durl=https://oss.sonatype.org/service/local/staging/deploy/maven2/ \
	-DrepositoryId=ossrh \
	-DpomFile=ossrh-test-1.2.pom \
	-Dfile=ossrh-test-1.2-javadoc.jar \
	-Dclassifier=javadoc
```

* Make PR to bring changes on build to Concierge master
* Publish R5.1.0 snapshots to repo.eclipse.org
