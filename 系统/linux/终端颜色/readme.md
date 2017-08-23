## 例子1

`pic1.png`

```shell
#!/bin/bash 

# clear the screen 
tput clear

# Move cursor to screen location X,Y (top left is 0,0) 
tput cup 3 15

# Set a foreground colour using ANSI escape 
tput setaf 3
echo "XYX Corp LTD."
tput sgr0

tput cup 5 17

# Set reverse video mode 
tput rev
echo "M A I N - M E N U"
tput sgr0
tput cup 7 15
echo "1. User Management"
tput cup 8 15
echo "2. Service Management"
tput cup 9 15
echo "3. Process Management"
tput cup 10 15
echo "4. Backup"

# Set bold mode 
tput bold
tput cup 12 15
read -p "Enter your choice [1-4] " choice

tput clear
tput sgr0
tput rc
```

## 例子2

```shell
#!/bin/bash  
  
# $1 str       print string  
# $2 color     0-7 设置颜色  
# $3 bgcolor   0-7 设置背景颜色  
# $4 bold      0-1 设置粗体  
# $5 underline 0-1 设置下划线  
  
function format_output(){  
    str=$1  
    color=$2  
    bgcolor=$3  
    bold=$4  
    underline=$5  
    normal=$(tput sgr0)  
  
    case "$color" in  
        0|1|2|3|4|5|6|7)  
            setcolor=$(tput setaf $color;) ;;  
        *)  
            setcolor="" ;;  
    esac  
  
    case "$bgcolor" in  
        0|1|2|3|4|5|6|7)  
            setbgcolor=$(tput setab $bgcolor;) ;;  
        *)  
            setbgcolor="" ;;  
    esac  
  
    if [ "$bold" = "1" ]; then  
        setbold=$(tput bold;)  
    else  
        setbold=""  
    fi  
  
    if [ "$underline" = "1" ]; then  
        setunderline=$(tput smul;)  
    else  
        setunderline=""  
    fi  
  
    printf "$setcolor$setbgcolor$setbold$setunderline$str$normal\n"  
}  
  
format_output "Yesterday Once More" 2 5 1 1  
  
exit 0  
```

## 颜色

```shell
# 前景色

0 – Black  
1 – Red  
2 – Green  
3 – Yellow  
4 – Blue  
5 – Magenta  品红
6 – Cyan  青色
7 – White 

# 背景色
数字颜色数字颜色

 # Color   # define        # Value   # RGB
 black     COLOR_BLACK       0     0, 0, 0
 blue      COLOR_BLUE        1     0,0,max
 green     COLOR_GREEN       2     0,max,0
 cyan      COLOR_CYAN        3     0,max,max
 red       COLOR_RED         4     max,0,0
 magenta   COLOR_MAGENTA     5     max,0,max
 yellow    COLOR_YELLOW      6     max,max,0
 white     COLOR_WHITE       7     max,max,max

```

