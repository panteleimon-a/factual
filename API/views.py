from bert.API.etl import etl
from bert.API.tf_in_use import prod
from API.apps import ApiConfig
from rest_framework.response import Response
from rest_framework.views import APIView
# Create your views here.

class match:
    def __init__(self, URL, Probability):
        self.URL= URL
        self.Probability= Probability
class SearchView(APIView):
    def make_clickable(link):
        # target _blank to open new window
        # extract clickable text to display for your link
        text = link.split('=')[0]
        return f'<a target="_blank" href="{link}">{text}</a>'
    def post(self, request):
        data=request.data
        query = data["text/URL"]
        query=etl(query).preprocess()
        df = prod(query, model=ApiConfig.model, tokenizer=ApiConfig.tokenizer, etl=etl).comparison_list()
        # link is the column with hyperlinks
        df.style.format({'URL': self.make_clickable})
        df['Match'] = df['Match'].map('{:.2%}'.format)
        df_dict=df.to_dict('records')
        return Response(df_dict, status=200)


    