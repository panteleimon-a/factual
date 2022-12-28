
import requests

URL1 = "https://edition.cnn.com/2022/12/09/europe/russia-putin-nuclear-weapons-intl/index.html"

from bs4 import BeautifulSoup

import pandas as pd

import random
proxies = ['66.42.53.233:8000',
 '85.193.92.239:8118',
 '177.82.85.209:3128',
 '201.229.250.19:8080',
 '41.169.72.4:8090',
 '118.27.113.167:8080',
 '45.42.177.99:3128',
 '23.109.172.148:9090',
 '179.96.28.58:80',
 '13.114.216.75:80',
 '147.139.182.91:3128',
 '112.217.162.5:3128',
 '205.185.126.246:3128',
 '49.0.2.242:8090',
 '208.82.61.75:3128',
 '20.210.26.214:3128',
 '200.105.215.22:33630',
 '5.253.16.131:9000',
 '188.166.176.202:8080',
 '45.42.177.39:3128',
 '51.159.115.233:3128',
 '107.172.73.179:7890',
 '18.159.181.93:8088',
 '51.79.50.22:9300',
 '140.227.25.191:23456',
 '182.18.83.42:7777',
 '183.221.242.103:9443',
 '41.33.47.146:1976',
 '34.146.19.255:3128',
 '158.69.71.245:9300',
 '190.61.88.147:8080',
 '45.92.94.190:9090',
 '185.217.137.216:1337',
 '123.240.60.64:8888',
 '89.37.4.82:80',
 '157.230.241.133:33273',
 '187.130.139.197:8080',
 '198.59.191.234:8080',
 '86.106.181.220:18379',
 '134.238.252.143:8080',
 '139.59.59.122:8118',
 '37.77.134.218:80',
 '47.57.233.110:808',
 '47.241.189.54:3127',
 '103.161.170.253:10007',
 '213.32.75.88:9300',
 '102.130.192.231:8080',
 '153.126.179.216:8080',
 '89.107.197.165:3128',
 '47.243.121.74:3128',
 '5.189.184.6:80',
 '188.0.147.102:3128',
 '47.74.226.8:5001',
 '35.200.4.163:3128',
 '91.185.20.162:3128',
 '185.39.50.2:1337',
 '45.8.179.242:1337',
 '213.230.97.98:3128',
 '45.8.179.241:1337',
 '116.202.22.13:3128',
 '103.29.185.54:8181',
 '149.129.223.129:3128',
 '35.221.99.16:9090',
 '185.217.137.241:1337',
 '158.69.53.98:9300',
 '164.68.124.245:80',
 '181.113.135.254:52058',
 '103.16.224.174:10000',
 '41.65.252.101:1976',
 '144.217.7.157:9300',
 '116.96.121.84:4003',
 '185.217.137.242:1337',
 '51.38.28.127:80',
 '190.45.251.189:3128',
 '47.241.165.133:443',
 '52.68.211.124:3128',
 '123.182.59.125:8089',
 '101.52.251.186:8080',
 '111.225.153.94:8089',
 '103.16.214.219:10000',
 '216.215.123.174:8080',
 '80.252.5.34:7001',
 '137.184.1.39:8000',
 '118.31.2.38:8999',
 '103.148.209.141:8282',
 '37.32.8.192:80',
 '59.15.154.69:13128',
 '185.231.183.217:1080',
 '103.160.2.43:10000',
 '167.114.96.27:9300',
 '148.251.150.106:3128',
 '103.180.139.244:10003',
 '137.184.151.220:443',
 '43.132.187.4:9002',
 '147.135.134.57:9300',
 '3.73.112.114:80',
 '103.16.214.132:10000',
 '162.155.10.150:55443',
 '113.252.11.250:8118',
 '103.183.121.100:10000']


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
            # break
          # If the request failed, continue to the next proxy
          # except:
            # continue
            self._encoding = BeautifulSoup(req.text,'html.parser')
        
    # Get the text from the page#
    def text(self):
        webtext = ''
        for text in self._encoding.find_all('p'):
            webtext = webtext + ' ' + text.text
        return webtext[1:]

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

    # Get the h1 titles from the page (main title), the h2 titles (contents) and the div title (probably the same as the h1)#
    def titles(self, h):
        htext = []
        '''
        Titles according to h:
        '''
        #h1 title
        if h == 1:
            for text in self._encoding.find_all('h1'):
                #error exception in case there is no title
                htext.append(text.text)
        #h2 titles
        elif h == 2:
            for text in self._encoding.find_all('h2'):
                #error exception in case there is no title
                htext.append(text.text)
        #div title
        elif h == 0:
            #error exception in case there is no title
            htext = self._encoding.title.string
        else:
            raise ValueError('Represents h1 or h2 (gets only 1,2 as values for the headers and 0 for the title)')
        return htext

    #Get the date of the article (if it exists)
    def date(self):
        meta = self._encoding.find_all('meta')
        published_date = []
        modified_date = []
        #meta should be global function
        '''
        Many pages use meta tags for dates, authors and keywords. Assuming that the property of the date meta tag, will contain
        the word 'published' and 'modified' we use it as a leverage to fetch the date.
        '''
        for tag in meta:
            if 'property' in tag.attrs.keys():
                if tag.attrs['property'].strip().lower().find('published') > 0:
                    published_date.append(tag.attrs['content'])
                elif tag.attrs['property'].strip().lower().find('modified') > 0:
                    modified_date.append(tag.attrs['content'])
        return published_date, modified_date
    

    def tags(self):
        meta = self._encoding.find_all('meta')
        tag_name = []
        tag_content = []
        for tag in meta:
            if 'name' in tag.attrs.keys() and tag.attrs['name'].strip().lower() in ['description', 'keywords']:
                tag_name.append(tag.attrs['name'].lower())
                tag_content.append(tag.attrs['content'])
        tag_list = list(map(list, zip(*[tag_name, tag_content])))
        tag_df = pd.DataFrame(tag_list)
        return tag_df

    def author(self):
        authordivs = []
        tags = {tag.name for tag in self._encoding.find_all()}
        class_list = set()
        # iterate all tags
        for tag in tags:
            # find all elements of tag
            for i in self._encoding.find_all(tag):
                # if tag has attribute of class
                if i.has_attr("class"):
                    if len(i['class']) != 0:
                        class_list.add(" ".join(i['class']))

        for i in class_list:
            if i.find('author') > -1 or i.find('writer') > -1 or i.find('journalist') > -1:
                authordivs.append(i)
        authorcontent = []
        for i in authordivs:
            try:
                div = self._encoding.find("div", {"class": i})
                authorcontent.append(div.text)
            except AttributeError:
                pass
        return authorcontent


