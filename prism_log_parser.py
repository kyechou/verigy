#!/usr/bin/env python3

import ast
import copy
import argparse

class Result:
    def __init__(self):
        self.property: str              = ''

        self.pkt_rate: float            = 0.0
        self.qlen: int                  = 0
        self.throughput: int            = 0
        self.timer_RRC: int             = 0
        self.timer_idle: int            = 0
        self.timer_eDRX: int            = 0
        self.timer_PSM: int             = 0

        self.model_build_time: float    = 0.0
        self.num_states: int            = 0
        self.num_transitions: int       = 0

        self.DFA_trans_time: float      = 0.0
        self.model_check_time: float    = 0.0
        self.result: float              = 0.0

    def __str__(self):
        return (self.property + ', ' + str(self.pkt_rate) + ', ' +
                str(self.qlen) + ', ' + str(self.throughput) + ', ' +
                str(self.timer_RRC) + ', ' + str(self.timer_idle) + ', ' +
                str(self.timer_eDRX) + ', ' + str(self.timer_PSM) + ', ' +
                str(self.model_build_time) + ', ' + str(self.num_states) + ', '
                + str(self.num_transitions) + ', ' + str(self.DFA_trans_time) +
                ', ' + str(self.model_check_time) + ', ' + str(self.result))

def parse_prism_log(filename):
    results = []
    result = Result()
    first_time = True
    with open(filename, 'r') as file:
        for line in file:
            if line.startswith('----------'):
                if first_time:
                    first_time = False
                else:
                    results.append(copy.deepcopy(result))
            elif line.startswith('Model checking'):
                prop = line.split()[2].translate(str.maketrans('', '', '":'))
                result.property = prop
            elif line.startswith('Model constants'):
                for constant_str in line.split()[2].split(','):
                    const_name = constant_str.split('=')[0]
                    const_value = ast.literal_eval(constant_str.split('=')[1])
                    setattr(result, const_name, const_value)
            elif line.startswith('Time for model construction'):
                result.model_build_time = float(line.split()[4])
            elif line.startswith('States:'):
                result.num_states = int(line.split()[1])
            elif line.startswith('Transitions:'):
                result.num_transitions = int(line.split()[1])
            elif line.startswith('Time for deterministic automaton translation'):
                result.DFA_trans_time = float(line.split()[5])
            elif line.startswith('Time for model checking'):
                result.model_check_time = float(line.split()[4])
            elif line.startswith('Result:'):
                result.result = float(line.split()[1])
        results.append(copy.deepcopy(result))

    print('property, pkt_rate, qlen, throughput, timer_RRC, timer_idle, '
          'timer_eDRX, timer_PSM, model_build_time, states, transitions, '
          'DFA_trans_time, model_check_time, result')
    for result in results:
        print(str(result))

def main():
    parser = argparse.ArgumentParser(description='PRISM log parser')
    parser.add_argument('files', metavar='file', nargs='*',
                        help='Input file names')
    arg = parser.parse_args()

    for file in arg.files:
        parse_prism_log(file)

if __name__ == '__main__':
    main()
