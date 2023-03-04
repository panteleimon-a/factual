#newBert_newMe
import torch
!pip install transformers
import tensorflow as tf
import pandas as pd
from transformers import BertTokenizer, TFBertForSequenceClassification
from transformers import InputExample, InputFeatures

model = TFBertForSequenceClassification.from_pretrained("bert-base-uncased")
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
model.summary()
URL = "https://ai.stanford.edu/~amaas/data/sentiment/aclImdb_v1.tar.gz"

dataset = tf.keras.utils.get_file(fname="aclImdb_v1.tar.gz",origin=URL,untar=True,cache_dir='.',cache_subdir='')
# dataset = tf.keras.utils.get_file(fname="trainingtweet.csv",origin=path,untar=False,cache_dir='.',cache_subdir='')
# The shutil module offers a number of high-level 
# operations on files and collections of files.
import tensorflow as tf
import pandas as pd
from transformers import BertTokenizer, TFBertForSequenceClassification
from transformers import InputExample, InputFeatures
import os
import shutil
# Create main directory path ("/aclImdb")
main_dir = os.path.join(os.path.dirname(dataset), 'aclImdb')
# main_dir = os.path.join(path,"trainingtweet.csv")
# Create sub directory path ("/aclImdb/train")
train_dir = os.path.join(main_dir, 'train')
# Remove unsup folder since this is a supervised learning task
remove_dir = os.path.join(train_dir, 'unsup')
shutil.rmtree(remove_dir)
# View the final train folder
print(os.listdir(train_dir))

# We create a training dataset and a validation 
# dataset from our "aclImdb/train" directory with a 80/20 split.
train = tf.keras.preprocessing.text_dataset_from_directory(
    './aclImdb/train', batch_size=30000, validation_split=0.2, 
    subset='training', seed=123)
test = tf.keras.preprocessing.text_dataset_from_directory(
    './aclImdb/train', batch_size=30000, validation_split=0.2, 
    subset='validation', seed=123)

for i in train.take(1):
  train_feat = i[0].numpy()
  train_lab = i[1].numpy()

train = pd.DataFrame([train_feat, train_lab]).T
train.columns = ['DATA_COLUMN', 'LABEL_COLUMN']
train['DATA_COLUMN'] = train['DATA_COLUMN'].str.decode("utf-8")
train.head()

for j in test.take(1):
  test_feat = j[0].numpy()
  test_lab = j[1].numpy()

test = pd.DataFrame([test_feat, test_lab]).T
test.columns = ['DATA_COLUMN', 'LABEL_COLUMN']
test['DATA_COLUMN'] = test['DATA_COLUMN'].str.decode("utf-8")
test.head()

InputExample(guid=None,
             text_a = "Hello, world",
             text_b = None,
             label = 1)

def convert_data_to_examples(train, test, DATA_COLUMN, LABEL_COLUMN): 
  train_InputExamples = train.apply(lambda x: InputExample(guid=None,text_a = x[DATA_COLUMN],text_b = None,label = x[LABEL_COLUMN]),axis = 1)
  validation_InputExamples = test.apply(lambda x: InputExample(guid=None,text_a = x[DATA_COLUMN],text_b = None,label = x[LABEL_COLUMN]),axis = 1)
  return train_InputExamples, validation_InputExamples

  train_InputExamples, validation_InputExamples = convert_data_to_examples(train,test,'DATA_COLUMN','LABEL_COLUMN')
  
def convert_examples_to_tf_dataset(examples, tokenizer, max_length=128):
    features = [] # -> will hold InputFeatures to be converted later
    for e in examples:
        # Documentation is really strong for this method, so please take a look at it
        input_dict = tokenizer.encode_plus(
            e.text_a,
            add_special_tokens=True,
            max_length=max_length, # truncates if len(s) > max_length
            return_token_type_ids=True,
            return_attention_mask=True,
            pad_to_max_length=True, # pads to the right by default # CHECK THIS for pad_to_max_length
            truncation=True
        )
        input_ids, token_type_ids, attention_mask = (input_dict["input_ids"],
            input_dict["token_type_ids"], input_dict['attention_mask'])
        features.append(
            InputFeatures(
                input_ids=input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids, label=e.label
            )
        )
    def gen():
        for f in features:
            yield (
                {
                    "input_ids": f.input_ids,
                    "attention_mask": f.attention_mask,
                    "token_type_ids": f.token_type_ids,
                },
                f.label,
            )
    return tf.data.Dataset.from_generator(
        gen,
        ({"input_ids": tf.int32, "attention_mask": tf.int32, "token_type_ids": tf.int32}, tf.int64),
        (
            {
                "input_ids": tf.TensorShape([None]),
                "attention_mask": tf.TensorShape([None]),
                "token_type_ids": tf.TensorShape([None]),
            },
            tf.TensorShape([]),
        ),
    )

DATA_COLUMN = 'DATA_COLUMN'
LABEL_COLUMN = 'LABEL_COLUMN'

train_InputExamples, validation_InputExamples = convert_data_to_examples(train, test, DATA_COLUMN, LABEL_COLUMN)

