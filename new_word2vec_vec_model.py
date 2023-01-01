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

#Train word2vec model

import pandas as pd
import regex
from nltk.corpus import stopwords
from gensim.models import Word2Vec
import multiprocessing
import unicodedata as ud
import emoji
import gcld3 as gcld

#remove stop words

stopwords_list = stopwords.words("english")

def clean_data(text):
    #text = ud.normalize('NFD',text)
    text = regex.sub('@[^\s]+','',text)
    text = regex.sub("@[A-Za-z0-9_]+","", text)
    text = regex.sub(r'http\S+', '', text)
    text = regex.sub(r'[\\/×\^\]\[÷]', '', text)
    text = emoji.demojize(text)
    text=text.replace(",","")
    text_tokens = text.split(" ")
    final_list= [word for word in text_tokens if not word in stopwords_list]
    text = ' '.join(final_list)
    return text 

#remove stop words
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
    df=df.tolist()
    for i in range(len(df)):
        df[i] = df[i].split(" ")
    return df

def train_w2v(w2v_df):
    cores = multiprocessing.cpu_count()
    w2v_model = Word2Vec(min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 1,workers=cores-1)
    w2v_model.build_vocab(w2v_df, progress_per=10000)
    w2v_model.train(w2v_df, total_examples=len(w2v_df), epochs=100, report_delay=1)
    return w2v_model

'''
Alternative to make sentences
nlp = spacy.load('el_core_news_sm') #greekf
nlp = spacy.load("en_core_web_sm") #english
'''

#Download and load training dataset
from kaggle.api.kaggle_api_extended import KaggleApi
api = KaggleApi()
api.authenticate()

api.dataset_download_files('kaushiksuresh147/political-tweets')
unzip('/Users/pante/factual/political-tweets.zip')
df=pd.read_csv('/Users/pante/factual/Political_tweets.csv',low_memory=False)
csv_path = "/Users/pante/factual/Political_tweets.csv"
df = pd.read_csv(csv_path,low_memory=False,dtype="string")

#apply preprocessing to training dataset

df["text"] = pd.Series(df["text"], dtype="string")
df["text"] = df["text"].apply(change_lower)
df["text"] = pd.Series(df["text"], dtype="string")
df["text"] = df["text"].apply(clean_data)
df["text"] = pd.Series(df["text"], dtype="string")
df["text"] = df["text"].apply(remover)
df["text"] = pd.Series(df["text"], dtype="string")
df['text'] = df.text.apply(lambda x: x[1:-1].split(' '))
#dropna
df['text']=list(filter(None, df['text']))

'''
#Split each tweet in sentences
hamsplits=[]
for j in text:
    hamsplits.append([i.strip().split(' ') for i in regex.findall(r'[^.?!]+', j, regex.MULTILINE)])
#sentences =  df_str.split("\n")

'''

#CBOW
#w2v_df = df["text"].apply(get_w2vdf) #split() method :NOT NECESSARY SINCE LINE BELOW IS SUFFICIENT
w2v_model = train_w2v(df['text'])
w2v_model.save('w2v_model.txt')


'''
#training method 2
def train_sentences(self, sentences: List[List[str]], epochs: int = 1) -> None:
    self.model.min_count = 1  # so even words that only appears once are used
    self.model.build_vocab(sentences=sentences, update=True)  # update = True ensures that words are added to vocab
    self.model.train(sentences=sentences, epochs=epochs, total_examples=len(sentences))

w2v_model = train_sentences(w2v_df)

#training method 3, special for recalibration
new_w2v_df=
model.train(new_w2v_df, total_examples = len(new_w2v_df), epochs = 10)
'''


'''
#Download additional Kaggle training dataset 

#if api.authenticate() > error : use os method

import os

os.environ['KAGGLE_USERNAME'] = 'YOUR_USERNAME'
os.environ['KAGGLE_KEY'] = 'YOUR_KEY'
from kaggle.api.kaggle_api_extended import KaggleApi
api = KaggleApi()
api.authenticate()

api.dataset_download_files('jp797498e/twitter-entity-sentiment-analysis')
unzip('/Users/pante/factual/twitter-entity-sentiment-analysis.zip')
'''


