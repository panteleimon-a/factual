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
''''
Train word2vec model

import pandas as pd
import regex
from nltk.corpus import stopwords
from gensim.models import Word2Vec
import multiprocessing
import unicodedata as ud

csv_path = "/Users/pante/factual/Political_tweets.csv"

df = pd.read_csv(csv_path,low_memory=False)


def clean_data(text):
    text = ud.normalize('NFD',text)
    #remove links
    text = regex.sub(r'https?:\/\/\S*', '', text, flags=regex.MULTILINE)
    text = regex.sub(r'[^ \nA-Za-z0-9À-ÖØ-öø-ÿ/]+', '', text)
    text = regex.sub(r'[\\/×\^\]\[÷]', '', text)
    text=' '.join(regex.sub("(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)"," ",text).split())
    return regex.sub(r'[!@#$]', '', text)

stopwords_list = stopwords.words("english")
def remover(text):
    text_tokens = text.split(" ")
    final_list = [word for word in text_tokens if not word in stopwords_list]
    text = ' '.join(final_list)
    return text

def change_lower(text):
    text = text.lower()
    return text

def get_w2vdf(df):
    w2v_df = pd.DataFrame(df).values.tolist()
    for i in range(len(w2v_df)):
        w2v_df[i] = w2v_df[i][0].split(" ")
    return w2v_df

def train_w2v(w2v_df):
    cores = multiprocessing.cpu_count()
    w2v_model = Word2Vec(min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 1,workers=cores-1)
    w2v_model.build_vocab(w2v_df, progress_per=10000)
    w2v_model.train(w2v_df, total_examples=w2v_model.corpus_count, epochs=100, report_delay=1)
    return w2v_model

df["text"] = df["text"].astype(str)
df["text"] = df["text"].apply(change_lower)
df["text"] = df["text"].apply(clean_data)
df["text"] = df["text"].apply(remover)

#CBOW
w2v_df = get_w2vdf(df['text'])
w2v_model = train_w2v(w2v_df)
w2v_model.save('w2v_model.txt')

#training method 1
def train_sentences(self, sentences: List[List[str]], epochs: int = 1) -> None:
    self.model.min_count = 1  # so even words that only appears once are used
    self.model.build_vocab(sentences=sentences, update=True)  # update = True ensures that words are added to vocab
    self.model.train(sentences=sentences, epochs=epochs, total_examples=len(sentences))

w2v_model = train_sentences(w2v_df)

#training method 2
new_w2v_df=
model.train(new_w2v_df, total_examples = len(new_w2v_df), epochs = 10)


'''


import pandas as pd
import regex
from nltk.corpus import stopwords
from gensim.models import Word2Vec
import multiprocessing
import pandas as pd
import gcld3 as gcld
#fasttext.util.download_model('en', if_exists='ignore')  # English
#fasttext.util.download_model('el', if_exists='ignore')  # Greek


#api.dataset_download_files('jp797498e/twitter-entity-sentiment-analysis')
#unzip('/Users/pante/factual/twitter-entity-sentiment-analysis.zip')
#api.dataset_download_files('rtatman/english-word-frequency')
#unzip('/Users/pante/factual/english-word-frequency.zip')
words=pd.read_csv('/Users/pante/factual/unigram_freq.csv',low_memory=False)
df=pd.read_csv('/Users/pante/factual/twitter_training.csv',low_memory=False)
new_w2v_df=df['im getting on borderlands and i will murder you all ,']
#now follow code lines 24-74 for cleaning data
new_w2v_df=new_w2v_df.astype(str)
new_w2v_df=new_w2v_df.apply(change_lower)
new_w2v_df=new_w2v_df.apply(clean_data)
new_w2v_df=new_w2v_df.apply(remover)
new_w2v_df=get_w2vdf(new_w2v_df)
l = ['@','%']
out_list = []
for x in new_w2v_df:
    for y in l:
        if y in x:
            x = x.replace(y,'')
            out_list.append(x)
            break
'''
#remove hashtags and split words according to dictionary (@words variable)
def partitioner(hashtag, words):
    while hashtag:
        word_found = longest_word(hashtag, words)
        yield word_found
        hashtag = hashtag[len(word_found):]

def longest_word(phrase, words):
    current_try = phrase
    while current_try:
        if current_try in words or current_try.lower() in words:
            return current_try
        current_try = current_try[:-1]
    # if nothing was found, return the original phrase
    return phrase

def partition_hashtag(text, words):
    return re.sub(r'#(\w+)', lambda m: ' '.join(partitioner(m.group(1), words)), text)

def read_dictionary_file(filename):
    with open(filename, 'rb') as f:
        return set(word.strip() for word in f)


#if __name__ == '__main__':
words = read_dictionary_file('words.txt')
print(partition_hashtag("#Whatthehello #goback", words))
'''

#recalibrate word2vec
w2v_model=Word2Vec.load("w2v_model.txt")
w2v_model.train(new_w2v_df, total_examples = len(new_w2v_df), epochs = 50)
word_vectors = Word2Vec.load("w2v_model.txt").wv
from sklearn.cluster import KMeans
model = KMeans(n_clusters=2, max_iter=1000, random_state=True, n_init=50).fit(X=word_vectors.vectors)
positive_cluster_center = model.cluster_centers_[1]
negative_cluster_center = model.cluster_centers_[0]