##TEST##

text = fetch(URL1).text()
title0 = fetch(URL1).titles(0)
title1 = fetch(URL1).titles(1)
title2 = fetch(URL1).titles(2)
date = fetch(URL1).date()
tags = fetch(URL1).tags()
urls = fetch(URL1).urls()
author = fetch(URL1).author()

text =fetch(URL1).text()
title0=fetch(URL1).titles(0)
urls =fetch(URL1).urls()

import re

searchlink='https://www.google.com/search?q='+str(re.sub(r"([^a-zA-Z0-9])", ' ',title0)).replace(" ", "+")

print(searchlink)

searchfetch=fetch(searchlink).urls()

print(searchfetch)

from pickle import FALSE
# news=pd.DataFrame(columns=['Source','Text'])
newsdict={}
for i in range(0,len(searchfetch)-1):
  link=searchfetch[1][i]
  if link[0:4]=='/url':
    newslink='http'+re.findall('http(.*)',link)[0]
    # 'www.google.com'+link
    print(newslink)
    # print(type(newslink))
    # print(link)
    newssource = re.search('https?://([A-Za-z_0-9.-]+).*', link)
    if newssource:
      a=newssource.group(1)
    if not (re.search('google', a)!=None or re.search('twitter', a)!=None):
      newsdict[a]=fetch(newslink).text()
print(newsdict)

len(newsdict)
newsdf=pd.DataFrame.from_dict(newsdict.items())
newsdf.columns = ['Source', 'text']
print(newsdf)

import os
import numpy as np
import tqdm
from gensim.models import FastText
from gensim.models.phrases import Phrases, Phraser
from gensim.parsing.preprocessing import remove_stopwords, strip_punctuation, strip_non_alphanum
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

!python -m spacy download en_core_web_md
import spacy
from spacy.lang.en import English
from spacy import displacy
nlp = spacy.load('en_core_web_md')

#creates a list of documents with a list of words inside:
text = []
for i in newsdf.text.values:
  doc = nlp(remove_stopwords(strip_punctuation(strip_non_alphanum(str(i).lower()))))
  tokens = [token.text for token in doc]
  text.append(tokens)


common_terms = ["of", "with", "without", "and", "or", "the", "a"]
# Create the relevant phrases from the list of sentences:
phrases = Phrases(text, common_terms=common_terms, threshold = 10, min_count=5)
# The Phraser object is used from now on to transform sentences
bigram = Phraser(phrases)
# Applying the Phraser to transform our sentences is simply
tokens = list(bigram[text])
print(tokens)

import subprocess
import sys
sys.path.append("/usr/local/lib/python3.7/dist-packages")
def install(package):
 subprocess.check_call([sys.executable, "-m", "pip", "install", package])
install("fasttext")
import fasttext
model = FastText(tokens, size=4, window=4, min_count=1, iter=4, sorted_vocab=1)

#TF-IDF # needs a list of lists for words and docs along with a fasttext 'model'
text = []
for i in tokens:
  string = ' '.join(i)
  text.append(string)
tf_idf_vect = TfidfVectorizer(stop_words=None)
final_tf_idf = tf_idf_vect.fit_transform(text)
tfidf_feat = tf_idf_vect.get_feature_names_out()

tfidf_sent_vectors = []; # the tfidf-w2v for each sentence/review is stored in this list
row=0;
errors=0
for sent in tokens: # for each review/sentence
    # print(sent)
    sentvec = np.zeros(20) # as word vectors are of zero length
    weightsum =0; # num of words with a valid vector in the sentence/review
    # if sent!=[]:
    for word in sent: # for each word in a review/sentence
        # print(word)
        # try:
        # if True: 
            vec = model.wv[word]
            # print(len(vec))
            # print(len(sentvec))
            # obtain the tf_idfidf of a word in a sentence/review
            tfidf = final_tf_idf [row, np.where(tfidf_feat==word)[0]] #tfidf_feat.index(word)]
            # print(tfidf)
            # print(tfidf.toarray())
            if tfidf.toarray()!=[]:
              tfnum = tfidf.toarray()[0][0]
              print(vec)
              sentvec += (vec * tfnum)
              weightsum += tfnum
            # print(tfidf)
        # except:
            # errors =+1
            # pass
    sent_vec /= weight_sum
    #print(np.isnan(np.sum(sent_vec)))
    # print(sent_vec)
    tfidf_sent_vectors.append(sent_vec)
    row += 1
print(tfidf_sent_vectors)
# print('errors noted: '+str(errors))
