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