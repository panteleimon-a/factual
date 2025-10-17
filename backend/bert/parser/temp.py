# -*- coding: utf-8 -*-
"""
class for word vectorization
"""
import pandas as pd
from zipfile import *

class load_vectors:
    def __init__(self,fname):
        fin=io.open(fname, 'r', encoding='utf-8', newline='\n', errors='ignore')
        n, d=map(int,fin.readline().split())
    @property
    def vecs(self):
        data={}
        for line in fin:
            tokens=line.rstrip().split(' ')
            data[tokens[0]]=map(float, tokens[1:])
        df=pd.DataFrame(data)
        return df