article="By Tim Lister, CNN  Updated 4:44 PM ET, Fri December 9, 2022   (CNN)Russian President Vladimir Putin, for the second time this week, floated the possibility that Russia may formally change its m"
'''
Find main language of the text
'''
def detector(article):
    model=gcld.NNetLanguageIdentifier(min_num_bytes=0, max_num_bytes=1000)
    result=model.FindLanguage(text=article)
    return result.language

# test
# text="Γεια"
print(detector(article))


def unzip(path):
    from zipfile import ZipFile
    zf = ZipFile(path)
    #extracted data is saved in the same directory
    zf.extractall() 
    zf.close()

if detector(article)=="en":
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

    import pandas as pd
    unzip('/Users/pante/factual/contractions.zip')
    CONTRACTIONS = pd.read_csv('/Users/pante/factual/contractions.csv').values.tolist()
else:
    CONTRACTIONS=[] #Greek contractions in progress

api.dataset_download_files('kaushiksuresh147/political-tweets')
unzip('/Users/pante/factual/political-tweets.zip')
df=pd.read_csv('/Users/pante/factual/Political_tweets.csv',low_memory=False)

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

from unidecode import unidecode
import itertools
import emoji

def clean_data(tweet,remove_non_english_letters):
    #CONTRACTIONS is a list of contractions and slang and their conversion. { "you've":"you have", "luv":"love", etc...}
    tweet = tweet.replace("’","'")
    tweet = remove_non_english_letters(tweet)
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



def token(tweet):
    tokens=word_tokenize(tweet)
    return tokens

tokens=token(article)
tokens =clean_data(" ".join(str(x) for x in tokens),unidecode)
tokens=tokens.split(" ")

def text_to_word_list(text):
    ''' Pre process and convert texts to a list of words 
    method inspired by method from eliorc github repo: https://github.com/eliorc/Medium/blob/master/MaLSTM.ipynb'''
   
    text = str(text)
    text = text.lower()

    return text

tokens = text_to_word_list(tokens)
#split in sentences and vectorization

def param(article):
    if detector(article)=="el":
        stop_words = set(stopwords.words('greek'))
        #nlp = spacy.load('el_core_news_sm')
        #c_terms = ["και", "αλλά", "γιατί", "ή", "όμως", "ο", "η", "το"] # Create the relevant phrases from the list of sentences:
        return stop_words#,c_terms
    elif detector(article)=="en":
        stop_words = set(stopwords.words('english'))
        #nlp = spacy.load('en_core_web_sm')
        #c_terms=[]
        return stop_words#,c_terms
    else:
        print("Unable to process article's given language")

stop_words=param(article)
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

def list_of_lists(tokens,stop_words):
    #remove stop words
    filtered_sentence = [w for w in tokens if not w in stop_words]
    return filtered_sentence
    '''
    !Not working!
    for i in article:
        doc = nlp(remove_stopwords(strip_punctuation(strip_non_alphanum(str(i).lower()))))
        tokens = [token.text for token in doc]
        text.append(tokens)
    '''
tokens=list_of_lists(article,stop_words)




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
w2v_model=Word2Vec.load("w2v_model.txt")
word_vectors = Word2Vec.load("w2v_model.txt").wv
from sklearn.cluster import KMeans
model = KMeans(n_clusters=2, max_iter=1000, random_state=True, n_init=50).fit(X=word_vectors.vectors)
positive_cluster_center = model.cluster_centers_[1]
negative_cluster_center = model.cluster_centers_[0]


def vector(tokens):
    text_tensor=[]
    for i in tokens:
        vec=word_vectors[(str(i))]
        text_tensor.append(vec)
    return text_tensor
text_tensor=vector(tokens)
#print(text_tensor)

#Test vector model efficiency
#en_model = KeyedVectors.load_word2vec_format('wiki-news-300d-1M.vec')
#ret_vals = en_model.similar_by_vector(text_tensor[i])

#Categorize vectors of a fasttext pretrained on 1m wiki-news words model in 2 clusters
from sklearn.cluster import KMeans
import numpy as np
from gensim.models import Word2Vec
from gensim.models import KeyedVectors
'''
word_vectors = KeyedVectors.load_word2vec_format("/Users/pante/factual/wiki-news-300d-1M.vec")
#word_vectors = KeyedVectors.load_word2vec_format("/Users/pante/factual/wiki-news-300d-1M.vec").vectors
model = KMeans(n_clusters=3, max_iter=1000, random_state=True, n_init=50).fit(X=word_vectors.vectors)
positive_cluster_center = model.cluster_centers_[0]
neutral_cluster_center = model.cluster_centers_[1]
negative_cluster_center = model.cluster_centers_[2]
#word_vectors.similar_by_vector(model.cluster_centers_[2], topn=20, restrict_vocab=None)
'''
#cosin distance of our text with the clusters
def cos_similarity(x,y):
  """ return cosine similarity between two lists """
 
  numerator = sum(a*b for a,b in zip(x,y))
  denominator = squared_sum(x)*squared_sum(y)
  return round(numerator/float(denominator),3)

cos_similarity(positive_cluster_center, embeddings[1])
cos_similarity(negative_cluster_center, embeddings[1])