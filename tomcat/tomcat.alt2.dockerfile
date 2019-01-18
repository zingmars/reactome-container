# name a whole bunch of base layers that contain pre-built components (applications and content/data files)
FROM reactome/reactomerestfulapi as restfulapi
FROM reactome/analysisservice as analysisservice
FROM reactome/contentservice as contentservice
FROM reactome/datacontent as datacontent
FROM reactome/pathwaybrowser as pathwaybrowser
FROM reactome/diagramjs as diagramjs
FROM reactome/fireworksjs as fireworksjs
FROM reactome/analysis-core as analysiscore
FROM reactome/fireworks-generator as fireworks
FROM reactome/diagram-generator as diagramfiles
# Final layer is Tomcat.
FROM tomcat:8.5.35-jre8
# Copy in all the components that we need.
COPY --from=restfulapi /webapps/*.war /usr/local/tomcat/webapps/
COPY --from=analysisservice /webapps/*.war /usr/local/tomcat/webapps/
COPY --from=contentservice /webapps/*.war /usr/local/tomcat/webapps/
COPY --from=datacontent /webapps/*.war /usr/local/tomcat/webapps/
COPY --from=pathwaybrowser /webapps/*.war /usr/local/tomcat/webapps/
COPY --from=diagramjs /webapps/*.war /usr/local/tomcat/webapps/
COPY --from=fireworksjs /webapps/*.war /usr/local/tomcat/webapps/
COPY --from=analysiscore /output/analysis.bin /analysis.bin
COPY --from=fireworks /fireworks-json-files /usr/local/tomcat/webapps/download/current/fireworks
COPY --from=diagramfiles /diagrams /usr/local/tomcat/webapps/download/current/diagram

RUN ln -s /usr/local/tomcat/webapps/diagram*.war /usr/local/tomcat/webapps/DiagramJs.war
RUN ln -s /usr/local/tomcat/webapps/fireworks*.war /usr/local/tomcat/webapps/FireworksJs.war
RUN ls -lht  /usr/local/tomcat/webapps/

RUN apt-get update && apt-get install -y netcat zip && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/interactors/tuple
RUN mkdir -p /var/www/html/download/current/
# WORKDIR /usr/local/tomcat/webapps/download/
ADD https://reactome.org/download/current/ehlds.tgz /usr/local/tomcat/webapps/download/current/ehld.tgz
RUN cd /usr/local/tomcat/webapps/download/current && tar -zxf ehld.tgz
ADD https://reactome.org/download/current/ehld/svgsummary.txt /usr/local/tomcat/webapps/download/current/ehld/svgsummary.txt
RUN chmod a+r /usr/local/tomcat/webapps/download/current/ehld/svgsummary.txt
RUN mkdir -p /var/www/html/ehld-icons
ADD https://reactome.org/ehld-icons/icon-lib-svg.tgz /var/www/html/ehld-icons/icon-lib-svg.tgz
RUN cd /var/www/html/ehld-icons/ && tar -zxf icon-lib-svg.tgz
ADD https://reactome.org/ehld-icons/icon-lib-emf.tgz /var/www/html/ehld-icons/icon-lib-emf.tgz
RUN cd /var/www/html/ehld-icons/ && tar -zxf icon-lib-emf.tgz
ADD https://reactome.org/ehld-icons/icon-lib-png.tgz /var/www/html/ehld-icons/icon-lib-png.tgz
RUN cd /var/www/html/ehld-icons/ && tar -zxf icon-lib-png.tgz

# Now,update the properties files in the applications.
WORKDIR /usr/local/tomcat/webapps/

COPY ./properties/content-service.ogm.properties /usr/local/tomcat/webapps/WEB-INF/classes/ogm.properties
RUN { touch WEB-INF/classes/ogm.properties; zip -u ContentService.war WEB-INF/classes/ogm.properties; rc=$?; echo $rc; if [ $rc -eq 12 ]; then exit 0; fi; exit $rc; }
COPY ./properties/content-service.service.properties /usr/local/tomcat/webapps/WEB-INF/classes/service.properties
RUN { touch WEB-INF/classes/service.properties; zip -u ContentService.war WEB-INF/classes/service.properties; rc=$?; echo $rc; if [ $rc -eq 12 ]; then exit 0; fi; exit $rc; }
# RUN zip -u ContentService.war WEB-INF/classes/service.properties && zip -u ContentService.war WEB-INF/classes/ogm.properties

COPY ./properties/data-content.ogm.properties /usr/local/tomcat/webapps/WEB-INF/classes/ogm.properties
RUN { touch WEB-INF/classes/ogm.properties; zip -u content.war WEB-INF/classes/ogm.properties; rc=$?; echo $rc; if [ $rc -eq 12 ]; then exit 0; fi; exit $rc; }
COPY ./properties/data-content.service.properties /usr/local/tomcat/webapps/WEB-INF/classes/core.properties
# RUN zip -u content.war WEB-INF/classes/core.properties && zip -u content.war WEB-INF/classes/ogm.properties
RUN { touch WEB-INF/classes/core.properties; zip -u content.war WEB-INF/classes/core.properties; rc=$?; echo $rc; if [ $rc -eq 12 ]; then exit 0; fi; exit $rc; }

COPY ./properties/analysis-service.service.properties /usr/local/tomcat/webapps/WEB-INF/classes/analysis.properties
# RUN zip -u AnalysisService.war WEB-INF/classes/analysis.properties
RUN { touch WEB-INF/classes/analysis.properties; zip -u AnalysisService.war WEB-INF/classes/analysis.properties; rc=$?; echo $rc; if [ $rc -eq 12 ]; then exit 0; fi; exit $rc; }

COPY ./properties/RESTfulAPI_application-context.xml /usr/local/tomcat/webapps/WEB-INF/applicationContext.xml
RUN touch /usr/local/tomcat/webapps/WEB-INF/applicationContext.xml
RUN zip -F ReactomeRESTfulAPI.war --out ReactomeRESTfulAPI_fixed.war && mv ReactomeRESTfulAPI_fixed.war ReactomeRESTfulAPI.war
RUN { zip -u ReactomeRESTfulAPI.war WEB-INF/applicationContext.xml; rc=$?; echo $rc; if [ $rc -eq 12 ]; then exit 0; fi; exit $rc; }

RUN mkdir -p /ContentService/custom
RUN mkdir -p /AnalysisService/tokens
