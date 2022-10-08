# -*- coding: utf-8 -*-
"""
class for word vectorization
"""
import pandas as pd
from _io import BytesIO
from _io import *
from zipfile import ZipFile
from urllib.request import urlopen
import _io as io

class load_vectors:
    def __init__(self,fname):
        fin=io.open(fname, 'r', encoding='utf-8', newline='\n', errors='ignore')
        n, d=map(int,fin.readline().split())
        data={}
        for line in fin:
            tokens=line.rstrip().split(' ')
            data[tokens[0]]=map(float, tokens[1:])
        df=pd.DataFrame(data)
        return df

URL=urlopen('https://dl.fbaipublicfiles.com/fasttext/vectors-english/wiki-news-300d-1M.vec.zip')

"""These word vectors are distributed under the Creative Commons Attribution-Share-Alike License 3.0"""

data=ZipFile(BytesIO(URL.read()))
f=data.extract('wiki-news-300d-1M.vec', path=None, pwd=None)
dataset=load_vectors(f)


