from django.urls import include, path
from .views import RegistrationView, LoginAPI, get_profile, UserProfileUpdateAPIView, UpdateEmailView, ChangePasswordView
from rest_framework_simplejwt import views as jwt_views

urlpatterns = [
    path('register/', RegistrationView.as_view(), name='register'),
    path('token/', jwt_views.TokenObtainPairView.as_view(), name ='token_obtain_pair'),
    path('token/refresh/', jwt_views.TokenRefreshView.as_view(), name ='token_refresh'),
    path('login/', LoginAPI.as_view(), name='login'),
    path('get_profile/', get_profile, name='get_profile'),
    path('update-profile/', UserProfileUpdateAPIView.as_view(), name='update-profile'),
    path('update-email/', UpdateEmailView.as_view(), name='update-email'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
]