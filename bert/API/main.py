#In the perfect universe we would have this code in a different .py but this is not the perfect universe. At least not yet
# !python3 -m venv ~/venv-metal                                             
# !source ~/venv-metal/bin/activate
# !pip install -r requirements.txt
from tqdm import tqdm
import re
import pandas as pd
from urllib.parse import urlparse
from bert.API.tf_in_use import * 
from bert.parser.Parser import fetch
import tensorflow as tf
from pickle import FALSE
import pandas as pd


def links(query):
  searchlink='https://www.google.com/search?q='+str(re.sub(r"([^a-zA-Z0-9])", ' ',query)).replace(" ", "+")
  # This will fetch the urls from the searchlink (which effectively searches google) - This works untill it won't Google change things. We have to be wary
  searchfetch=fetch(searchlink).urls()
  urls=fetch(searchlink).urls()
  #This will create the final dict with texts. For now we don't get any twitter or youtube links
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
  return [newsdict,urls]

# Our precious sentiment analysis
def get_sent(senttext, model, tokenizer):
  tf_batch = tokenizer(senttext, max_length=128, padding=True, truncation=True, return_tensors='tf')
  tf_outputs = model(tf_batch)
  tf_predictions = tf.nn.softmax(tf_outputs["logits"][0], axis=-1)
  return tf_predictions.numpy()[1]

#This will return a list (not yet but close) of the sources and the score or similarity (words and sentiment)
def comparison_list(query,model,tokenizer):
  # Import time module
  #tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
  #tokenizer.save_pretrained("/Users/pante/Git_Repositories/factual/MVP/bert/tokenizer")
  #tokenizer= BertTokenizer.from_pretrained("/Users/pante/Git_Repositories/factual/MVP/bert/tokenizer")
  #model=tf.keras.models.load_model("/Users/pante/Git_Repositories/factual/MVP/bert/model")
  #import time
  # record start time
  #start = time.time()
  articles=links(query)
  newsdict=articles[1]
  querysent=get_sent(query,model,tokenizer)
  simlist=[]
  sentlist=[]
  valid_urls=[]
  sim=[]
  j=0
  for i in tqdm(newsdict[1]):
    sim.append(compute_similarity(query,newsdict[0][j])*1.25)
    if sim!=0:
      simlist.append(sim)
      sent=1-abs(get_sent(newsdict[0][j],model,tokenizer)-querysent)
      sentlist.append(sent)
      valid_urls.append(i)
    res_list={'URL':valid_urls, 'Probability':[sim[l]*sentlist[l] for l in range(len(sim))]}
    #end =time.time()
    #print("Time elapsed:", end-start)
    j+=1
  return pd.DataFrame(res_list)