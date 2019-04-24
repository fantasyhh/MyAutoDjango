from django.urls import path
from rest_framework.routers import DefaultRouter
from .views import TestView

# router = DefaultRouter()
# router.register(r'mouseinfo', MouseInfoViewSet)
# urlpatterns = router.urls

# if DefaultRouter exists ,urlpatterns+= [...]
urlpatterns = [
    path('hello_django/', TestView.as_view()),
]