'''
#Dictionary with words to correct text from slang, etc.

api.dataset_download_files('rtatman/english-word-frequency')
unzip('/Users/pante/factual/english-word-frequency.zip')
words=pd.read_csv('/Users/pante/factual/unigram_freq.csv',low_memory=False)
'''

df=pd.read_csv('/Users/pante/factual/twitter_training.csv',low_memory=False)
new_w2v_df=df['im getting on borderlands and i will murder you all ,']
#Data preprocessing for additional training dataset
new_w2v_df=new_w2v_df.dropna()
new_w2v_df = pd.Series(new_w2v_df, dtype="string")
new_w2v_df = new_w2v_df.apply(change_lower)
new_w2v_df= pd.Series(new_w2v_df, dtype="string")
new_w2v_df= new_w2v_df.apply(clean_data)
new_w2v_df= pd.Series(new_w2v_df, dtype="string")
new_w2v_df= new_w2v_df.apply(remover)
new_w2v_df= pd.Series(new_w2v_df, dtype="string")
#dropna
new_w2v_df=list(filter(None, new_w2v_df))
new_w2v_df = new_w2v_df.apply(lambda x: x[1:-1].split(' '))

#recalibrate model
w2v_model = train_w2v(new_w2v_df)
#w2v_model.save('w2v_model.txt') #save only if new model has better results in K-means


'''
Find main language of the text
'''
def detector(article):
    model=gcld.NNetLanguageIdentifier(min_num_bytes=0, max_num_bytes=1000)
    result=model.FindLanguage(text=article)
    return result.language


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


w2v_model=Word2Vec.load("/Users/pante/factual/w2v_model.txt")
word_vectors = Word2Vec.load("/Users/pante/factual/w2v_model.txt").wv

#optimize k
from sklearn.cluster import KMeans
wcss=[]
import seaborn as sns
for i in range(1, 20):
    clustering= KMeans(n_clusters=i, init='k-means++')
    clustering.fit(word_vectors.vectors)
    wcss.append(clustering.inertia_)
    
ks = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
sns.lineplot(x = ks, y = wcss)

#structure K-means model

model = KMeans(n_clusters=10, max_iter=1000, random_state=True, n_init=50).fit(X=word_vectors.vectors)

positive_cluster_center = model.cluster_centers_[0]
negative_cluster_center = model.cluster_centers_[9]
#word_vectors.similar_by_vector(model.cluster_centers_[9], topn=10, restrict_vocab=None) #print top 10 words in cluster[9]

#input tweet
article="By Tim Lister, CNN  Updated 4:44 PM ET, Fri December 9, 2022   (CNN)Russian President Vladimir Putin, for the second time this week, floated the possibility that Russia may formally change its m"
print(detector(article)) # tweet language

#vectorize tweet
def tweet(article, change_lower, clean_data, remover):    
    df_test=article
    df_test= pd.Series(df_test, dtype="string")
    df_test = df_test.apply(change_lower)
    df_test= pd.Series(df_test, dtype="string")
    df_test= df_test.apply(clean_data)
    df_test = pd.Series(df_test, dtype="string")
    df_test= df_test.apply(remover)
    df_test= pd.Series(df_test, dtype="string")
    df_test = df_test.apply(lambda x: x[1:-1].split(' '))
    df_test= pd.Series(df_test, dtype="string")
    df_test=df_test.to_string(index=False).replace(",","").split(" ")
    #dropna
    df_test=list(filter(None, df_test))

from gensim.models import FastText
import numpy as np

model = FastText(sentences=df["text"], vector_size=300)
vectors=model.wv
vec_article=[]
for word in df_test:
    vec_article.append(vectors[word])
    i+=1

vec_article=pd.Series(vec_article, dtype=str)

#cosin distance of our text from the clusters : when negative, we shall accept neutrality
from scipy import spatial
for i in vec_article:
    p_result =+ 1-spatial.distance.cosine(positive_cluster_center,i)
    n_result =+ 1-spatial.distance.cosine(negative_cluster_center,i)