from django.urls import path
from API.views import twitter_API


urlpatterns = [
    path('', twitter_API.as_view(), name="platform_API"),
]