from pickle import FALSE
import nltk
nltk.download('punkt')
from nltk.corpus import stopwords
import string
import re
# Super important, think of adding stemming
# https://medium.com/@mifthulyn07/comparing-text-documents-using-tf-idf-and-cosine-similarity-in-python-311863c74b2c

class etl:
  def __init__(self, text):
    # For now we have only the english text 
    self.en_stop=stopwords.words('english')
    self.text=text
  def preprocess(self):
    remove_punctuation_map = dict((ord(char), None) for char in string.punctuation)
    new_text= nltk.word_tokenize(self.text.lower().translate(remove_punctuation_map))
    query= [word for word in new_text if word not in self.en_stop]
    return query