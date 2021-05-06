all: build

#-exportvector "vector"
#-exportmodel ".dot"
#-exporttransdot "transitions.dot" \
#-exporttransdotstates "transitions-states.dot"
build: ctmc.prism
	prism $< -mtbdd -exportresults "results.csv:csv" \
		-exportstaterewards staterewards \
		-exporttransrewards transrewards

clean:
	-@rm -rf *.csv *.dot

.PHONY: all build clean
