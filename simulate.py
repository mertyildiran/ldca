#!/bin/python3

import os
import sys
import subprocess
import random
from difflib import SequenceMatcher

data = [
    (
        ('2', '3'),
        '5'
    ),
    (
        ('4', '5'),
        '9'
    ),
    (
        ('7', '1'),
        '8'
    )
]

def compare(a, b):
    return SequenceMatcher(None, a, b).ratio()

def run_program(program_id, replicate, *args):
    replicate_arg = '0'
    if replicate:
        replicate_arg = '1'
    program_name = str(program_id).rjust(49, '0')
    cwd = os.path.abspath(sys.argv[1])
    process = subprocess.Popen(('./{}'.format(program_name), replicate_arg, *args), cwd=cwd, stdout=subprocess.PIPE)
    output = subprocess.check_output(('xxd', '-p'), stdin=process.stdout)
    process.wait()
    return output.decode('utf-8')

program_id = 0
out0 = run_program(program_id, True)
print(out0)

candidate = [program_id, program_id]
for i in range(1, 20):
    print('Iter:', i)
    program_id += 1
    candidate[0] = program_id
    program_id += 1
    candidate[1] = program_id

    try:
        score1 = 0
        score2 = 0

        for row in data:
            out1 = run_program(candidate[0], False, *row[0])
            print(out1)

            out2 = run_program(candidate[1], False, *row[0])
            print(out2)

            score1 += compare(out1, row[1])
            score2 += compare(out2, row[1])

        score1 = score1 / len(data)
        score2 = score2 / len(data)

        if score1 > score2:
            run_program(candidate[0], True)
        elif score1 < score2:
            run_program(candidate[1], True)
        else:
            dice = random.randint(0, 1)
            run_program(candidate[dice], True)

    except FileNotFoundError:
        program_id -= 2
        run_program(program_id, True)
