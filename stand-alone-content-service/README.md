# :construction: Stand-alone Reactome Content service :construction:

This document explains how to build and run Reactome's ContentService as a stand-alone Docker image.

1. Clone this repository, checkout the feature/Joomla branch and `cd` to `stand-alone-content-service`.
```bash
git clone https://github.com/reactome/container.git
git checkout feature/Joomla
cd stand-alone-content-service
```

2. Build the docker image. This can be done with the command:
```bash
docker build -t reactome_content_service -f content-service.dockerfile .
```

3. Download the Reactome graph database and extract it to the stand-alone-content-service directory:
```bash
wget https://reactome.org/download/current/reactome.graphdb.tgz
tar -xzf reactome.graphdb.tgz
```

4. Run the docker container which you just built. This can be done with the command:
```bash
docker run --name content-service --rm -v $(pwd)/reactome.graphdb.v66:/neo4j/neo4j-community-3.4.10/data/databases/graph.db -p 8888:8080 reactome_content_service
```
:warning: **NOTE:** You may need to change the mount for the graph database, depending on the version of the file you download (the "_v66_" in the mount: `reactome.graphdb.v66:/neo4j/neo4j-community-3.4.10/data/databases/graph.db`).

5. You should now be able to access the ContentService at [http://localhost:8888/ContentService](http://localhost:8888/ContentService). On this page you will see a listing of endpoints for the ContentService which you can test interactively

If you prefer to access the ContentService from the command line, you can use the content service like this:

```bash
wget http://localhost:8888/ContentService/exporter/event/R-HSA-5205682.sbgn > R-HSA-5205682.sbgn
```

:warning: **Attention!** :warning: This docker image of the ContentService is a work-in-progress. Some endpoints might not be 100% functional yet. So far, only `/exporter/event/{identifier}.sbgn` and `/exporter/event/{identifier}.sbml` have been tested. Others _may_ work, but no guarantees are given at this time.
