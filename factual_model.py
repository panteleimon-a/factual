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
import pandas as pd
import numpy as np
import regex
from nltk.corpus import stopwords
from gensim.models import Word2Vec
import multiprocessing
import unicodedata as ud
import emoji
import gcld3 as gcld
from gensim import utils
from gensim.utils import tokenize as tk
from scipy import spatial

#remove stop words and clean data

stopwords_list = stopwords.words("english")

def clean_data(text):
    i=0
    for sentence in text:
        j=0
        for each in sentence:
            new_text=[word.replace(",","") for word in each]
            new_text =[regex.sub('@[^\s]+','',word) for word in new_text]
            new_text = [regex.sub("@[A-Za-z0-9_]+","",word) for word in new_text]
            new_text = [regex.sub(r'http\S+', '', word) for word in new_text]
            new_text = [emoji.demojize(word) for word in new_text]
            final_list= [word for word in new_text if not word in stopwords_list]
            text[i][j]=final_list
            j+=1
        i+=1
        
    return text

def change_lower(text):
    i=0
    for sentence in text:
        j=0
        for each in sentence:
            new_text=[word.lower() for word in each]
            text[i][j]=new_text
            j+=1
        i+=1
    return text

def train_w2v(w2v_df):
    cores = multiprocessing.cpu_count()
    w2v_model = Word2Vec(min_count=4,window=4,vector_size=300, alpha=0.03, min_alpha=0.0007, sg = 1,workers=cores-1)
    w2v_model.build_vocab(w2v_df, progress_per=10000)
    w2v_model.train(w2v_df, total_examples=len(w2v_df), epochs=100, report_delay=1)
    return w2v_model

def tok(text):
    return list(tk(text))
def sentence_tok(df):
    sentences = []
    for sentence in df:
        sentences.append(sentence.split())
    return sentences

def tweeter(article, change_lower, clean_data): #Only for validation or for tweets testing
    df_test=pd.Series(dtype=str)
    result=pd.Series(dtype=str)
    try:
        article.shape[1]
        df_test["text"]=pd.Series(article["text"],dtype=str)
        i=0
        for sentence in df_test["text"]:
            df_test["text"][i]=tok(sentence)
            i+=1
        df_test["text"]=pd.Series(df_test["text"],dtype=str) 
        df_test["text"] = df_test["text"].apply(change_lower)
        df_test["text"] = pd.Series(df_test["text"], dtype="string")
        df_test["text"]= df_test["text"].apply(clean_data)
        df_test["text"]= pd.Series(df_test["text"], dtype="string")
        df_test["text"]= pd.Series(df_test["text"], dtype="string")
        df_test["text"]=pd.Series(df_test["text"],dtype=str)
        # Replacing empty string with np.NaN
        df_test["text"] = df_test["text"].replace('', np.nan)
        
        df_test["sentiment"]=article["sentiment"]
        # Dropping rows where NaN is present
        df_test.dropna(inplace=True)#subset=['text'] for specific column
        df_test["text"]= pd.Series(df_test["text"].tolist(),dtype=str)

        result=df_test     
    except AttributeError:
        df_test=list(tok(article))
        df_test=pd.Series(df_test,dtype=str) 
        df_test = df_test.apply(change_lower)
        df_test= pd.Series(df_test, dtype="string")
        df_test= df_test.apply(clean_data)
        df_test= pd.Series(df_test, dtype="string")
        df_test=pd.Series(df_test,dtype=str) 
        # Replacing empty string with np.NaN
        df_test = df_test.replace('', np.nan)
        # Dropping rows where NaN is present
        result = df_test.dropna()#subset=['text'] for specific column
        result=result.tolist()
    return result

def tweet_vec(tweet,model):
    #vectors=model.wv
    vec_article=[]
    for word in tweet:
        vec_article.append(model.wv.get_vector(word))
    vec_article=pd.Series(vec_article, dtype=str)
    return vec_article

#cosin distance of our text from the clusters : when negative, we shall accept neutrality

def sent_score(vec_article,positive_cluster_center,negative_cluster_center):
    p_result=0
    n_result=0
    for i in vec_article:
        p_result =+ 1-spatial.distance.cosine(positive_cluster_center,i)
        n_result =+ 1-spatial.distance.cosine(negative_cluster_center,i)
    if p_result*n_result<0:
        return "Neutral"
    elif -0.1<p_result+n_result<0.1:
        return "Irrelevant"
    elif abs(p_result)>abs(n_result):
        return "Negative"
    else:
        return "Positive"


