##################### TF IDF (the LDA is ready, not added yet :@) ############################
#import what you need
#In the perfect universe we would have this code in a different .py but this is not the perfect universe. At least not yet
# !python3 -m venv ~/venv-metal                                             
# !source ~/venv-metal/bin/activate
# !pip install -r requirements.txt
import tensorflow as tf
from pickle import FALSE
import pandas as pd
from bert.parser.Parser import Parse
import nltk
nltk.download('punkt')
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer

# Our precious sentiment analysis
def get_sent(senttext, model, tokenizer):
  tf_batch = tokenizer(senttext, max_length=128, padding=True, truncation=True, return_tensors='tf')
  tf_outputs = model(tf_batch)
  tf_predictions = tf.nn.softmax(tf_outputs["logits"][0], axis=-1)
  return tf_predictions.numpy()[1]

class prod:
  def __init__(self, query, model, tokenizer, etl):
    self.en_stop=stopwords.words('english')
    self.etl=etl
    self.Parse=Parse
    self.query=query
    self.model=model
    self.tokenizer=tokenizer
  def compute_similarity(self, b):
    # Cosine similarity
    # We preprocess both a and b, so no need for a preprocess step in the tokenizer, like etl.proprocess
    vectorizer = TfidfVectorizer(tokenizer=lambda i:i, lowercase=False) #tokenizer=self.preprocess
    b=self.etl(b).preprocess()
    tfidf = vectorizer.fit_transform([self.query, b])
    return ((tfidf * tfidf.T).toarray())[0,1]
  
  #This will return a list (not yet but close) of the sources and the score or similarity (words and sentiment)
  def comparison_list(self):
    init=self.Parse(self.query, self.etl)
    links=init.links
    articles=init.text()
    querysent=get_sent(self.query,self.model,self.tokenizer)
    simlist=[]
    sentlist=[]
    valid_urls=[]
    j=0
    for i in articles:
      # Was articles[i]*1.25
      sim=self.compute_similarity(self.query,articles[i])
      if sim!=0:
        sentsimilarity=1-abs(get_sent(i,self.model,self.tokenizer)-querysent)
        simlist.append(sim)
        sentlist.append(sentsimilarity)
        valid_urls.append(links[j])
      res_list={'URL':valid_urls, 'Probability':[sim[l]*sentlist[l] for l in range(len(sim))]}
      j+=1
    return pd.DataFrame(res_list)