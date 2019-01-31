restart_service:
	sudo rm -f /tmp/audit.log
	sudo systemctl stop camflowd
	sudo rm -f /tmp/audit.log
	sudo systemctl start camflowd
	stat /tmp/audit.log

camflow_config:
	sudo camflow --compress-node false
	sudo camflow --compress-edge false
	sudo camflow --duplicate false
	sudo camflow --reset-filter

record_version:
	camflow -v > version.txt

record_config:
	camflow -c > config.txt

record_state:
	camflow -s > state.txt

prepare_examples:
	mkdir -p build
	cd build && git clone https://github.com/camflow/examples
	cd build/examples && make all

wget:
	$(MAKE) restart_service
	sudo camflow --track-file /bin/wget true
	wget www.google.com
	sudo camflow --track-file /bin/wget false
	sleep 10
	cp /tmp/audit.log wget.log
	rm index.html

pipe:
	$(MAKE) restart_service
	./build/examples/provenance/pipe.o
	sleep 10
	cp /tmp/audit.log pipe.log

all: record_version record_config record_state wget pipe restart_service

validate:
	camtool --validate pipe.log
	camtool --validate wget.log
	mkdir data
	mv pipe.log data/
	provparser -t camflow -v -k -i data/
	rm -rf data
	mkdir data
	mv wget.log data/
	provparser -t camflow -v -k -i data/
