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
from gensim.models import Word2Vec, KeyedVectors, FastText
from tqdm.auto import tqdm
import unicodedata as ud
import emoji
import gcld3 as gcld
from gensim import utils
from gensim.utils import tokenize as tk
from scipy import spatial
stopwords_list = stopwords.words("english")

def clean_data(text):
    a=[]
    for sentence in text:
        new_text =[regex.sub('@[^\s]+','',word) for word in sentence]
        new_text = [regex.sub("@[A-Za-z0-9_]+","",word) for word in new_text]
        new_text = [regex.sub(r'http\S+', '', word) for word in new_text]
        new_text = [emoji.demojize(word) for word in new_text]
        final_list= [word for word in new_text if not word in stopwords_list]
        final_list= [word for word in final_list if len(word)>2]
        a.append(final_list)
    return a

def change_lower(text):
    a=[]
    for sentence in text:
        new_text=''.join([word.lower() for word in sentence])
        a.append(new_text)
    return a

def tok(text):
    return list(tk(text))

def tweet_vec(tweet,word_vectors,ft_model):
    #vectors=model.wv
    vec_article=[]
    try:
        for word in tweet:
            vec_article.append(word_vectors.get_vector(word))
    except (IndexError, SyntaxError, TypeError, KeyError):
        for word in tweet:
            vec_article.append(ft_model.wv[word])
    vec_article=pd.Series(vec_article, dtype=str)
    return vec_article

def tweet_score(article,positive_cluster_center,negative_cluster_center):
    p_result=0
    n_result=0
    for i in article:
        p_result =+ (1-spatial.distance.cosine(positive_cluster_center,i))
        n_result =+ (1-spatial.distance.cosine(negative_cluster_center,i))
    if -0.01<p_result+n_result<0.01:
        return "Neutral"
    elif abs(p_result-n_result)<0.01:
        return "Irrelevant"
    elif abs(p_result)>abs(n_result):
        return "Negative"
    else:
        return "Positive"

def predict(df:object,positive_cluster_center:np.ndarray ,negative_cluster_center:np.ndarray, word_vectors:KeyedVectors, ft_model:FastText):    
    scores=[]
    #vectorize tweets
    for tweet in tqdm(df):
        vec_tweet=tweet_vec(tweet,word_vectors,ft_model)
        scores.append(tweet_score(vec_tweet,positive_cluster_center,negative_cluster_center))
    return scores

#load models
word_vectors=KeyedVectors.load("/Users/pante/Git_Repositories/factual/cbow/en_wiki_word2vec_300.txt")
ft_model=KeyedVectors.load("/Users/pante/Git_Repositories/factual/skipgram/en_wiki_fasttext_300.bin")

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

model = KMeans(n_clusters=17, max_iter=1000, random_state=True, n_init=50).fit(X=word_vectors.vectors)
positive_cluster_center = model.cluster_centers_[0]
negative_cluster_center = model.cluster_centers_[16]
#1-spatial.distance.cosine(negative_cluster_center,positive_cluster_center)
#word_vectors.similar_by_vector(model.cluster_centers_[16], topn=100, restrict_vocab=None) #print top 10 words in cluster[9]

#validation 1
val_df=pd.read_csv('/Users/pante/Git_Repositories/factual/data/twitter_validation.csv',low_memory=False)
val_df=val_df.dropna(how='any')
val_w2v_df=pd.DataFrame()
val_w2v_df["text"]=val_df['I mentioned on Facebook that I was struggling for motivation to go for a run the other day, which has been translated by Tom’s great auntie as ‘Hayley can’t get out of bed’ and told to his grandma, who now thinks I’m a lazy, terrible person 🤣']
val_w2v_df["sentiment"]=val_df['Irrelevant']
#preprocessing
val_w2v_df["text"]=change_lower(val_w2v_df["text"])
val_w2v_df["text"]=val_w2v_df["text"].apply(tok)
val_w2v_df["text"]=clean_data(val_w2v_df["text"])
y_input=val_w2v_df["sentiment"]
y_predict=predict(val_w2v_df["text"],positive_cluster_center=positive_cluster_center,negative_cluster_center=negative_cluster_center, word_vectors=word_vectors, ft_model=ft_model)
print("Accuracy:",(y_predict == y_input).sum()/len(y_input))

#validation 1
cols=['sentiment','text']
train_df=pd.read_csv('/Users/pante/Git_Repositories/factual/data/twitter_training.csv',low_memory=False,usecols=[2,3],names=cols)
train_df.dropna(how='any',inplace=True)
train_df.reset_index(inplace=True)
train_df.drop(columns=['index'], inplace=True)
#preprocessing
train_df["text"]=change_lower(train_df["text"])
train_df["text"]=train_df["text"].apply(tok)
train_df["text"]=clean_data(train_df["text"])
y_train=train_df["sentiment"]
y_predict=predict(train_df["text"],positive_cluster_center=positive_cluster_center,negative_cluster_center=negative_cluster_center, word_vectors=word_vectors, ft_model=ft_model)
print("Accuracy:",(y_predict == y_input).sum()/len(y_input))