train_data = convert_examples_to_tf_dataset(list(train_InputExamples), tokenizer)
train_data = train_data.shuffle(100).batch(32).repeat(2)

validation_data = convert_examples_to_tf_dataset(list(validation_InputExamples), tokenizer)
validation_data = validation_data.batch(32)

model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=3e-5, epsilon=1e-08, clipnorm=1.0),loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),metrics=[tf.keras.metrics.SparseCategoricalAccuracy('accuracy')])
#This should take time. You can run it in VS and stop it after 20 hours. This way it won't run forever. Stopping it manually will not interfere with the model
#proceed after doing your due diligence; this will eat up your ram!
model.fit(train_data, epochs=2, validation_data=validation_data)

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
  
#In the perfect universe we would have this code in a different .py but this is not the perfect universe. At least not yet


import requests
from bs4 import BeautifulSoup
import pandas as pd
import random
import urllib.request
from urllib.parse import urlparse
def get_useragent():
 useragent_list = [
 "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13",
 "Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13",
 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13",
 "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13",
 "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1284.0 Safari/537.13",
 "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.6 Safari/537.11" ]
 return random.choice(useragent_list)

class fetch:
    def __init__(self, url):
        # for proxy in proxies:
          # try:
            req = requests.get(
            url=url,
            headers={"User-Agent": get_useragent()}
            # ,proxies={'http': proxy, 'https': proxy}
            )
            soup = BeautifulSoup(response,'html.parser',from_encoding=req)
            # break
          # If the request failed, continue to the next proxy
          # except:
            # continue
            self._encoding = BeautifulSoup(req.text,'html.parser')
            self._pic_encoding = BeautifulSoup(req.text,'html.parser',from_encoding=response.info().get_param('charset'))
    # Get the text from the page#
    def text(self):
        webtext = ''
        for text in self._encoding.find_all('p'):
            webtext = webtext + ' ' + text.text
        return webtext[1:]
   # def pics(self):
   #   meta = self._encoding.find_all('img')
   #   imglinks=[]
   #   for img in meta:
   #     imglinks.append(img.get('src'))
   #   return imglinks
    def titles(self, h):
        htext = []
        if h == 1:
            for text in self._encoding.find_all('h1'):
                htext.append(text.text)
        elif h == 2:
            for text in self._encoding.find_all('h2'):
                htext.append(text.text)
        elif h == 0:
            htext = self._encoding.title.string
        else:
            raise ValueError('Represents h1 or h2 (gets only 1,2 as values for the headers and 0 for the title)')
        return htext
    # Get the links as well as the titles of each link#
    def urls(self):
        url_name = []
        url_link = []
        for link in self._encoding.find_all('a'):
            url_name.append(link.text)
            url_link.append(link.get('href'))
        url_list = list(map(list, zip(*[url_name, url_link])))
        url_df = pd.DataFrame(url_list)
        return url_df
  
#### Watch out here, python will ask you for a query

import re
query=input("query")
searchlink='https://www.google.com/search?q='+str(re.sub(r"([^a-zA-Z0-9])", ' ',query)).replace(" ", "+")

print(searchlink)
# This will fetch the urls from the searchlink (which effectively searches google) - This works untill it won't Google change things. We have to be wary
searchfetch=fetch(searchlink).urls()
print(searchfetch)


#This will create the final dict with texts. For now we don't get any twitter or youtube links
from pickle import FALSE
# del len
# news=pd.DataFrame(columns=['Source','Text'])
newsdict={}
for i in range(0,len(searchfetch)-1):
  link=searchfetch[1][i]
  if link[0:4]=='/url':
    searchlink='http'+re.findall('http(.*)',link)[0]
    dumplink='&ved'+re.findall('&ved(.*)',link)[0]
    newslink=searchlink[0:len(searchlink)-len(dumplink)]
    # 'www.google.com'+link
    print(newslink)
    # print(type(newslink))
    # print(link)
    newssource = re.search('https?://([A-Za-z_0-9.-]+).*', link)
    if newssource:
      a=newssource.group(1)
    if not (re.search('google', a)!=None or re.search('twitter', a)!=None or re.search('youtube', a)!=None):
      newsdict[a]=fetch(newslink).text()
# print(newsdict)

# Our precious sentiment analysis
def get_sent(senttext):
  tf_batch = tokenizer(senttext, max_length=128, padding=True, truncation=True, return_tensors='tf')
  tf_outputs = model(tf_batch)
  tf_predictions = tf.nn.softmax(tf_outputs[0], axis=-1)
  return float(tf_predictions[0][1])
#This will return a list (not yet but close) of the sources and the score or similarity (words and sentiment)
maxsim=0
best=""
sum=0
length=0
sumsent=0
querysent=get_sent(query)
simlist=[]
sentlist=[]
for i in newsdict.keys():
  sim=compute_similarity(query,newsdict[i])*1.25
  if sim!=0:
    simlist.append(sim)
    sent=1-abs(get_sent(newsdict[i])-querysent)
    sentlist.append(sent)
  print(sim,sent)
  print(i)
print(querysent)


