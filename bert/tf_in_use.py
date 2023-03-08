##################### TF IDF (the LDA is ready, not added yet :@) ############################
#import what you need
import pandas as pd
import numpy as np
import nltk
nltk.download('punkt')
from nltk.corpus import stopwords
import string
import matplotlib.pyplot as plt
import seaborn as sns
# For now we have only the english text 
en_stop=stopwords.words('english')
from sklearn.feature_extraction.text import TfidfVectorizer
remove_punctuation_map = dict((ord(char), None) for char in string.punctuation)
#the preprocess is currently with the nltk quick and agile. It is not custimizable but it is what we need right now
def preprocess(text):
  return nltk.word_tokenize(text.lower().translate(remove_punctuation_map))
vectorizer = TfidfVectorizer(tokenizer=preprocess, stop_words=en_stop)
#the return has the cosine similarity in essense
def compute_similarity(a, b):
  tfidf = vectorizer.fit_transform([a, b])
  return ((tfidf * tfidf.T).toarray())[0,1]