#using tensorflow / Source: https://www.projectpro.io/recipes/train-word2vec-model-tensorflow

#Dictionary with words to correct text from slang, etc.

api.dataset_download_files('rtatman/english-word-frequency')
unzip('/Users/pante/factual/english-word-frequency.zip')
words=pd.read_csv('/Users/pante/factual/unigram_freq.csv',low_memory=False)

#validation 1
new_df=pd.read_csv('/Users/pante/Git_Repositories/factual/data/twitter_validation.csv',low_memory=False)
new_df=new_df.dropna(how='any')
new_w2v_df=pd.DataFrame()
new_w2v_df["text"]=new_df['I mentioned on Facebook that I was struggling for motivation to go for a run the other day, which has been translated by Tom’s great auntie as ‘Hayley can’t get out of bed’ and told to his grandma, who now thinks I’m a lazy, terrible person 🤣']
new_w2v_df["text"]
new_w2v_df["sentiment"]=new_df['Irrelevant']




#Find main language of the text

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

def test(article,positive_cluster_center ,negative_cluster_center):    
    #vectorize tweet
    tweet=tweeter(article, change_lower=change_lower, clean_data=clean_data)
    a=[]
    for i in tweet:
        a.append(i.replace(",","").replace("\n",""))
    tweet=a 
    #vectorize tweet
    vec_tweet=tweet_vec(tweet,ft_model)
    return sent_score(vec_tweet,positive_cluster_center,negative_cluster_center)

'''
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
'''

word_vectors=KeyedVectors.load("/Users/pante/Git_Repositories/factual/cbow/en_wiki_word2vec_300.txt")
#word_vectors=w2v_model.wv
#word_vectors = Word2Vec.load("/Users/pante/factual/w2v_model.txt").wv

#optimize k
from sklearn.cluster import KMeans
wcss=[]
import seaborn as sns
for i in range(1, 20):
    clustering= KMeans(n_clusters=i, init='k-means++')
    clustering.fit(word_vectors.vectors)
    wcss.append(clustering.inertia_)
    
ks = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
sns.lineplot(x = ks, y = wcss)

#structure K-means model

model = KMeans(n_clusters=2, max_iter=1000, random_state=True, n_init=50).fit(X=word_vectors.vectors)
#save sklearn model with pickle
import pickle

with open("kmeans.pkl", "wb") as f:
    pickle.dump(model, f)

word_vectors.similar_by_vector(model.cluster_centers_[0], topn=100, restrict_vocab=None) #print top 10 words in cluster[9]

#input tweet
article="By Tim Lister, CNN  Updated 4:44 PM ET, Fri December 9, 2022   (CNN)Russian President Vladimir Putin, for the second time this week, floated the possibility that Russia may formally change its m"
print(detector(article)) # tweet language

from gensim.models import FastText, KeyedVectors
#train=df["text"]
#vec_model = FastText(sentences=train, vector_size=300)
#vec_model.save("ft.vec_model.txt")
ft_model=FastText.load("/Users/pante/Git_Repositories/factual/cbow/en_wiki_fasttext_300.bin")
#load k-means
with open("kmeans.pkl", "rb") as f:
    model = pickle.load(f)
positive_cluster_center = model.cluster_centers_[0]
negative_cluster_center = model.cluster_centers_[1]

import time
start = time.time()
print(test(article,positive_cluster_center,negative_cluster_center))
end = time.time()

new_w2v_df=new_w2v_df.reset_index(drop=True)

KeyedVectors.distance(vec_tweet=tweet_vec(tweet,ft_model),positive_cluster_center)
i=1
a=[]
for tweet in new_w2v_df["text"]:
    print("Iteration:",i)
    a.append((tweet,positive_cluster_center,negative_cluster_center))
    i+=1

i=1
a=[]
for tweet in result[0]:
    print("Iteration:",i)
    a.append(test(tweet,positive_cluster_center,negative_cluster_center))
    i+=1

a=pd.Series(a,dtype=str).reset_index(drop=True)
(a == result[1] ).sum()

