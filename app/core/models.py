"""
Database models.
"""
from django.db import models
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin,
)


class UserManager(BaseUserManager):
    """Manager for users."""

    def create_user(self, email, password=None, **extra_fields): # **extra_fields: can provide keyword arguments
        """Create, save and return a new user."""
        if not email:
            raise ValueError('User must have an email address.')
        user = self.model(email=self.normalize_email(email), **extra_fields) # 'self.model' is a way defining a new user object out of our user class
        user.set_password(password) # setup hashed password. it defaults by Django
        user.save(using=self._db) # 'self._db' means it supports adding multiple databases. code this way is funture-proof.

        return user

    def create_superuser(self, email, password):
        """Create and return a new superuser."""
        user = self.create_user(email, password)
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)

        return user


# AbstractBaseUser contains authentication system but not any fields
# PermissionsMixin contains functionality for permission and fields
class User(AbstractBaseUser, PermissionsMixin):
    """User in the system."""
    email = models.EmailField(max_length=255, unique=True)
    name = models.CharField(max_length=255)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager() # assgin the user manager to our custom user class. it creates an instance of the manager.

    USERNAME_FIELD = 'email'