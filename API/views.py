from bert.API.main import comparison_list
import json
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
    def post(self, request):
        context={}
        data=request.data
        query = data["text/URL"]
        '''if gender == 'Male':
            gender = 0
        elif gender == 'Female':
            gender = 1
        else:
            return Response("Gender field is invalid", status=400)
        '''

        textAns = comparison_list(query, model=ApiConfig.model, tokenizer=ApiConfig.tokenizer)
        # json_records = textAns.reset_index().to_json()
        # jsonify
        # arr=[]
        # arr= json.loads(json_records)
        # context["text"]= textAns.reset_index() #textAns.to_html()
        # jsonify
        df=pd.DataFrame({'sources':[i for i in textAns["URL"]], 'factual index': [i for i in textAns["Probability"]]})
        df_dict=df.to_dict('records')
        return Response(df_dict, status=200)