##################### TF IDF (the LDA is ready, not added yet :@) ############################
#import what you need
try:
  #In the perfect universe we would have this code in a different .py but this is not the perfect universe. At least not yet
# !python3 -m venv ~/venv-metal                                             
# !source ~/venv-metal/bin/activate
# !pip install -r requirements.txt
  import tensorflow as tf
  from pickle import FALSE
  import pandas as pd
  from bert.parser.Parser import *
  import nltk
  nltk.download('punkt')
  from nltk.corpus import stopwords
  from bert.parser.Parser import *
  import string
  from sklearn.feature_extraction.text import TfidfVectorizer
except ImportError:
  pass

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

# Our precious sentiment analysis
def get_sent(senttext, model, tokenizer):
  tf_batch = tokenizer(senttext, max_length=128, padding=True, truncation=True, return_tensors='tf')
  tf_outputs = model(tf_batch)
  tf_predictions = tf.nn.softmax(tf_outputs["logits"][0], axis=-1)
  return tf_predictions.numpy()[1]

class prod:
  def __init__(self, query, model, tokenizer):
    self.en_stop=stopwords.words('english')
    self.Parse=Parse
    self.query=query
    self.model=model
    self.tokenizer=tokenizer
  def compute_similarity(self, a, b):
    # Cosine similarity
    # The preprocess is currently with the nltk quick and agile. It is not custimizable but it is what we need right now
    vectorizer = TfidfVectorizer(tokenizer=lambda i:i, stop_words=self.en_stop) #tokenizer=self.preprocess
    tfidf = vectorizer.fit_transform([a, b])
    return ((tfidf * tfidf.T).toarray())[0,1]
  
  #This will return a list (not yet but close) of the sources and the score or similarity (words and sentiment)
  def comparison_list(self):
    articles=self.Parse(self.query).text()
    urls=self.Parse(self.query).urls()
    querysent=get_sent(self.query,self.model,self.tokenizer)
    simlist=[]
    sentlist=[]
    valid_urls=[]
    sim=[]
    j=0
    for i in articles:
      sim.append(self.compute_similarity(self.query,articles[i]*1.25))
      if sim!=0:
        simlist.append(sim)
        sent=1-abs(get_sent(i,self.model,self.tokenizer)-querysent)
        sentlist.append(sent)
        valid_urls.append(urls[j])
      res_list={'URL':valid_urls, 'Probability':[sim[l]*sentlist[l] for l in range(len(sim))]}
      j+=1
    return pd.DataFrame(res_list)