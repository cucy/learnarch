## 环境准备

### 部署git服务器

`先安装mysql`

```shell
[root@n1 ~]# docker run -d --name mysql -p 3306:3306 -e MYSQL_DATABASE=gogs -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.5.57
```

`Gogs轻量级git服务器`

```shell
[root@n1 ~]# docker run -d --name=gogs -p 10022:22 -p 3000:3000 --link mysql:mysql  -v /var/gogs:/data gogs/gogs
```
- `域名`必须写外网能访问的地址,`端口`必须是外网能访问的端口,`应用 URL`写外网可以访问的URL,**否则不能正常登陆克隆**
- `参考文档 https://github.com/gogits/gogs/tree/master/docker 启动时修改 Database Type , Domain , Application URL`

## 练习一 Git仓库管理

### 1.从远程仓库拉取代码

```shell
[root@n1 ~]# git clone https://github.com/cucy/learnarch.git
[root@n1 ~]# cd learnarch
[root@n1 petstore-account-service]# git remote -v
origin	https://github.com/cucy/learnarch.git (fetch)
origin	https://github.com/cucy/learnarch.git (push)
```

### 2.创建新的远程仓库 

Gogs界⾯操作：注册⽤户，登录，创建代码仓库，拷⻉仓库地址 

### 3.添加到远程仓库 

```shell
[root@n1 petstore-account-service]# git remote add zrdtest http://10.76.249.131:3000/zrd/zrdtest.git
[root@n1 petstore-account-service]# git remote -v
origin	https://github.com/cucy/learnarch.git (fetch)
origin	https://github.com/cucy/learnarch.git (push)
zrdtest	http://10.76.249.131:3000/zrd/zrdtest.git (fetch)
zrdtest	http://10.76.249.131:3000/zrd/zrdtest.git (push)
[root@n1 petstore-account-service]# git push -u zrdtest origin/master 

# 删除远程仓库地址
bash-4.3# git remote  remove zrdtest
bash-4.3# git remote -v
origin	https://github.com/cucy/learnarch.git (fetch)
origin	https://github.com/cucy/learnarch.git (push)
```

## 练习二 代码提交和回滚

### 1.在主分支修改内容

⽐如修改README.md⽂件，创建新⽂件或删除已有文件 

### 2.提交修改到本地仓库
```shell
git status
git add .
git status
git commit -m "任意关于提交内容的注解"
git status 
```
### 3.回滚提交 

```shell
git log 	#查看提交号
git revert 	<要回滚的提交号>
git log
git status
```

### 4.还原提交历史 

```shell
git reset			<要还原到的提交号>
git status			# 默认还原到⼯作区
git reset --hard 	<要还原到的提交号>
git status
git log
```

### 5.提交到远程仓库 

```shell
git push			# 会提示输入Github账号密码 回滚提交需要加 -f (--froce)
cat .git/config 	# 查看分分支的默认远端仓库
```

### 6.修改主干的默认远端仓库 

```shell
git push -u stuq master
cat .git/config
```

## 练习三 Git分支管理&单主干分支策略 

### 1.创建发布分支

```shell
git branch -v		# 本地分支状态
git branch -v -r	# 远程分支
git branch rel_1.0	# 创建分支
git branch -v
git branch -v -r
git checkout rel_1.0	# 切换到分支

# 简洁版创建分支并切换
git checkout -b rel_1.1
git branch -v
```
* 将当前分支推送到`remote`端
    - 1、远程已有`remote_branch`分支并且已经关联本地分支`local_branch`且本地已经切换到`local_branch`: 
        `git push`
    - 2、远程已有`remote_branch`分支但未关联本地分支`local_branch`且本地已经切换到`local_branch`: ` git push -u origin/remote_branch`
    - 3、远程没有`remote_branch`分支,且本地已经切换到`local_branch`: `git push origin local_branch:remote_branch`

### 2.继续修改并提交到开发分支

`修改、创建、删除等操作...`

```shell
git add .
git commit -m "任意关于提交内容的注解"
git pull --rebase 	# 提交前先拉取， rebase参数会避免产生额外分支
git push 			# 有默认远端仓库的分支就可以直接push
```

### 3.进进版本发布，合并提交到Master分支

```shell
git checkout rel_1.0
git merge master
git tag v1.0
git push		# 提示未设置该分⽀的默认远程仓库
cat .git/config
```

### 4.设置分支的默认远程仓库

```shell
git push --set-upstream stuq rel_1.0
cat .git/config
git push --tag 	#提交标签
```

### 5.线上紧急问题修复 

```shell
git checkout rel_1.0
```

`修改、创建、删除...执行必要测试`

```shell
git add .
git commmit -m "线上问题修复说明"
git tag v1.0.1
git push
git push --tag
git log #查看提交号
git checkout master
git cherry-pick <提交号列表
```

## 练习四 从历史记录中移除敏感信息文件

### 1.创建一个包含密码内容的文件并提交

```shell
echo '123456' > password
git add .
git commit -m "add password file"
git push
```

### 2.删除这个文件

```shell
git rm password
git commit -m "remove password file"
git push
```

### 3.检查历史记录

`伪删除`
git checkout 回到历史版本或在Gogs界面查看提交历史 被删除的密码文件件依然存在于历史中

### 4.使用bfg工具彻底清除指定文件

```shell
alias bfg='java -jar /bin/bfg-1.12.15.jar'
bfg --help
bfg -D password
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force #提示主干是保护分支，不能force push
```

### 5.解除主干保护

在Gogs的仓库配置中移除主干分支的保护，从新push

```shell
git push --force
```

## 练习五 修改历史提交的注解

### 1.错误的提交注解

修改文件、创建文件、删除文件...

```shell
git add .
git commit -m "注解内容"
git log
```

### 2.修改最后一次提交的注解内容

```shell
git commit -m "新的注解内容" --amend
git log
```

### 3.修正更早以前的提交注解

```shell
git log 		# 找到要修改提交的前一个提交号
git rebase -i 	<提交号>
git push --force
```



# 暂时存储已开发的代码,中途最其他的事情 (另一个方案 使用分支)

```
git  stash -h
usage: git stash list [<options>]
   or: git stash show [<stash>]
   or: git stash drop [-q|--quiet] [<stash>]
   or: git stash ( pop | apply ) [--index] [-q|--quiet] [<stash>]
   or: git stash branch <branchname> [<stash>]
   or: git stash [save [--patch] [-k|--[no-]keep-index] [-q|--quiet]
		       [-u|--include-untracked] [-a|--all] [<message>]]
   or: git stash clear

  
  
```
   
   

   
git stash 
		`当前文件临时存放到????, 可以取回来,可以帮忙合并(自动操作)`
		`只存红色的文件,被修改的文件没有进行add`
	
git stash pop 			取回最后保存的一条
git stash apply xxxx    按编号取回



# 合并


git branch -h 

git  merge xxx  `将xxx分支合并到当期所在分支 (先git checkout到需要合并的分支)`

git branch  -d xxx `删除分支`



# 把代码拉取到暂存区 (两步操作 等价于 git pull)

`git fetch  dev` 

`git  merge origin/dev `


# rebase

`git fetch  dev `

`git  rebase origin/dev`    # 不会产生新分叉记录 和 merge不一样

git  rebase  # 保持提交记录的整洁



# 解决冲突

 - 所有相关开发人员都在
 - 合并时间尽量缩短(每个功能模块进行合并)
 - review
