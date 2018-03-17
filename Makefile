SINGLE_PORT=8181
BALANCE_PORT=8282
TARGET_PORTS=9091 9092 9093 9094

all : check_env $(TARGET_PORTS)
	@nginx -s stop || true
	@nginx -c ./nginx.conf -p .
	@pandoc -f html http://localhost:$(SINGLE_PORT)
	@$(foreach PORT, $(TARGET_PORTS), pandoc -f html http://localhost:$(BALANCE_PORT) && ) true

check_env :
	@which nginx   2>&1 > /dev/null
	@which python3 2>&1 > /dev/null
	@which pandoc  2>&1 > /dev/null

$(TARGET_PORTS) :
	@mkdir -p ./sites/${@}
	@sed 's/PORT_NUMBER/${@}/' ./index.html > ./sites/${@}/index.html
	@cd ./sites/${@} && python3 -m http.server ${@} &

clean :
	@nginx -s stop || true
	@ps -e | grep "python3 -m http.server $(PORT)" | grep -v cd | grep -v grep | awk '{print $$1}' | xargs kill

cleanall :
	@$(foreach PORT, $(TARGET_PORTS), $(MAKE) clean PORT=$(PORT) && rm -rf ./sites/$(PORT) && ) rmdir sites && true

.PHONY: all check_env stop clean cleanall $(TARGET_PORTS)
