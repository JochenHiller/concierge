# Release Concierge and Publish to Eclipse Maven / Maven Central

## Shell scripts

* Concierge-Release.sh: build a maven repo based on existing R5.0.0
  * use prebuild artifacts from R5.0.0 distribution
  * generate Javadocs and Sources from v5.0.0 tag
  * setup maven repo with sources, javadocs and correct timestamp
* Concierge-Release-Deploy-MavenCentral.sh
  * TODO
* Concierge-Release-Deploy-EclipseMaven.sh
  * TODO


## Maven Central

An issues for a staged repository has been created (https://issues.sonatype.org/browse/OSSRH-43650) where we can publish artifacts to.



## References

Eclipse:

* https://gist.github.com/JochenHiller/d18b9a22fc658db0b9e7e4b33d08cd8a

Publish to Maven Central:

* https://maven.apache.org/repository/guide-central-repository-upload.html
* https://central.sonatype.org/pages/ossrh-guide.html
* https://central.sonatype.org/pages/gradle.html
* Minimum requirements: https://central.sonatype.org/pages/requirements.html


## TODO

* gen GPG Key (GitHub ?)
* sign 
* upload to maven, check if valid
* CI Build
  * check to call sign on Eclipse CI
  