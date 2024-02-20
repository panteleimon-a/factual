from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin,Group, Permission
from django.contrib.auth.backends import ModelBackend
from django.contrib.auth.models import User
'''

class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)
    full_name = models.CharField(max_length=255, default='')
    is_active = models.BooleanField(default=False)
    is_journalist = models.BooleanField(default=False)
    type_of_employment = models.CharField(max_length=255, blank=True, null=True)
    organization_name = models.CharField(max_length=255, blank=True, null=True)

    USERNAME_FIELD = 'email'
    '''
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    full_name = models.CharField(max_length=255, blank=True, null=True)
    is_journalist = models.BooleanField(default=False)
    type_of_employment = models.CharField(max_length=255, blank=True, null=True)
    organization_name = models.CharField(max_length=255, blank=True, null=True)
    beta_authenticated = models.BooleanField(default=False)
