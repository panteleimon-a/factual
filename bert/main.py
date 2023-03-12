#In the perfect universe we would have this code in a different .py but this is not the perfect universe. At least not yet
import requests
from bs4 import BeautifulSoup
import pandas as pd
import random
import urllib.request
from urllib.parse import urlparse
from tf_in_use import compute_similarity
from request import fetch, get_useragent

# Input query (GET request) / request in json format here
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