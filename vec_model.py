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
import fasttext
from parser.temp import load_vectors

class vec_model:
    def __init__(self):
        print("Vectorization model is getting trained")
    @property
    def train_vec(self):
        URL=urlopen('https://dl.fbaipublicfiles.com/fasttext/vectors-english/wiki-news-300d-1M.vec.zip')
        """These word vectors are distributed under the Creative Commons Attribution-Share-Alike License 3.0"""
        data=ZipFile(BytesIO(URL.read()))
        f=data.extractall
        dataset=load_vectors(f)
        return dataset

