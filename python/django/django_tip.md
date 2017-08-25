
### `from django.utils.translation import * `
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
