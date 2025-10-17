from django.shortcuts import render
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token
from .models import UserProfile
from .serializers import UserSerializer, LoginSerializer, UserProfileSerializer, UserSerializer
from django.contrib.auth import login, logout
from django.http import JsonResponse
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import ensure_csrf_cookie
from rest_framework import permissions  # Add this import
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.contrib.auth import authenticate
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework import generics
from rest_framework_simplejwt.tokens import RefreshToken, AccessToken
from django.contrib.auth.models import User
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.exceptions import ValidationError
from django.contrib.auth.password_validation import validate_password
'''
class RegistrationView(APIView):
    def post(self, request, *args, **kwargs):
        request.data['is_approved'] = False
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            
            #token, created = Token.objects.create(user=user)
            #return Response({'token': token.key}, status=status.HTTP_201_CREATED)
            return Response({'message': 'Registration successful'}, status=status.HTTP_201_CREATED)
        else:
            print(serializer.errors)  # Log or print validation errors
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
'''
# views.py
class RegistrationView(APIView):
    def post(self, request):
        try:
            # Extract relevant data from request data
            email = request.data.get('email')
            password = request.data.get('password')
            full_name = request.data.get('full_name')
            is_journalist = request.data.get('is_journalist')
            type_of_employment = request.data.get('type_of_employment')
            organization_name = request.data.get('organization_name')
            # Create a new User object (use create_user for password hashing)
            user = User.objects.create_user(username=email, password=password, email=email)
            user.is_active = False
            user.save()
            # Create a new UserProfile object
            UserProfile.objects.create(
                user=user,
                full_name=full_name,
                is_journalist=is_journalist,
                type_of_employment=type_of_employment,
                organization_name=organization_name
            )

            # Return appropriate response
            return Response({'message': 'Registration successful'}, status=status.HTTP_201_CREATED)

        except Exception as e:
            # Handle exceptions, log errors, and return an appropriate response
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class LoginAPI(generics.CreateAPIView):
    serializer_class = LoginSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        '''
                # Authenticate user
        user = authenticate(
            request,
            username=serializer.validated_data['username'],
            password=serializer.validated_data['password']
        )

        if not user:
            raise AuthenticationFailed('Invalid username or password')
        '''

        username = serializer.validated_data['username']
        password = serializer.validated_data['password']

        # Check if the user exists
        if not User.objects.filter(username=username).exists():
            # For security, you may want to use a generic message
            raise ValidationError({'username': ['Invalid email']})

        user = User.objects.get(username=username)
        # check if user is not yet approved
        if not user.is_active:
            raise ValidationError({'user_active_status': ['Not active.']})

        # Authenticate user
        user = authenticate(username=username, password=password)

        # Check if authentication was successful
        if not user:
            # Again, for better security, use a generic message
            raise ValidationError({'password': ['Invalid password']})

        refresh = RefreshToken.for_user(user)
        access = AccessToken.for_user(user)

        return Response({
            "user": UserSerializer(user, context=self.get_serializer_context()).data,
            "refresh": str(refresh),
            "access": str(access),
        })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_profile(request):
    user=request.user
    user_profile = UserProfile.objects.get(user=user)  # Assuming you have a user profile associated with the request
    user_profile_serializer = UserProfileSerializer(user_profile) 
    user_serializer = UserSerializer(user)
 
    response_data = {
        'user': user_serializer.data,
        'user_profile': user_profile_serializer.data,
    }
    return Response(response_data)

@permission_classes([IsAuthenticated])
class UserProfileUpdateAPIView(APIView):
    def put(self, request):
        try:
            # Extract updated profile data from request payload

            full_name = request.data.get('full_name')
            is_journalist = request.data.get('is_journalist')
            type_of_employment = request.data.get('type_of_employment')
            organization_name = request.data.get('organization_name')
            # Retrieve user profile associated with the authenticated user
            user_profile = UserProfile.objects.get(user=request.user)

            # Update user profile fields
            user_profile.full_name = full_name
            user_profile.is_journalist = is_journalist
            user_profile.type_of_employment = type_of_employment
            user_profile.organization_name = organization_name
            user_profile.save()

            # Serialize updated user profile and return response
            serializer = UserProfileSerializer(user_profile)
            return Response(serializer.data, status=status.HTTP_200_OK)

        except Exception as e:
            # Handle exceptions and return error response
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
@permission_classes([IsAuthenticated])
class UpdateEmailView(APIView):
    def put(self, request, *args, **kwargs):
        user = request.user
        new_email = request.data.get('email', None)

        if not new_email:
            return Response({'error': 'Email is required.'}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email=new_email).exclude(username=user.username).exists():
            return Response({'error': 'This email is already in use.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user.email = new_email
            user.username = new_email
            user.save()
            return Response({'message': 'Email updated successfully.'}, status=status.HTTP_200_OK)
        except ValidationError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
@permission_classes([IsAuthenticated])
class ChangePasswordView(APIView):
    def put(self, request, *args, **kwargs):
        user = request.user
        old_password = request.data.get('old_password', None)
        new_password = request.data.get('new_password', None)

        if old_password is None or new_password is None:
            return Response({'error': 'Old password and new password are required.'}, status=status.HTTP_400_BAD_REQUEST)

        if not authenticate(username= user.username, password = old_password):
            return Response({'error': 'Incorrect old password.'}, status=status.HTTP_400_BAD_REQUEST)

        
        try:
            # Validate the new password
            validate_password(new_password, user)
            # Set the new password
            user.set_password(new_password)
            user.save()
            return Response({'message': 'Password updated successfully.'}, status=status.HTTP_200_OK)
        except ValidationError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)