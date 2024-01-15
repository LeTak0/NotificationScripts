#!/bin/bash
#SSL and ServiceWorker Certificate needed.
topicurl={Notification Server URL with Topic PATH , https://example.com/Docker}
# List images of the running containers
IMAGES=$(docker ps --format '{{.Image}}')

for IMAGE in $IMAGES; do
    # Try to pull the latest image without updating the installed container's image
    # and redirect errors to /dev/null to handle them gracefully
    if docker pull -q $IMAGE 2>/dev/null; then

        # Get image ID of the currently used image by the running container
        CURRENT_IMAGE_ID=$(docker inspect --format '{{.Image}}' $(docker ps -q --filter ancestor=$IMAGE))

        # Get image ID of the latest image on Docker Hub
        LATEST_IMAGE_ID=$(docker inspect --format '{{.Id}}' $IMAGE)

        # Check if they differ
        if [ "$CURRENT_IMAGE_ID" != "$LATEST_IMAGE_ID" ]; then
            # Send notification through cURL 
	    curl \
    		-d "Update available for $IMAGE" \
    		-H "Title: Docker Update $(hostname)" \
    		-H "Priority: high" \
    		-H "Tags: warning,whale" \
    		-H "Authorization: {TOKEN}" \
    		$topicurl
        fi
    else
        echo "Failed to pull image: $IMAGE. It may be private or local."
    fi
done
