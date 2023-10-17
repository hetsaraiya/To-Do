from django.urls import path
from .views import TodoDelete
from .views import TodoGet

urlpatterns = [
    path('', TodoGet.as_view()),
    path('<int:pk>', TodoDelete.as_view()),
    
]