##################### TF IDF (the LDA is ready, not added yet :@) ############################
#import what you need
#In the perfect universe we would have this code in a different .py but this is not the perfect universe. At least not yet
# !python3 -m venv ~/venv-metal                                             
# !source ~/venv-metal/bin/activate
# !pip install -r requirements.txt
import tensorflow as tf
from pickle import FALSE
import pandas as pd
from bert.parser.Parser import text
import nltk
nltk.download('punkt')
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer
# Library to sort similarity
from operator import itemgetter
# Import cosine similarity library
from sklearn.metrics.pairwise import linear_kernel

# Our precious sentiment analysis
def get_sent(senttext, model, tokenizer):
  tf_batch = tokenizer(senttext, max_length=128, padding=True, truncation=True, return_tensors='tf')
  tf_outputs = model(tf_batch)
  tf_predictions = tf.nn.softmax(tf_outputs["logits"][0], axis=-1)
  return tf_predictions.numpy()[1]

# Cosine similarity
# We preprocess both a and b, so no need for a preprocess step in the tokenizer, like etl.proprocess
def compute_similarity(query, b):
  vectorizer = TfidfVectorizer(tokenizer=lambda i:i, lowercase=False) #tokenizer=self.preprocess
  comp_lst=[query, b[0]]
  tfidf = vectorizer.fit_transform(comp_lst)
  cosine_similarities = linear_kernel(tfidf[0:1], tfidf).flatten()
  return cosine_similarities[1]
  
class prod:
  def __init__(self, query, model, tokenizer, etl):
    self.en_stop=stopwords.words('english')
    self.etl=etl
    self.query=query
    self.model=model
    self.tokenizer=tokenizer
  #This will return a list (not yet but close) of the sources and the score or similarity (words and sentiment)
  def comparison_list(self):
    articles,links=text(self.query,self.etl)
    querysent=get_sent(self.query,self.model,self.tokenizer)
    sentlist=[]
    valid_urls=[]
    sim=[]
    j=0
    # Was articles[i]*1.25
    for i in range(len(articles)):
      temp=(compute_similarity(self.query, articles[i])*1.25)
      # Take only non-empty/relevant articles
      if temp!=0 and articles[i][0]!=[]:
        sim.append(temp)
        sentsimilarity=1-abs(get_sent(articles[i][0] if not all(isinstance(i, type(list)) for i in articles[i]) else articles[i],self.model,self.tokenizer)-querysent)
        sentlist.append(sentsimilarity)
        valid_urls.append(links[j])
        j+=1
    # Final output section
    res_dic=[{'URL':valid_urls, 'Similarity Match':[sim[l] for l in range(len(valid_urls))], 'Sentiment Match':[sentlist[l] for l in range(len(valid_urls))]}]
    # Sort for similarity
    dic_sorted = sorted(res_dic, key=itemgetter('Similarity Match'), reverse=True)[0]
    match_score= [dic_sorted["Similarity Match"][i] * dic_sorted["Sentiment Match"][i] for i in range(len(sim))]
    out_dic={'URL':valid_urls, "Match": match_score}
    return pd.DataFrame(out_dic)