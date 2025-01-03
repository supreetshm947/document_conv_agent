start_n8n:
	docker compose up

set_volume_permissions:
	mkdir -p ./n8n_data
	sudo chmod -R 777 ./n8n_data