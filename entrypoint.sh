#!/bin/bash

JAVA_VERSION=$1
BUILD_TOOL=$2
BUILD_TOOL_VERSION=$3
STYLE=$3
REPOSITORY_TYPE=$4
REPOSITORY_URL=$5
REPOSITORY_USERNAME=$6
REPOSITORY_PASSWORD=$7

# if java version is 8; then download java 8 otherwise get java 11
if [ "$JAVA_VERSION" = "8" ]; then
    sdk install java 8.0.362-zulu  
elif [ "$JAVA_VERSION" = "11" ]; then
    sdk install java 11.0.11.hs-adpt
else 
    sdk install java 17.0.6-tem
fi


# if BUILD_TOOL is gradle then download gradle otherwise download maven
if [ "$BUILD_TOOL" == "gradle" ]; then
    # if STYLE is not null; then set the command arguments otherwise get the other command arguments
    if [ "$STYLE" != "" ]; then
        GRADLE_ARGS="--no-daemon -Dskip.tests=true -DactiveStyle=${STYLE} -I init.gradle -Dorg.gradle.jvmargs=-Xmx2048M ${BUILD_ACTION}"
    else
        GRADLE_ARGS="--no-daemon -Dskip.tests=true -I init.gradle -Dorg.gradle.jvmargs=-Xmx2048M ${BUILD_ACTION}"
    fi
    # if REPOSITORY_TYPE is nexus; then download init script otherwise get the other init script
    if [ "$REPOSITORY_TYPE" == "nexus" ]; then
        curl -o init.gradle https://raw.githubusercontent.com/moderneinc/enterprise-jenkins-ingest/main/gradle/init-nexus.gradle
    else
        curl -o init.sh https://raw.githubusercontent.com/philips-software/docker-ci-scripts/master/init.sh
    fi

    # run ./gradle $GRADLE_ARGS moderneJar conditionally with artifactoryPublish if REPOSITORY_TYPE is artifactory
    if [ "$REPOSITORY_TYPE" = "artifactory" ]; then
        echo "./gradlew $GRADLE_ARGS moderneJar artifactoryPublish"
    else
        echo "./gradlew $GRADLE_ARGS moderneJar"
    fi    

# else if BUILD_TOOL starts with  "maven" or "mvnw"; then download maven
elif [[ "$BUILD_TOOL" =~ "maven" || "$BUILD_TOOL" == "mvnw" ]]; then

    # if BUILT_TOOL is maven or mvnw then download maven 3.8.6 for $JAVA_VERSION otherwise download maven 3.3.9 JDK 8
    if [ "$BUILD_TOOL" = "maven" ] || [ "$BUILD_TOOL" = "mvnw" ]; then
        sdk install maven 3.8.6
    else
        sdk install maven 3.3.9
    fi

    curl -o add-mvn-configuration.sh https://raw.githubusercontent.com/moderneinc/enterprise-jenkins-ingest/main/maven/add-mvn-configuration.sh
    chmod +x ./add-mvn-configuration.sh
    ./add-mvn-configuration.sh

    # if STYLE is not null; then set the command arguments otherwise get the other command arguments
    MVN_ARGS="-B -DpomCacheDirectory=. -Drat.skip=true -Dlicense.skip=true -Dlicense.skipCheckLicense=true -Drat.numUnapprovedLicenses=100 -Dgpg.skip -Darchetype.test.skip=true -Dmaven.findbugs.enable=false -Dspotbugs.skip=true -Dpmd.skip=true -Dcpd.skip=true -Dfindbugs.skip=true -DskipTests -DskipITs -Dcheckstyle.skip=true -Denforcer.skip=true -Dskip.npm -Dskip.yarn -Dskip.bower -Dskip.grunt -Dskip.gulp -Dskip.jspm -Dskip.karma -Dskip.webpack ${STYLE ? "-Drewrite.activeStyle=${STYLE}" : ""} -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn ${BUILD_ACTION} clean install io.moderne:moderne-maven-plugin:0.32.2:ast"


    # if BUILD_TOOL is mvwn; then run mvnw otherwise run mvn
    if [ "$BUILD_TOOL" = "mvnw" ]; then
        echo "./mvnw $MVN_ARGS"
    else
        echo "./mvn $MVN_ARGS"
    fi


fi
