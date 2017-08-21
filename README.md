# Reactome Container

## Overview

[Reactome](http://reactome.org/) is a free, open-source, curated and peer reviewed pathway database. It is an online bioinformatics database of human biology described in molecular terms. It is an on-line encyclopedia of core human pathways. [Reactome Wiki](http://wiki.reactome.org/index.php/Main_Page) provides more details about reactome. 

This project enables users to setup a standalone reactome server on their own system. With this server users will be able to run an instance of [Reactome](http://reactome.org/) on their local system. Reactome server is packaged in  docker containers so any system capable of running docker can run an instance of this server.

### Details

This project builds up a reactome server with all the required java applications inside docker containers and deploys them. The broad view of structure of the project is shown in the image below. Image describes how different components of the project are connected to each other and what endpoints are available to the user for interaction. 

This project includes a submodule from [release](https://github.com/reactome/Release/) repository. The website part and perl scripts for the server are derived from there. The java applications required by reactome server are built from following repositories of reactome:

1. [Curator Tool](https://github.com/reactome/CuratorTool)
2. [Pathway Exchange](https://github.com/reactome/Pathway-Exchange)
3. [RESTfulAPI](https://github.com/reactome/RESTfulAPI)
4. [Pathway Browser](https://github.com/reactome-pwp/browser)
5. [Diagram Exporter](https://github.com/reactome-pwp/diagram-exporter)
6. [Content Service](https://github.com/reactome/content-service)
7. [Data Content](https://github.com/reactome/data-content)
8. [Search Core](https://github.com/reactome/search-core)
9. [Analysis Tools](https://github.com/reactome/AnalysisTools)
10. [Interactors Core](https://github.com/reactome-pwp/interactors-core)



## Set Up

You can begin with cloning the repository along with its submodule using:

```
git clone --recursive https://github.com/reactome/container.git
```

Before you can run this project, you need to [install docker](https://docs.docker.com/engine/installation/) and [install docker-compose](https://docs.docker.com/compose/install/) on your system. To ease out things, installation instructions are packed in the file [prereqs-ubuntu.sh](https://github.com/reactome/container/blob/master/prereqs-ubuntu.sh) which can be executed by:

```
cd container
./prereqs-ubuntu.sh
```

## Understanding Workflow

The workflow of project works is described in following steps:

1. Download data and archives: First of all we need to get database files ready. These are downloaded by `deploy.sh -d all` or `deploy.sh -u all`.
2. When database is ready, we need to build java-applications by `deploy.sh -b all`.
3. Now everything is ready, and we can now start the server using `deploy.sh -r`.

These three steps can be combined in one command: 

```
./deploy.sh -d all -b all -r
```

## How to run

For the first time, we need to download the database files and build all the applications before we run the server. All this is managed by the `deploy.sh` script. You may just execute the given command if you are running this project for the first time:

```
./deploy.sh -d all -b all -r
```

The above command will download all database files and then build all the applications. While using the first time, users are advised to use `-b all` to build all the applications since some applications are dependend on other. After that users may select individual applications to build using `select` argument with `-b` flag.

#### Flags used with `deploy.sh`

The `./deploy.sh` script can be run with single or multiple or no flags. The usage of flags is described below:

 - `-d` or `--download` to Download database files. It will remove old database files (if present) and download new files from remote server. This will not include those files which can be built locally (analysis.bin and interactors.db). It will download only these files: database files (neo4j db and tomcat db ), diagrams and fireworks and solr_data.

 - `-d all` or `--download all` to Download all files. It will remove previous files and download new ones. The files that will be affected include: database files, diagrams and fireworks, solr_data. And due to `all` argument, it will also include: analysis.bin, interactors.db.

  -  `-u` or `--update` to Update database files. It will update database files and those files which cannot be built locally. Files which can be built locally will not be affected. This flag plays a two way role. If the files are not present locally, then it downloads the files and if the remote file is newer, then local file is deleted and new one is downloaded. It is like a superset to download flag.

 -  `-u all` or `--update all` to Update all database files. It will include all data archives and also the files which can be built locally, for example, analysis.bin and interactors.db.

 - `-b` or `--build`  is Build flag. Rebuild essential war files.
 
 - `-b all` or `--build all` is Build all flag. It will build all webapps. Data files like analysis.bin and interactors.db will also be built due to the presence of all argument.

 - `-b select` or `--build select` It will allow user to select which webapps to build. By using this flag, the user will be presented with name of the services and from there user will be required to press y/n for yes/no if the service should be built or not.
 
- `-r` or `--run` is used to run the server. This should be the last flag when you are providing a number of flags. For example, `./deploy.sh --update all --build --run` this command will update all archives, and then build the essential applications, and then start the server, while `./deploy.sh --run --update all --build` this command will just run the reactome server and then exit.

- `-h` or `--help` displays a message with details of all the flags.

## How to use

After the reactome server has been given the instruction to get started, it will take some time get ready. When it is ready, then you will be able to visit following endpoints at your browser:

-   `localhost:80` for reactome.org
-   `localhost:8983` for solr admin
-   `localhost:7474` for neo4j admin
-   `localhost:8082/manager/html` for tomcat manager

## Configuring custom passwords

Some services require password for running and they have been provided with the default passowrds in their environment file, the files having `.env` extension. The default passwords can be changed by changing the `env` file for corresponding service.

- **Mysql:** Its configurations are stored in `tomcat.env`. `root` is the default user and if you want to add another user or change the password then you can add following lines to [tomcat.env](https://github.com/reactome/container/blob/master/tomcat.env)

  ```
  MYSQL_USER=<you_user_name>
  MYSQL_PASSWORD=<you_password>
  ```

  Note: If you add your own user and password for mysql, then make sure, to change the username and password at [application-context](https://github.com/reactome/container/blob/master/java-application-builder/mounts/applicationContext.xml#L14) and also modify password of wordpress database user at [wordpress.env](https://github.com/reactome/container/blob/master/wordpress.env#L9).

- **Tomcat Admin:** Its users and their passwords can be modified in [tomcat-users.xml](https://github.com/reactome/container/blob/master/tomcat/tomcat-users.xml#L46).

- **Neo4j Admin:** Its password can be changed in [neo4j.env](https://github.com/reactome/container/blob/master/neo4j.env#L1) by modifying first line to: `NEO4J_AUTH=<new_user>/<new_password>`
Note: If you modify password of neo4j, then make sure to update changes at [content-service-pom.xml](https://github.com/reactome/container/blob/master/java-application-builder/mounts/content-service-pom.xml#L26) and at [data-content-pom.xml](https://github.com/reactome/container/blob/master/java-application-builder/mounts/data-content-pom.xml#L36)

- **Solr Admin:**  Its default username and password is currently not configurable and both are set as `solr`

- **Wordpress:** The username and password for wordpress-admin can be modified by executing following command when the server is running.

  ```
  docker exec -i mysql-database mysql --user=<username_from_wordpress.env> --password=<password_from_wordpress.env> wordpress <<< "UPDATE wp_users SET user_login = 'user_name', user_pass = 'password' where id=1;"
  ```

  The changes will be made by service named `mysql-database` and changes will reside in database file internal to `mysql-database` container. On removing container, the customized username and password will also be removed.
