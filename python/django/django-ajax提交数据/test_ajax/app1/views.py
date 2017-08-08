from django.shortcuts import render
from django.http.response import JsonResponse


def index(request):
    if request.method == 'POST':
        res = {}
        res['user'] = request.POST.get('user')
        res['pwd'] = request.POST.get('pwd')
        return JsonResponse(res, safe=True)
    return render(request, "index.html", {})

