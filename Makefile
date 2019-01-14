docker:
	# using the old tag, because the other doesnt support reloading of content
	docker run -p 8080:8080 -v `pwd`:/app-data \
		-ti --rm \
		--name kubeflow_workshop \
		-e CONTENT_URL_PREFIX="file:///app-data" \
		-e WORKSHOPS_URLS="file:///app-data/_workshop.yml" \
		-e LOG_TO_STDOUT=true \
		quay.io/osevg/workshopper:old

deploy:
	oc new-app quay.io/osevg/workshopper --name=workshop \
          -e WORKSHOPS_URLS="https://raw.githubusercontent.com/durandom/openshift_kubeflow_workshop/master/_workshop.yml" \
          -e LOG_TO_STDOUT=true \
          -n workshop
	oc expose svc/workshop -n workshop

rollout:
	oc rollout latest dc/workshop -n workshop

