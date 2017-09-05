# str unicode

| **Python 2**                             | **Python 3**                             |
| ---------------------------------------- | ---------------------------------------- |
| class Person(models.Model):    name = models.TextField()    def __unicode__(self):        return self.name | class Person(models.Model):    name = models.TextField()    def __str__(self):        return self.name |





**Calling super() is easier**

| **Python 2**                             | **Python 3**                             |
| ---------------------------------------- | ---------------------------------------- |
| class CoolMixin(object):    def do_it(self):        return super(CoolMixin,                  self).do_it() | class CoolMixin:    def do_it(self):        return super().do_it() |

**Standard library reorganized**

| **Python 2**                             | **Python 3**                             |
| ---------------------------------------- | ---------------------------------------- |
| $ python -m SimpleHTTPServerServing HTTP on 0.0.0.0 port 8000 ... | $python -m http.serverServing HTTP on 0.0.0.0 port 8000 ... |

