
# `from django.utils.translation import * `
```
Django 国际化使用的翻译模块是使用 Python 自带的 gettext 标准模块。通过一个到 GNU gettext 消息目录库的接口，这个模块为 Python 程序提供了国际化 (I18N) 和本地化 (L10N)。
开发人员和翻译人员需要完成一下 3 个步骤：
1. 第一步：在 Python 代码和模板中嵌入待翻译的字符串，
2. 第二步：把那些字符串翻译成需要支持的语言，并进行相应的编译
3. 第三步：在 Django settings 文件中激活本地中间件，
```
```python
from django.utils.translation import ugettext_lazy as _

from django.utils.translation import gettext_lazy
。gettext_lazy适合用在form和model的字段定义中
```
## `from django.utils.translation import ugettext`
```python
from django.http import HttpResponse

from django.utils.translation import ugettext as _
# 使用函数 ugettext() 指定一个待翻译的字符串, 方便使用短别名'_'

import time

def test1_view(request):
	t = time.localtime()
	n = t[6]

	# 星期一到星期天字符串,每个字符串用_()标识出来
	weekdays = [ _('Monday'), _('Tuesday'), _('Wednesday'), _('Thursday'), _('Friday'), _('Saturday'), _('Sunday')]
	return HttpResponse(weekdays[n]) 
	

# 步骤 1 创建目录
'''
接下来，先在 test1 App 目录下创建 locale 目录，
并运行“django-admin.py makemessages -l zh_CN”产生 locale/zh_CN/LC_MESSAGES/django.po 文件
'''

'''
[root@localhost test1]# mkdir locale 
[root@localhost test1]# ls 
__init__.py  __init__.pyc  locale  models.py  tests.py  views.py  views.pyc 
[root@localhost test1]# django-admin.py makemessages -l zh_CN
'''

# 步骤二 修改模板
'''
打开 locale/zh_CN/LC_MESSAGES/django.po 文件，其主要内容如清单 8：
'''

'''
清单 8. 更新 django.po 文件
-------------------------------------------
#: views.py:12 
msgid "Monday"
msgstr "星期一"
 
#: views.py:12 
msgid "Tuesday"
msgstr "星期二"
 
#: views.py:12 
msgid "Wednesday"
msgstr "星期三"
 
#: views.py:12 
msgid "Thursday"
msgstr "星期四"
 
#: views.py:12 
msgid "Friday"
msgstr "星期五"
 
#: views.py:12 
msgid "Saturday"
msgstr "星期六"
 
#: views.py:12 
msgid "Sunday"
msgstr "星期天"
'''

# 步骤三 编译模板成二进制
'''
编译信息文件,编译成二进制

创建信息文件之后，每次对其做了修改，
都需要用 django-admin.py compilemessages 编译成“.mo”文件供 gettext 使用，
具体操作请参看清单 9
'''
'''
清单 9. 编译信息文件

[root@localhost test1]# django-admin.py compilemessages
'''

# 步骤四 确认配置
'''
首先需要确认 testsite 目录下 setting.py 的配置，
主要需要核实 LANGUAGE_CODE，USE_I18N 和 MIDDLEWARE_CLASSES。
主要配置请参看清单 10:
'''
'''
清单 10. setting.py 中的国际化相关配置:

LANGUAGE_CODE = 'en-us'
USE_I18N = True 
MIDDLEWARE_CLASSES = ( 
   'django.middleware.common.CommonMiddleware', 
   'django.contrib.sessions.middleware.SessionMiddleware', 
   'django.middleware.locale.LocaleMiddleware', 
   'django.contrib.auth.middleware.AuthenticationMiddleware', 
)

请注意注意 MIDDLEWARE_CLASSES 中的'django.middleware.locale.LocaleMiddleware', 
需要放在'django.contrib.sessions.middleware.SessionMiddleware' 后面。

必须  python manage.py migrate
'''

```
