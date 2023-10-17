from django.shortcuts import render
from rest_framework import generics
from .models import Todo
from .serializer import TodoSerealizer

class TodoGet(generics.ListCreateAPIView):
    queryset = Todo.objects.all()
    serializer_class = TodoSerealizer

class TodoDelete(generics.RetrieveUpdateDestroyAPIView):
    queryset = Todo.objects.all()
    serializer_class = TodoSerealizer