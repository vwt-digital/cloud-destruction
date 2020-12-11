#! /bin/bash

DESTROY_PROJECT="${1}"

set -e

if [ -z "${DESTROY_PROJECT}" ]
then
    echo "Specify project to destroy"
    echo "Syntax: $0 <project-to-destroy>"
    exit 1
fi

echo "Destroying Cloud Scheduler jobs of ${DESTROY_PROJECT}..."
for schedule_job in $(gcloud scheduler jobs list --format="get(name)" --project="${DESTROY_PROJECT}")
do
    gcloud --quiet scheduler jobs delete "${schedule_job}" --project="${DESTROY_PROJECT}"
done

echo "Destroying Cloud Functions of ${DESTROY_PROJECT}..."
for cloud_function in $(gcloud functions list --format="get(name)" --project="${DESTROY_PROJECT}")
do
    function_region=$(echo ${cloud_function} | cut -d"/" -f3)
    function_name=$(echo ${cloud_function} | cut -d"/" -f6)
    gcloud --quiet functions delete "${function_name}" --region="${function_region}" --project="${DESTROY_PROJECT}"
done

echo "Destroying App Engine of ${DESTROY_PROJECT}..."
for app_service in $(gcloud app services list --format="get(id)" --project="${DESTROY_PROJECT}")
do
    gcloud --quiet app services delete "${app_service}" --project="${DESTROY_PROJECT}"
done

echo "Destroying Cloud Endpoints of ${DESTROY_PROJECT}..."
for endpoint_service in $(gcloud endpoints services list --format="get(serviceName)" --project="${DESTROY_PROJECT}")
do
    gcloud --quiet endpoint services delete "${endpoint_service}" --project="${DESTROY_PROJECT}"
done

echo "Deleting deployment of ${DESTROY_PROJECT}..."
if gcloud --quiet deployment-manager deployments describe "${DESTROY_PROJECT}-project-deploy"
then
    gcloud deployment-manager deployments delete "${DESTROY_PROJECT}-project-deploy" --delete-policy=abandon
fi

echo "Shutting down ${DESTROY_PROJECT}..."
gcloud --quiet projects delete "${DESTROY_PROJECT}"
