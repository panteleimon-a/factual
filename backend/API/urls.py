from django.urls import path
from API.views import SearchView, FactualProxyView, AnalyzeAndMatchView


urlpatterns = [
    # Original endpoint
    path('', SearchView.as_view(), name="factual_api"),
    # New proxy endpoint for direct Factual API access
    path('factual/<str:endpoint>/', FactualProxyView.as_view(), name="factual_proxy"),
    # High-level endpoint with external model integration
    path('analyze-and-match/', AnalyzeAndMatchView.as_view(), name="analyze_and_match"),
]