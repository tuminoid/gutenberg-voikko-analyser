#!/usr/bin/env python

import sys
from libvoikko import Voikko

v = Voikko("fi")
baseform = []

with open('/data/words.txt', 'r') as fh:
    for line in fh:
        for word in line.split():
            analysis = v.analyze(word)
            if len(analysis) > 0:
                print("{}:{}".format(
                    analysis[0]["BASEFORM"],
                    analysis[0]["CLASS"]))
