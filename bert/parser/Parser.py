import requests
import urllib3
from bs4 import BeautifulSoup
import pandas as pd
from bert.parser.get_user_agent import get_useragent
import re
from pickle import FALSE
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import browser_cookie3
from factualweb.settings import ISALLOWED_TOKENS
from fake_headers import Headers
import time #giorgos_ster
import concurrent.futures, requests
# disable warnings for insecure requests
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Every 3-4 sessions open it
# Import ips kai vazo kai user agents kai den me anagnorizei
class ChromeSocket():
    def __init__(self):
        self.session=requests.Session()
        self.session.verify = False
        self.session.trust_env = False
        headers= Headers(
        # generate any browser & os headeers
        headers=False  # don`t generate misc headers
    )
        self.header=headers.generate()
        self.cookies = browser_cookie3.chrome()
    def get_text(self, url):
        try:
            r = self.session.get(url,headers=self.header ,allow_redirects=False ,cookies=self.cookies, timeout=15)
        except requests.exceptions.InvalidHeader:
            headers=get_useragent()
        r = self.session.get(url,headers=self.header ,allow_redirects=False ,cookies=self.cookies, timeout=15)
        _encoding = BeautifulSoup(r.text, "html5lib")
        return _encoding
    def g_search(self, url):
        links=[]
        options = Options()
        options.add_argument("--headless=new")
        driver = webdriver.Chrome(options)
        driver.get(url)
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        search=soup.find_all('div', class_="yuRUbf")
        links.append([i.a.get('href') for i in search])
        return links

# Generates a list of lists (pages of urls)
def results(query,n_pages):
    for page in range(1, n_pages):
        search_url ='https://www.google.com/search?q='+str(re.sub(r"([^a-zA-Z0-9])", ' ',str(query))).replace(" ", "+")+ "&start=" +str((page - 1) * 10)
        links=ChromeSocket.g_search(search_url)
    return links

class Parse():
    def __init__(self, query, etl):
        # Specify number of pages on google search, each page contains 10 #links
        self.etl=etl
        self.query=query
    def isallowed(self, webtext):
        pass
    def fetch_and_process_url(self, url):
        try:
            soup = ChromeSocket.get_text(url)
            webtext = ''
            for each in soup.find_all('p'):
                webtext += ' ' + each.text
            return [self.etl(webtext).preprocess()]
        except requests.exceptions.ReadTimeout:
            return ''
    def text(self):
        start_time = time.time()
        links = [link for page in results(self.query, n_pages=3) for link in page]
        print(f"Article scraping collection execution time: {time.time() - start_time} seconds")

        # Use ThreadPoolExecutor to process URLs in parallel
        with concurrent.futures.ThreadPoolExecutor() as executor:
            # Schedule the execution of fetch_and_process_url for each URL
            future_to_url = {executor.submit(self.fetch_and_process_url, url): url for url in links}
            # Collect the results as they complete
            text = []
            for future in concurrent.futures.as_completed(future_to_url):
                url = future_to_url[future]
                try:
                    result = future.result()
                    text.append(result)
                except Exception as exc:
                    print(f"{url} generated an exception: {exc}")
                    text.append('')

        print(f"Total execution time: {time.time() - start_time} seconds")
        return text, links

    '''
    def text(self):
        links=[]
        start_time = time.time()
        links=([link for page in results(self.query, n_pages=3) for link in page])
        end_time = time.time()
        print(f"Execution time: {end_time - start_time} seconds") #23-24s
        # test here
        text = [] # Initiate empty list to capture final results
        for url in links:
            # For each link, initiate new socket? Not possible google blocks us
            # HEADLESS SELENIUM OPTIONS
            try:
                soup=ChromeSocket(url)[0]
                webtext = ''
                for each in soup.find_all('p'):
                    webtext = webtext + ' ' + each.text
                text.append([self.etl(webtext).preprocess()])
            except requests.exceptions.ReadTimeout:
                text.append('')
        second_end_time = time.time()
        print(f"Execution time 2: {second_end_time - start_time} seconds") #220-240s
        return text, links

    '''
    # Get the links as well as the titles of each link#
    def urls(self):
        url_name = []
        url_link = []
        for link in self._encoding.find_all("div", class_="BNeawe s3v9rd AP7Wnd"):
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
    
