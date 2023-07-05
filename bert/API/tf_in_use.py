##################### TF IDF (the LDA is ready, not added yet :@) ############################
#import what you need
try:
  import pandas as pd
  import numpy as np
  import nltk
  nltk.download('punkt')
  from nltk.corpus import stopwords
  import string
  import matplotlib.pyplot as plt
  import seaborn as sns
  from sklearn.feature_extraction.text import TfidfVectorizer
except ImportError:
  pass

#the return has the cosine similarity in essense
def compute_similarity(a, b):
   # For now we have only the english text 
  en_stop=stopwords.words('english')
  #the preprocess is currently with the nltk quick and agile. It is not custimizable but it is what we need right now
  vectorizer = TfidfVectorizer(tokenizer=preprocess, stop_words=en_stop)
  tfidf = vectorizer.fit_transform([a, b])
  return ((tfidf * tfidf.T).toarray())[0,1]
def preprocess(text):
  remove_punctuation_map = dict((ord(char), None) for char in string.punctuation)
  return nltk.word_tokenize(text.lower().translate(remove_punctuation_map))