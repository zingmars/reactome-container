#! /bin/bash

# simple script to build ALL of the images necessary to run Reactome in docker containers.

#TODO: get the Release version as well as Neo4j username/password from a file.
RELEASE_VERSION=R67
NEO4J_USER=neo4j
NEO4J_PASSWORD=n304j

# the MySQL database is the first piece that must be built - solr, neo4j, analysis-core,
# diagrams generator, fireworks generator depend on it.
cd ./mysql
docker build -t reactome/reactome-mysql:$RELEASE_VERSION -f mysql.dockerfile .

# Next, we need to create the graph database.
cd ../neo4j
docker build -t reactome/reactome-neo4j:$RELEASE_VERSION \
	--build-arg RELEASE_VERSION=$RELEASE_VERSION \
	--build-arg NEO4J_USER=$NEO4J_USER \
	--build-arg NEO4J_PASSWORD=$NEO4J_PASSWORD \
	-f neo4j_generated_from_mysql.dockerfile .

# Now, we can build everyting else!

cd ../analysis-core
docker build -t reactome/analysis-core \
	--build-arg RELEASE_VERSION=$RELEASE_VERSION \
	--build-arg NEO4J_USER=$NEO4J_USER \
	--build-arg NEO4J_PASSWORD=$NEO4J_PASSWORD \
	-f analysis-core.dockerfile .

cd ../diagram-generator
docker build -t reactome/diagram-generator \
	--build-arg RELEASE_VERSION=$RELEASE_VERSION \
	--build-arg NEO4J_USER=$NEO4J_USER \
	--build-arg NEO4J_PASSWORD=$NEO4J_PASSWORD \
	-f diagram-generator.dockerfile .

cd ../fireworks-generator
docker build -t reactome/fireworks-generator \
	--build-arg RELEASE_VERSION=$RELEASE_VERSION \
	--build-arg NEO4J_USER=$NEO4J_USER \
	--build-arg NEO4J_PASSWORD=$NEO4J_PASSWORD \
	-f diagram-generator.dockerfile .

# Build all of the Java web applications.
# Right now, we always build from master because no repos are have release tags.
# Hopefully that will change in the future...
# $ANALYSIS_SERVICE_VERSION=
cd ../tomcat
docker build -t reactome/analysisservice -f AnalysisService.dockerfile .
docker build -t reactome/contentservice -f ContentService.dockerfile .
docker build -t reactome/datacontent -f data-content.dockerfile .
docker build -t reactome/diagramjs -f DiagramJs.dockerfile .
docker build -t reactome/fireworksjs -f FireworksJs.dockerfile .
docker build -t reactome/pathwaybrowser -f PathwayBrowser.dockerfile .
docker build -t reactome/reactomerestfulapi -f ReactomeRESTfulAPI.dockerfile .

# Finally, we will build the solr index.
cd ../solr
docker build -t reactome/solr -f index-builder.dockerfile .

# Let's display what was built.
docker images | grep "reactome/"