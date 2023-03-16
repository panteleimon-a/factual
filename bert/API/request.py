#In the perfect universe we would have this code in a different .py but this is not the perfect universe. At least not yet
try:
    import requests
    from bs4 import BeautifulSoup
    import pandas as pd
    import random
    import urllib.request
    from urllib.parse import urlparse
    from tf_in_use import compute_similarity
except ImportError:
    pass    

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
#             self._pic_encoding = BeautifulSoup(req.text,'html.parser',from_encoding=response.info().get_param('charset'))
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
  
