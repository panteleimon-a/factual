import os
import requests
from django.conf import settings
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import status
from bert.API.etl import etl
from bert.API.tf_in_use import prod
from API.apps import ApiConfig


class SearchView(APIView):
    """
    Original search view for fact-checking.
    """
    def make_clickable(link):
        # target _blank to open new window
        # extract clickable text to display for your link
        text = link.split('=')[0]
        return f'<a target="_blank" href="{link}">{text}</a>'

    def post(self, request):
        data = request.data
        query = data.get("text/URL")
        if not query:
            return Response({"error": "text/URL field is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        query = etl(query).preprocess()
        df = prod(query, model=ApiConfig.model, tokenizer=ApiConfig.tokenizer, etl=etl).comparison_list()
        # link is the column with hyperlinks
        df.style.format({'URL': self.make_clickable})
        df['Match'] = df['Match'].map('{:.2%}'.format)
        df_dict = df.to_dict('records')
        return Response(df_dict, status=status.HTTP_200_OK)


class FactualProxyView(APIView):
    """
    Low-level proxy endpoint for Factual API.
    Forwards requests to the external Factual API.
    Endpoint: /api/factual/<endpoint>
    """
    def post(self, request, endpoint):
        # Get the Factual API key from settings
        api_key = getattr(settings, 'FACTUAL_API_KEY', None)
        if not api_key:
            return Response(
                {"error": "Factual API key not configured"},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        
        # Forward the request to the actual Factual API
        # Note: Adjust the base URL based on the actual Factual API endpoint
        factual_base_url = "https://api.factual.com"  # Update with actual URL
        url = f"{factual_base_url}/{endpoint}"
        
        try:
            headers = {
                'Authorization': f'Bearer {api_key}',
                'Content-Type': 'application/json'
            }
            
            response = requests.post(
                url,
                json=request.data,
                headers=headers,
                timeout=30
            )
            
            return Response(response.json(), status=response.status_code)
        except requests.exceptions.RequestException as e:
            return Response(
                {"error": f"Failed to connect to Factual API: {str(e)}"},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )


class AnalyzeAndMatchView(APIView):
    """
    High-level endpoint that analyzes text using external sentiment model
    and matches it against factual sources.
    Endpoint: /api/analyze-and-match/
    
    This endpoint:
    1. Calls the external finetuned binary word-level sentiment model
    2. Uses the analysis results to perform fact-checking
    """
    def post(self, request):
        text = request.data.get("text")
        if not text:
            return Response(
                {"error": "text field is required"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get the external model API URL from settings
        model_api_url = getattr(settings, 'MODEL_API_URL', None)
        model_api_key = getattr(settings, 'MODEL_API_KEY', None)
        
        if not model_api_url:
            return Response(
                {"error": "External model API not configured. Please set MODEL_API_URL in environment variables."},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        
        try:
            # Step 1: Call the external sentiment model
            headers = {'Content-Type': 'application/json'}
            if model_api_key:
                headers['Authorization'] = f'Bearer {model_api_key}'
            
            model_response = requests.post(
                model_api_url,
                json={"text": text},
                headers=headers,
                timeout=30
            )
            
            if model_response.status_code != 200:
                return Response(
                    {"error": "External model API returned an error", "details": model_response.text},
                    status=status.HTTP_503_SERVICE_UNAVAILABLE
                )
            
            sentiment_data = model_response.json()
            
            # Step 2: Use the sentiment analysis to perform fact-checking
            # Process the text through the existing ETL and comparison pipeline
            processed_query = etl(text).preprocess()
            df = prod(processed_query, model=ApiConfig.model, tokenizer=ApiConfig.tokenizer, etl=etl).comparison_list()
            df['Match'] = df['Match'].map('{:.2%}'.format)
            matches = df.to_dict('records')
            
            # Step 3: Combine results
            result = {
                "sentiment_analysis": sentiment_data,
                "fact_check_matches": matches,
                "text": text
            }
            
            return Response(result, status=status.HTTP_200_OK)
            
        except requests.exceptions.RequestException as e:
            return Response(
                {"error": f"Failed to connect to external model API: {str(e)}"},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        except Exception as e:
            return Response(
                {"error": f"An error occurred during analysis: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


    