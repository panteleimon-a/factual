# -*- coding: utf-8 -*-
"""
Word vectorization model

requirements:
fasttext
Google Compact Language Detector v3 (CLD3)Permalink (gcld3)
spacy
gensim
sklearn
python -m spacy download el_core_news_sm
python -m spacy download en_core_web_sm
nltk
kaggle
regex
itertools
emoji
word2vec

"""
import fasttext
import fasttext.util
import pandas as pd
import gcld3 as gcld
#fasttext.util.download_model('en', if_exists='ignore')  # English
#fasttext.util.download_model('el', if_exists='ignore')  # Greek

'''
Find main language of the text
'''
article="By Tim Lister, CNN  Updated 4:44 PM ET, Fri December 9, 2022   (CNN)Russian President Vladimir Putin, for the second time this week, floated the possibility that Russia may formally change its m"
def detector(article):
    model=gcld.NNetLanguageIdentifier(min_num_bytes=0, max_num_bytes=1000)
    result=model.FindLanguage(text=article)
    return result.language

# test
# text="Γεια"
print(detector(article))


'''
Reduce vectors dimension

#fasttext.util.reduce_model(ft, 100)
#ft_en.get_dimension()

Test Nearest Neighbors

#ft.get_word_vector('hello').shape
#ft.get_nearest_neighbors('hello')
'''
import spacy
from spacy.lang.en import English, Greek
from spacy import displacy
import os
import numpy as np
import tqdm
from gensim.models.phrases import Phrases, Phraser,ENGLISH_CONNECTOR_WORDS
from gensim.parsing.preprocessing import remove_stopwords, strip_punctuation, strip_non_alphanum
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import nltk
nltk.download('stopwords')
from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize
nltk.download('punkt')
#split in sentences and vectorization
def param(article):
    if detector(article)=="el":
        ft = fasttext.load_model('cc.el.300.bin')
        stop_words = set(stopwords.words('greek'))
        #nlp = spacy.load('el_core_news_sm')
        print("Model dimension:",ft.get_dimension())
        #c_terms = ["και", "αλλά", "γιατί", "ή", "όμως", "ο", "η", "το"] # Create the relevant phrases from the list of sentences:
        return ft,stop_words#,c_terms
    elif detector(article)=="en":
        ft = fasttext.load_model('cc.en.300.bin')
        stop_words = set(stopwords.words('english'))
        #nlp = spacy.load('en_core_web_sm')
        print("Model dimension:",ft.get_dimension())
        #c_terms=[]
        return ft,stop_words#,c_terms
    else:
        print("Unable to process article's given language")

ft,stop_words=param(article)
#print(vector(article))

''''

def listToString(s):
 
    # initialize an empty string
    str1 = ""
 
    # traverse in the string
    for ele in s:
        str1 += ele
 
    # return string
    return str1
'''

def list_of_lists(article,stop_words):
    word_tokens = word_tokenize(article)
    filtered_sentence = [w for w in word_tokens if not w.lower() in stop_words]
    return filtered_sentence
    '''
    !Not working!
    for i in article:
        doc = nlp(remove_stopwords(strip_punctuation(strip_non_alphanum(str(i).lower()))))
        tokens = [token.text for token in doc]
        text.append(tokens)
    '''
    
'''
gensim.phrases to remove common terms and generate phrases? mostly applicable for Word2Vec
if c_terms!=[]:
    c_terms= frozenset(listToString(c_terms).split())
else:
    c_terms=ENGLISH_CONNECTOR_WORDS
phrases = Phrases(text, common_terms=c_terms # The Phraser object is used from now on to transform sentences
bigram = Phraser(phrases) # Applying the Phraser to transform our sentences is simply
tokens = list(bigram[text])
'''

tokens=list_of_lists(article,stop_words)
#print(list_of_lists(article,stop_words))

if detector(article)=="el":
    #eglish contractions
    #make sure .kaggle authentication file is in workspace 
    from kaggle.api.kaggle_api_extended import KaggleApi
    api = KaggleApi()
    api.authenticate()
    '''#or, use os method
    import os

    os.environ['KAGGLE_USERNAME'] = 'YOUR_USERNAME'
    os.environ['KAGGLE_KEY'] = 'YOUR_KEY'

    from kaggle.api.kaggle_api_extended import KaggleApi

    api = KaggleApi()
    api.authenticate()'''
    api.dataset_download_files('ishivinal/contractions')
    from zipfile import ZipFile
    zf = ZipFile('/Users/pante/factual/contractions.zip')
    #extracted data is saved in the same directory
    zf.extractall() 
    zf.close()
    import pandas as pd
    CONTRACTIONS = pd.read_csv('/Users/pante/factual/contractions.csv').values.to_string()
else:
    CONTRACTIONS=[] #Greek contractions in progress

import regex
import itertools
'''
#Strip accents: Limited for English but widely used for other languages, accents are often misplaced or forgotten. The easiest way to deal with them is to get rid of them.
def strip_accents(text):
    if 'ø' in text or  'Ø' in text:
        #Do nothing when finding ø 
        return text   
    text = text.encode('ascii', 'ignore')
    text = text.decode("utf-8")
    return str(text)
'''
import emoji
def clean_data(tweet):
    #CONTRACTIONS is a list of contractions and slang and their conversion. { "you've":"you have", "luv":"love", etc...}
    tweet = tweet.replace("’","'")
    words = tweet.split()
    reformed = [CONTRACTIONS[word] if word in CONTRACTIONS else word for word in words]
    tweet = " ".join(reformed)
    '''
    Utility function to clean tweet text by removing links, special characters
    using simple regex statements.
    '''
    tweet = ''.join(''.join(s)[:2] for _, s in itertools.groupby(tweet))
    tweet = emoji.demojize(tweet)
    return ' '.join(regex.sub("(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)", " ", tweet).split())
    

tokens=clean_data(" ".join(str(x) for x in tokens))
tokens=tokens.split(" ")

def vector(tokens,ft):
    text_tensor=[]
    for i in tokens:
        vec=ft.get_word_vector(str(i))
        text_tensor.append(vec)
    return text_tensor
text_tensor=vector(tokens,ft)
print(text_tensor)
#Test vector model efficiency
#en_model = KeyedVectors.load_word2vec_format('wiki-news-300d-1M.vec')
#ret_vals = en_model.similar_by_vector(text_tensor[i])

#Categorize vectors of a fasttext pretrained on 1m wiki-news words model in 2 clusters
from sklearn.cluster import KMeans
import numpy as np
from gensim.models import Word2Vec
from gensim.models import KeyedVectors
#model = KeyedVectors.load_word2vec_format("/Users/pante/factual/wiki-news-300d-1M.vec")
model = KMeans(n_clusters=2, max_iter=1000, random_state=True, n_init=50).fit(X=model.vectors)
positive_cluster_center = model.cluster_centers_[0]
negative_cluster_center = model.cluster_centers_[1]

#cosin distance of our text with the clusters
