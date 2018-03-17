PORTS=9091 9092 9093 9094

all : check_env $(PORTS)

check_env :
	@which nginx   2>&1 > /dev/null
	@which python3 2>&1 > /dev/null
	@which pandoc  2>&1 > /dev/null

$(PORTS) :
	@mkdir -p ./sites/${@}
	@sed 's/PORT_NUMBER/${@}/' ./index.html > ./sites/${@}/index.html
	@cd ./sites/${@} && python3 -m http.server ${@} &

clean :
	@ps -e | grep "python3 -m http.server $(PORT)" | grep -v cd | grep -v grep | awk '{print $$1}' | xargs kill

cleanall :
	@$(foreach PORT, $(PORTS), $(MAKE) clean PORT=$(PORT) && rm -rf ./sites/$(PORT) && ) rmdir sites && true

.PHONY: all check_env stop clean cleanall $(PORTS)
