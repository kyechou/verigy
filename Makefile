all: build

#-exportvector "vector"
#-exportmodel ".dot"
build: ctmc.prism
	prism $< \
		-exportresults "results.csv:csv" \
		-exporttransdot "transitions.dot" \
		-exporttransdotstates "transitions-states.dot"

clean:
	-@rm -rf *.csv *.dot

.PHONY: all build clean
