# -*- coding: utf-8 -*-
"""
Word vectorization model

requirements:
fasttext-langdetect
fasttext

"""
import fasttext
import fasttext.util
import pandas as pd
fasttext.util.download_model('en', if_exists='ignore')  # English
fasttext.util.download_model('gr', if_exists='ignore')  # Greek
ft_en = fasttext.load_model('cc.en.300.bin')          
ft_en.get_dimension()
ft_gr = fasttext.load_model('cc.gr.300.bin')  
ft_gr.get_dimension()
'''
Reduce vectors dimension

#fasttext.util.reduce_model(ft, 100)
#ft_en.get_dimension()

Test Nearest Neighbors

#ft_en.get_word_vector('hello').shape
#ft_en.get_nearest_neighbors('hello')
'''
class tovec:
    def __init__(self, wordlistfl):
        result = detect(text=wordlistfl, low_memory=False)
        return result[0][0]
        