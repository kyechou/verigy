all: ctmc

ctmc: ctmc.prism ctmc.props
	prism $^ -mtbdd \
		-exportresults $@.results.csv:csv \
		-exportstaterewards $@.state.rewards \
		-exporttransrewards $@.trans.rewards

pta.games: pta.prism pta.games.props
	prism $^ -ptamethod games \
		-exportresults $@.results.csv:csv

pta.digital: pta.prism pta.digital.props
	prism $^ -ptamethod digital \
		-exportresults $@.results.csv:csv

clean:
	-@rm -rf *.csv *.dot *.rewards

.PHONY: all ctmc pta.games pta.digital clean

#-exportvector "vector"
#-exportmodel ".dot"
#-exporttransdot "transitions.dot" \
#-exporttransdotstates "transitions-states.dot"

