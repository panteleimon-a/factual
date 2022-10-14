import requests
from bs4 import BeautifulSoup
import pandas as pd
URL = "https://www.forbes.com/sites/siladityaray/2022/10/14/food-giant-danone-to-exit-russia-taking-a-nearly-1-billion-hit/?sh=6cc27cca796f"
'''
URL test
'''
# req = requests.get(URL)
# print(req.content)

'''
Parser class fetch
'''
class fetch:
    def __init__(self, url):
        req = requests.get(URL)
        self._encoding = BeautifulSoup(req.text, 'html.parser')
        
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
            # find all element of tag
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

text = fetch(URL).text()
title0 = fetch(URL).titles(0)
title1 = fetch(URL).titles(1)
title2 = fetch(URL).titles(2)
date = fetch(URL).date()
tags = fetch(URL).tags()
urls = fetch(URL).urls()
author = fetch(URL).author()
