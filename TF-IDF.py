import requests
from bs4 import BeautifulSoup
import pandas as pd
import re
from pickle import FALSE
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
def search_preptext(self,text):
  searchpreptext='https://www.google.com/search?q='+str(text).replace(" ", "+")
  return searchpreptext
def search_text(self,text):
  searchtext='https://www.google.com/search?q='+str(re.sub(r"([^a-zA-Z0-9])", ' ',title0)).replace(" ", "+")
  return searchtext

############TF-IDF vectors#####################
# needs a list of lists for words and docs along with a fasttext 'model'
# text = []
# for i in tokens:
#   string = ' '.join(i)
#   text.append(string)
# tf_idf_vect = TfidfVectorizer(stop_words=None)
# final_tf_idf = tf_idf_vect.fit_transform(text)
# tfidf_feat = tf_idf_vect.get_feature_names_out()

#####################TFIDF model##########################################
def tfidfscore(self, tokens, tweet_text):
  text = []
  for i in tokens:
      string = ' '.join(i)
      text.append(string)
  tf_idf_vect = TfidfVectorizer(stop_words=None)
  tfidf_feat = tf_idf_vect.get_feature_names_out()
  final_tf_idf = tf_idf_vect.fit_transform(text)
  tfidf_sent_vectors = []; # the tfidf-fasttext for each sentence/review is stored in this list
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
              vec = ft.get_word_vector(word)
              # for w2v: vec = model[word].wv

              # obtain the tf_idfidf of a word in a sentence/review
              tfidf = final_tf_idf [row, np.where(tfidf_feat==word)[0]] #tfidf_feat.index(word)]


              if tfidf.toarray()!=[]:
                tfnum = tfidf.toarray()[0][0]
                print(vec)
                sentvec += (vec * tfnum)
                weightsum += tfnum
          # except:
              # errors =+1
              # pass
      sent_vec /= weight_sum
      #print(np.isnan(np.sum(sent_vec)))
      # print(sent_vec)
      tfidf_sent_vectors.append(sent_vec)
      row += 1
  # print(tfidf_sent_vectors)
  # print('errors noted: '+str(errors))
  # join the cosine distance vectors back to the dataframe:
  query = np.array(list(tweet_text))
  query = np.nan_to_num(query)
  vectors = np.array(list(tfidf_sent_vectors))
  vectors = np.nan_to_num(vectors)
  cosine_similarities = pd.Series(cosine_similarity(query, vectors).flatten())
  return cosine_similarities


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
newsdf=pd.DataFrame.from_dict(newsdict.items())
newsdf.columns = ['Source', 'text']
newsdf['FT_tfidf'] = cosine_similarities
