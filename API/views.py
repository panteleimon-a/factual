from bert.API.tf_in_use import * 
import pandas as pd
from API.apps import ApiConfig
from rest_framework.views import APIView
from rest_framework.response import Response

# Create your views here.

class match:
    def __init__(self, URL, Probability):
        self.URL= URL
        self.Probability= Probability

class twitter_API(APIView):
    def make_clickable(link):
        # target _blank to open new window
        # extract clickable text to display for your link
        text = link.split('=')[0]
        return f'<a target="_blank" href="{link}">{text}</a>'
    
    def post(self, request):
        data=request.data
        query = etl(data["text/URL"]).preprocess()
        textAns = prod(query, model=ApiConfig.model, tokenizer=ApiConfig.tokenizer).comparison_list()
        df=pd.DataFrame({'sources':[i for i in textAns["URL"]], 'factual index': [i for i in textAns["Probability"]]})

        # link is the column with hyperlinks
        df.style.format({'URL': self.make_clickable})
        df_dict=df.to_dict('records')
        return Response(df_dict, status=200)