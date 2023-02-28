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
import fasttext
from nltk.corpus import stopwords
from gensim.models import Word2Vec, KeyedVectors, FastText
from tqdm.auto import tqdm
import unicodedata as ud
import emoji
import gcld3 as gcld
from gensim import utils
from gensim.utils import tokenize as tk
from scipy import spatial
import io
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

#load fasttext vectors only for .txt vectors
'''
def load_vectors(fname):
    fin = io.open(fname, 'r', encoding='utf-8', newline='\n', errors='ignore')
    n, d = map(int, fin.readline().split())
    data = {}
    for line in fin:
        tokens = line.rstrip().split(' ')
        data[tokens[0]] = map(float, tokens[1:])
    return data
'''
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
            vec_article.append(ft_model.get_word_vector(word))
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
from gensim.models import KeyedVectors
word_vectors=KeyedVectors.load("/Users/pante/Git_Repositories/factual/google-news.bin")
ft_vectors = fasttext.load_model("/Users/pante/Git_Repositories/factual/cc.en.300.bin") #fasttext pre-trained model with data from 2017
#ft_vectors.words to classify fasttext



# K-Means (not operating with word-vectors)
#optimize k
from sklearn.cluster import KMeans
wcss=[]
import seaborn as sns
clusters=50
for i in range(1, clusters):
    clustering= KMeans(n_clusters=i, init='k-means++')
    clustering.fit(word_vectors.vectors)
    wcss.append(clustering.inertia_)
    
ks=[i for i in range(0,clusters-1)]
sns.lineplot(x = ks, y = wcss)

# point where curv changes convexity
kurt_point=30
model = KMeans(n_clusters=kurt_point, max_iter=1000, random_state=True, n_init=50).fit(X=word_vectors.vectors)
positive_cluster_center = model.cluster_centers_[0]
negative_cluster_center = model.cluster_centers_[kurt_point-1]

kurt_point=25
ensmbl_model = KMeans(n_clusters=kurt_point, max_iter=1000, random_state=True, n_init=50).fit(X=model.cluster_centers_)
positive_cluster_center=ensmbl_model.cluster_centers_[0]
negative_cluster_center=ensmbl_model.cluster_centers_[kurt_point-1]
#info

from numpy import (array, dot, arccos, clip)
from numpy.linalg import norm
c = dot(negative_cluster_center,positive_cluster_center)/norm(negative_cluster_center)/norm(positive_cluster_center) # -> cosine of the angle
angle = arccos(clip(c, -1, 1)) # if you really want the angle
np.linalg.norm(positive_cluster_center)
np.linalg.norm(negative_cluster_center)
np.angle([positive_cluster_center])
np.angle([negative_cluster_center])
#1-spatial.distance.cosine(negative_cluster_center,positive_cluster_center)
#word_vectors.similar_by_vector(model.cluster_centers_[16], topn=100, restrict_vocab=None) #print top 10 words in cluster[9]

#experimentation starts here


import hdbscan
from joblib import Memory
import numpy as np
from sklearn.neighbors import DistanceMetric
metric = DistanceMetric.get_metric('mahalanobis', V=np.cov(word_vectors.vectors))
clusterer = hdbscan.HDBSCAN(algorithm='best', alpha=1.0, approx_min_span_tree=True, gen_min_span_tree=False, leaf_size=40, memory=Memory(cachedir=None), metric=metric, min_cluster_size=4, min_samples=1, p=None)
clusterer.fit(word_vectors.vectors) #this might be a ndarray 

#The algorithm creates its own clusters
#The amount of clusters it created:
print(clusterer.labels_.max()+1)
#These are the assigned clusters for each vector:
print(clusterer.labels_)
#In order to find the "centroids" we can use the probability of the vector to belong in the assigned cluster.
print(clusterer.probabilities_)
#the vectors with probability=1 should be on the center of the alleged centroids.
centered_vectors={}
i=0
for prob in clusterer.probabilities_:
    if prob=1: centered_vectors[vectors[i]]=clusterer.labels_[i]
    i=i+1

#I would expect more than one vector to have probability of one in a cluster. The Mahalanobis distance might has to do with that. It measure the distance of the vector and the distribution of the class. The algorithm works hierarchical, meaning that it begins taking the whole dataset as one class and then splits it according to the mahalanobis distance. I expect the forming of not many classes, but who knows at this point. There is the case where, the algorithm will disregard some vectors as noise, meaning that they are not contributing to the variance of none of the classes. They can be regarded as irrelevant or neutral.
#Getting the "centroid" of the class can be tricky. However the mean of the keys of the above dictionary can give us a general centroid for each class.


# PCA
from sklearn.preprocessing import StandardScaler
from sklearn.preprocessing import PowerTransformer
from sklearn.decomposition import PCA

# apply the power transformer

pt = PowerTransformer().fit(word_vectors.vectors)
word_power_transformed = pd.DataFrame(
    pt.transform(word_vectors.vectors)
)

# apply a standard scaler
scaler = StandardScaler().fit(word_power_transformed)
word_power_scaled_transformed = pd.DataFrame(scaler.transform(word_power_transformed))

#apply the PCA

pca = PCA()
pca.fit(word_power_scaled_transformed)
#calculate the num of components based on #variance
mean_var=pca.explained_variance_ratio_.mean()
arr=pd.Series([var for var in pca.explained_variance_ratio_],dtype=float)
common_var=arr.quantile(q=0.99,interpolation="higher")
comps = len([c for c in list(pca.explained_variance_ratio_) if c>=common_var]) 
pca_train = PCA(n_components = comps)
df_pca_train = pd.DataFrame(
    pca_train.fit_transform(word_power_scaled_transformed)
    )

#apply the k-means
#optimize k
from sklearn.cluster import KMeans
wcss=[]
import seaborn as sns
clusters=30
for i in range(1, clusters):
    clustering= KMeans(n_clusters=i, init='k-means++', random_state=42)
    clustering.fit(df_pca_train)
    wcss.append(clustering.inertia_)
    
ks=[i for i in range(0,clusters-1)]
sns.lineplot(x = ks, y = wcss)
# point where curv changes convexity
kurt_point=25
model = KMeans(n_clusters=kurt_point, max_iter=1000, random_state=True, n_init=50).fit(X=df_pca_train)
positive_cluster_center = model.cluster_centers_[0]
negative_cluster_center = model.cluster_centers_[kurt_point-1]
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
y_predict=predict(val_w2v_df["text"],positive_cluster_center=positive_cluster_center,negative_cluster_center=negative_cluster_center, word_vectors=word_vectors, ft_model=ft_vectors)
print("Accuracy:",(y_predict == y_input).sum()/len(y_input))


#experimentation ends here






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
y_predict=predict(val_w2v_df["text"],positive_cluster_center=positive_cluster_center,negative_cluster_center=negative_cluster_center, word_vectors=word_vectors, ft_model=ft_vectors)
print("Accuracy:",(y_predict == y_input).sum()/len(y_input))

#validation 2
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
y_predict=predict(train_df["text"],positive_cluster_center=positive_cluster_center,negative_cluster_center=negative_cluster_center, word_vectors=word_vectors, ft_model=ft_vectors)
print("Accuracy:",(y_predict == y_train).sum()/len(y_train))