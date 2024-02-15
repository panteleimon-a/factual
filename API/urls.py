from django.urls import path
from API.views import SearchView


urlpatterns = [
    path('', SearchView.as_view(), name="factual API"),
]