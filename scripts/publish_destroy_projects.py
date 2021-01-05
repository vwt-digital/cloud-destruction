import json
import argparse
import logging
from google.cloud import pubsub_v1
import sys
from gobits import Gobits

logging.basicConfig(level=logging.INFO)


def publish_to_topic(args, gobits):
    try:
        destroy_projects_msg_data = []
        with open(args.projects_destroy_list, 'r') as f:
            destroy_projects_list = f.read().splitlines()

        if not destroy_projects_list:
            logging.info("No projects in destroy_projects list, not publishing an empty list")
            return True

        for destroy_project_id in destroy_projects_list:
            destroy_projects_msg_data.append({
                "project_id": destroy_project_id
            })

        logging.info('Publishing destroy_projects list containing {} projects'.format(len(destroy_projects_list)))
        # Project ID where the topic is
        topic_project_id = args.topic_project_id
        # Topic name
        topic_name = args.topic_name
        # Publish to topic
        publisher = pubsub_v1.PublisherClient()
        topic_path = "projects/{}/topics/{}".format(
            topic_project_id, topic_name)
        msg = {
            "gobits": [gobits.to_json()],
            "destroy_projects": destroy_projects_msg_data
        }
        # print(json.dumps(msg, indent=4, sort_keys=True))
        future = publisher.publish(
            topic_path, bytes(json.dumps(msg).encode('utf-8')))
        future.add_done_callback(
            lambda x: logging.debug('Published destroy_projects list')
        )
        return True
    except Exception as e:
        logging.exception('Unable to publish destroy_projects list ' +
                          'to topic because of {}'.format(e))
    return False


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--projects-destroy-list', required=True)
    parser.add_argument('-p', '--topic-project-id', required=True)
    parser.add_argument('-t', '--topic-name', required=True)
    args = parser.parse_args()
    gobits = Gobits()
    if not publish_to_topic(args, gobits):
        sys.exit(1)
