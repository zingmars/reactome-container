#! /bin/bash
set -e
CuratorTool ()
{
  # Build Curator Tool
  cd /gitroot/libsbgn && ant \
  && cd /gitroot/CuratorTool/ant \
  && ant -buildfile ReactomeJar.xml \
  && ant -buildfile CuratorToolBuild.xml
}

PathwayExchange ()
{
  CuratorTool
  # Build Pathway Exchange
  cd /gitroot/Pathway-Exchange \
  && mvn install:install-file -Dfile=/gitroot/libsbgn/dist/org.sbgn.jar -DartifactId=sbgn -DgroupId=org.sbgn -Dpackaging=jar -Dversion=milestone2 \
  && mvn install:install-file -Dfile=./lib/celldesigner/celldesigner.jar -DgroupId=celldesigner -DartifactId=celldesigner -Dversion=UNKNOWN_VERSION -Dpackaging=jar \
  && mvn install:install-file -Dfile=./lib/protege/arq.jar -DgroupId=com.hp.hpl.jena -DartifactId=arq -Dpackaging=jar -Dversion=UNKNOWN_VERSION \
  && mvn install:install-file -Dfile=./lib/protege/protege.jar -Dpackaging=jar -DgroupId=edu.stanford.protege -DartifactId=protege -Dversion=UNKNOWN_VERSION \
  && mvn install:install-file -Dfile=./lib/protege/protege-owl.jar -Dversion=3.2 -DgroupId=edu.stanford.smi.protege -DartifactId=protege-owl -Dpackaging=jar \
  && mvn install:install-file -Dfile=lib/sbml/jsbml-0.8-rc1-with-dependencies.jar -DgroupId=org.sbml -DartifactId=jsbml -Dversion=0.8-rc1 -Dpackaging=jar \
  && mvn install:install-file -Dfile=./lib/sbml/libsbmlj.jar -DgroupId=org.sbml -DartifactId=libsbml -Dpackaging=jar -Dversion=0.8-rc1 \
  && pwd && mvn compile package install
}

RESTfulAPI ()
{
  # Build RESTfulAPI
  cd /gitroot/RESTfulAPI/ -lht \
  && mvn install:install-file -Dfile=/gitroot/CuratorTool/reactome.jar -DartifactId=Reactome -DgroupId=org.reactome -Dpackaging=jar -Dversion=UNKNOWN_VERSION \
  && pwd && mvn package
}

PathwayBrowser ()
{
  # Build Pathway Browser
  cd /gitroot/browser && mvn package \
  && cd /gitroot/diagram-exporter && mvn install \
  && cp /gitroot/browser/target/PathwayBrowser*.war /webapps/PathwayBrowser.war
}

ContentService ()
{
  # Build Content-service
  cd /gitroot/content-service && mvn package \
  && cp /gitroot/content-service/target/ContentService*.war /webapps/ContentService.war
}

AnalysisToolsCore ()
{
  # Analysis Tools requires core and service, building and installing core first
  cd /gitroot/AnalysisTools/Core && mvn package install
  echo "Following files were generated in Core/target"
  ls -a /gitroot/AnalysisTools/Core/target/
}

AnalysisBin ()
{
  cd /gitroot/AnalysisTools/Core/target/
  echo "Building analysis.bin, required for running analysis service:"
  time java -jar tools-jar-with-dependencies.jar build \
        -h 172.25.3.3 \
        -d gk_current \
        -u root \
        -p root \
        -o ./analysis.bin \
        -g /gitroot/AnalysisTools/interactors.db
  cp ./analysis.bin /downloads/
}

AnalysisToolsService ()
{
  # Build AnalysisTools service using the "AnalysisService-Local" profile.
  cd /gitroot/AnalysisTools/Service && mvn package -P AnalysisService-Local
  cp /gitroot/AnalysisTools/Service/target/analysis-service*.war /webapps/
}

InteractorsCore ()
{
  echo "Creating interactors.db ..." \
  cd /gitroot/interactors-core/ \
  && mvn package -DskipTests
  # if container has already been run once then the file would be present, we shall use that file
  if [[ -f /downloads/intact-micluster.txt ]]; then
    java -jar target/InteractorsParser-jar-with-dependencies.jar -g interactors.db -f /downloads/intact-micluster.txt
  else
    # else we need to download the intact-micluster.txt file (currently 315MB)
    java -jar target/InteractorsParser-jar-with-dependencies.jar -g interactors.db -d -t /downloads
  fi
  # Running tests
  mvn package -Dinteractors.SQLite=interactors.db \
  && cp interactors.db /downloads/
  echo "Successfully created interactors.db"
}
declare -A app_list
# app_list+=( ["CuratorTool"]=ready )
# app_list+=( ["PathwayExchange"]=ready )
# app_list+=( ["RESTfulAPI"]=ready )
# app_list+=( ["PathwayBrowser"]=ready )
# app_list+=( ["ContentService"]=ready )
# app_list+=( ["AnalysisToolsCore"]=notready )
# app_list+=( ["AnalysisToolsService"]=developing )
# app_list+=( ["AnalysisBin"]=ready )
app_list+=( ["InteractorsCore"]=notready )

for app in "${!app_list[@]}";
do
  if [[ ${app_list[${app}]} == "ready" ]]; 
  then
    echo ${app} " ready! Skippinig ahead"
  else
    echo "Developing " ${app} "In phase=" ${app_list[${app}]}
    ${app}
  fi
done
set +e