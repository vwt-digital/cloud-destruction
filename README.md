# Shutdown GCP Projects using cloud-destruction

Shutting down a Google Cloud Project (GCP) is not very complicated. It can be done by a single click in the Cloud Console. However, in a [software defined everything](https://github.com/vwt-digital/operational-data-hub/blob/develop/architecture/adr/0004-create-software-defined-everything.md) environment, also removal of resources needs to be done by software. The code in this repository facilitates shutting down projects without any manual intervention. Beware and use it with care!

## Usage

Cloud-destruction can be used to destroy one or more projects in a single execution. It is running as a [Cloud Build](https://cloud.google.com/cloud-build) and requires some configuration files. In a common use case scenario, projects will be created and shutdown from a specific project managing project. See [cloud-deployment](https://github.com/vwt-digital/cloud-deployment) for an example of a project-creation setup. The configuration required by cloud-destruction is based on that of cloud-deployment.

The cloud-destruction Cloud Build is configured by passing it these substitution variables:
* ```_PROJECTS_CATALOG_DIR```: A directory containing a sub-directory for each project that should exist. These sub-directories can be empty. Make sure that every project in the organisation where the project to destroy resides is represented by a folder, minus the project to destroy itself.
* ```_PROJECTS_DESTROY_LIST```: A text file listing all projects to shut down, each project on a seperate line.
* ```_PARENT_ID```: The GCP ID of the organisation or folder containing all projects defined in the ```_PROJECTS_CATALOG_DIR```.

Make sure that you submit the cloudbuild in the project managing GCP project, not in the project to destroy. This can be done by either adding the [project tag](https://cloud.google.com/sdk/gcloud/reference#--project) ```--project=``` or setting the project in the gcloud config with the [set project command](https://cloud.google.com/sdk/gcloud/reference/config/set) ```gcloud config set project```.

Running the cloud-destruction Cloud Build can be done by this command:
```
$ cd cloud-destruction
$ gcloud builds submit . \
  --substitutions="_PARENT_ID=nnn,_PROJECTS_DESTROY_LIST=destroy_projects.lst,_PROJECTS_CATALOG_DIR=config/projects"
```

First, these checks will be done:
* If any project exists that is not specified in the ```_PROJECTS_CATALOG_DIR``` or ```_PROJECTS_DESTROY_LIST```, the build will break.
* If any project in ```_PROJECTS_DESTROY_LIST``` is still also specified in ```_PROJECTS_CATALOG_DIR```, the build will break.

If both checks pass, all existing projects that are specified in ```_PROJECTS_DESTROY_LIST``` will be shut down.
