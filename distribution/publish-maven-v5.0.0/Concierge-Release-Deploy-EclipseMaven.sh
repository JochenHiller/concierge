#!/bin/bash

# See:
# https://wiki.eclipse.org/Services/Nexus
# https://docs.gradle.org/current/userguide/maven_plugin.html#uploading_to_maven_repositories
# https://repo.eclipse.org/content/repositories/concierge-releases/
# https://repo.eclipse.org/content/repositories/concierge-snapshots/


echo "Concierge-Release-Deploy-EclipseMaven.sh"

(
set -x
cd ../..

# we simple call gradle publish
# when version is NOT snapshot it will do a publish into release repo
# use --info to get more details during development

./gradlew --info publish
)
