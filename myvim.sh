#!/bin/bash
# 程序名：myvim.sh
# 作者：李龙飞
# 学号：3200100556
# 程序功能：用 bash shell 实现简易的 vim 编辑器
#         可以在终端上进行编辑，并且可以保存到文件中
#         具体功能见功能描述文档

# 刷新屏幕显示内容函数
function refresh_screen() {
    # 将光标移到文件开头
    printf "\e[1;1H"
    # 隐藏光标
    printf "\e[?25l"
    # 清屏
    printf "\e[2J"
    # 显示更新后的文件内容
    cat .temp_file_of_myvim
    # 将光标移到当前位置
    printf "\e[${cur_line};${cur_column}H"
    # 显示光标
    printf "\e[?25h"
}

# 获取文件行数和每行字符数函数
function get_line_info() {
    # 获取文件行数
    num_line=$[`wc -l < .temp_file_of_myvim` + 1]
    # 将第0行的字符数设置为0
    char_line=(0)
    # 获取文件每行字符数
    for char in `awk -F "" '{print NF}' temp.txt`; do
        char_line[${#char_line[*]}]=${char}
    done
    # 若最后一行为空行，则将其字符数设置为0
    if [ ${#char_line[*]} -lt $((num_line + 1)) ]; then
        char_line[${#char_line[*]}]=0
    fi
}

# 打印底线命令模式提示符函数
function print_lastline_info() {
    # 重置字符属性
    printf "\e[0m"
    # 刷新屏幕显示内容
    refresh_screen
    # 移动光标到命令提示符位置
    # 即为文件最下方位置后三行
    printf "\e[$((num_line+3));1H"
    # 设置反色
    printf "\e[7m"
    # 隐藏光标
    printf "\e[?25l"
    # 打印命令提示符
    echo "-- LAST LINE --"
    # 打印冒号
    echo -n ": "
    # 显示光标
    printf "\e[?25h"
}

# 打印错误提示符函数
function print_error_info() {
    # 重置字符属性
    printf "\e[0m"
    # 刷新屏幕显示内容
    refresh_screen
    # 移动光标到命令提示符位置
    # 即为文件最下方位置后三行
    printf "\e[$((num_line+3));1H"
    # 设置强调色加粗
    printf "\e[1;37;41m"
    # 隐藏光标
    printf "\e[?25l"
    # 打印命令提示符
    printf $1
    # 将光标移到原先行列位置
    printf "\e[${cur_line};${cur_column}H"
    # 显示光标
    printf "\e[?25h"
}

# 打印插入模式提示符函数
function print_insert_info() {
    # 重置字符属性
    printf "\e[0m"
    # 刷新屏幕显示内容
    refresh_screen
    # 移动光标到命令提示符位置
    # 即为文件最下方位置后三行
    printf "\e[$((num_line+3));1H"
    # 设置反色加粗
    printf "\e[1;7m"
    # 隐藏光标
    printf "\e[?25l"
    # 打印命令提示符
    echo -n "-- INSERT --"
    # 将光标移到原先行列位置
    printf "\e[${cur_line};${cur_column}H"
    # 显示光标
    printf "\e[?25h"
    # 重置字符属性
    printf "\e[0m"
}

# 打印替换模式提示符函数
function print_replace_info() {
    # 重置字符属性
    printf "\e[0m"
    # 刷新屏幕显示内容
    refresh_screen
    # 移动光标到命令提示符位置
    # 即为文件最下方位置后三行
    printf "\e[$((num_line+3));1H"
    # 设置反色加粗
    printf "\e[1;7m"
    # 隐藏光标
    printf "\e[?25l"
    # 打印命令提示符
    echo -n "-- REPLACE --"
    # 将光标移到原先行列位置
    printf "\e[${cur_line};${cur_column}H"
    # 显示光标
    printf "\e[?25h"
    # 重置字符属性
    printf "\e[0m"
}

# 打印用法提示函数
usage() {
    echo "usage: ./myvim.sh [FILE]..."
}

# 若参数为空，则报错、打印用法提示并退出
if [ $# -eq 0 ]; then
    # 打印错误提示符
    echo -e "\e[1;37;41mError: No file name\e[0m"
    # 打印使用方法
    usage
    # 退出
    exit 1
fi

# 若参数过多，则报错、打印用法提示并退出
if [ $# -gt 1 ]; then
    # 打印错误提示符
    echo -e "\e[1;37;41mError: Too many file name\e[0m"
    # 打印使用方法
    usage
    # 退出
    exit 1
fi

# 检查文件是否存在
if [ ! -f $1 ]; then
    # 打印错误提示符
    echo -e "\e[1;37;41mError: $1 is not a file\e[0m"
    # 打印使用方法
    usage
    # 退出
    exit 1
fi

# 检查文件是否可读
if [ ! -r $1 ]; then
    # 打印错误提示符
    echo -e "\e[1;37;41mError: $1 is not readable\e[0m"
    # 打印使用方法
    usage
    # 退出
    exit 1
fi

# 获取文件
file=$1
# 清屏
clear
# 将文件输出到临时文件
cat $file > .temp_file_of_myvim
# 在屏幕上显示文件内容
cat .temp_file_of_myvim
# 获取文件行数和每行字符数
get_line_info
# 将当前行数设置为1
cur_line=1
# 将当前列数设置为1
cur_column=1
# 设置模式为命令模式
mode="command"
# 将光标移动到当前位置
printf "\e[${cur_line};${cur_column}H"
# 设置cESC键值
cESC=`echo -ne "\033"`
# 设置cENTER键值
cENTER=`echo -ne "\015"`
# 设置cBACKSPACE键值
cBACKSPACE=`echo -ne "\177"`
# 将辅助计数的变量初始化为0
number=0
# 将剪贴板初始化为空
copy=""

# 主循环
while :; do
    # 判断模式
    case $mode in
        "command") # 命令模式
            # 保存旧的分隔符设置
            OLD_IFS="$IFS"
            # 将输入分隔符设置为回车
            IFS=$'\n'
            # 获取输入(无回显且单字符相应)
            read -n 1 -s cmd
            # 还原分隔符设置
            IFS=$OLD_IFS
            # 分析输入命令
            case $cmd in
                ":") # 进入底线命令模式
                    mode="lastline"
                    # 打印底线命令模式提示符
                    print_lastline_info
                    ;;
                "x") # 向后删除一个字符 (相当于[del])
                    # 若无记录需要删除的数量，则默认删除一个字符
                    if [ $number -eq 0 ]; then
                        # 仅在当前行不为空行时生效
                        if [ ${char_line[$cur_line]} -gt 0 ]; then
                            # 使用awk删除将当前位置字符替换为空字符
                            awk -v FS="" -v OFS="" '{ 
                                if ("'"$cur_line"'" == NR) {
                                    gsub(/.*/, "", $"'"$cur_column"'")
                                }
                                print > ".temp_file_of_myvim"
                            }' .temp_file_of_myvim
                            # 将当前行的总字符数减1
                            char_line[$cur_line]=$((${char_line[$cur_line]}-1))
                            # 若删除的字符为当前行的最后一个字符，则将当前位置往前移一格
                            if [ ${char_line[$cur_line]} -lt $cur_column ]; then
                                cur_column=${char_line[$cur_line]}
                            fi
                            # 刷新屏幕显示内容
                            refresh_screen
                        fi
                    else # 若记录了要删除的数字，则删除对应数量的字符
                        # 仅在当前行不为空行时生效
                        if [ ${char_line[$cur_line]} -gt 0 ]; then
                            # 循环删除对应数量的字符
                            while [ $number -gt 0 ]; do
                                # 使用awk删除将当前位置字符替换为空字符
                                awk -v FS="" -v OFS="" '{ 
                                    if ("'"$cur_line"'" == NR) {
                                        gsub(/.*/, "", $"'"$cur_column"'")
                                    }
                                    print > ".temp_file_of_myvim"
                                }' .temp_file_of_myvim
                                # 将当前行的总字符数减1
                                char_line[$cur_line]=$((${char_line[$cur_line]}-1))
                                # 若删除的字符为当前行的最后一个字符
                                # 则将当前位置往前移一格
                                # 并且退出循环
                                if [ ${char_line[$cur_line]} -lt $cur_column ]; then
                                    cur_column=${char_line[$cur_line]}
                                    break;
                                fi
                                # 将待删除数量减1
                                number=$(($number-1))
                            done
                            # 刷新屏幕显示内容
                            refresh_screen
                            # 将辅助计数变量重置为0
                            number=0
                        fi
                    fi
                    ;;
                "X") # 向前删除一个字符 (相当于[backspace])
                    # 若无记录需要删除的数量，则默认删除一个字符
                    if [ $number -eq 0 ]; then
                        # 仅在当前行不为空行，且当前位置不为最左端的位置时生效
                        if [ ${char_line[$cur_line]} -gt 0 ] && [ $cur_column -gt 1 ]; then
                            # 使用awk删除将当前位置左边的字符替换为空字符
                            awk -v FS="" -v OFS="" '{ 
                                if ("'"$cur_line"'" == NR) {
                                    gsub(/.*/, "", $"'"$(($cur_column-1))"'")
                                }
                                print > ".temp_file_of_myvim"
                            }' .temp_file_of_myvim
                            # 将当前行的总字符数减1
                            char_line[$cur_line]=$((${char_line[$cur_line]}-1))
                            # 将当前位置往左移一格
                            cur_column=$(($cur_column-1))
                            refresh_screen
                        fi
                    else # 若记录了要删除的数字，则删除对应数量的字符
                        # 仅在当前行不为空行，且当前位置不为最左端的位置时生效
                        if [ ${char_line[$cur_line]} -gt 0 ] && [ $cur_column -gt 1 ]; then
                            while [ $number -gt 0 ]; do
                                # 使用awk删除将当前位置左边的字符替换为空字符
                                awk -v FS="" -v OFS="" '{ 
                                    if ("'"$cur_line"'" == NR) {
                                        gsub(/.*/, "", $"'"$(($cur_column-1))"'")
                                    }
                                    print > ".temp_file_of_myvim"
                                }' .temp_file_of_myvim
                                # 将当前行的总字符数减1
                                char_line[$cur_line]=$((${char_line[$cur_line]}-1))
                                # 将当前位置往左移一格
                                cur_column=$(($cur_column-1))
                                # 若当前位置为最左端的位置，则退出循环
                                if [ $cur_column -le 1 ]; then
                                    break;
                                fi
                                # 将待删除数量减1
                                number=$(($number-1))
                            done
                            # 刷新屏幕显示内容
                            refresh_screen
                            # 将辅助计数变量重置为0
                            number=0
                        fi
                    fi
                    ;;
                "0") # 将光标移动到当前行的最左端
                    # 若之前未输入其他数字
                    if [ $number -eq 0 ]; then
                        # 将当前位置移到最左端
                        cur_column=1
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                    else
                        # 若之前输入其他数字，则统计输入数字以待后用
                        number=$(($number*10+$cmd))
                    fi
                    ;;
                "$") # 将光标移动到当前行的最右端
                    # 将当前位置移到最右端
                    cur_column=${char_line[$cur_line]}
                    # 将光标移到当前位置
                    printf "\e[${cur_line};${cur_column}H"
                    ;;
                [1-9]) # 1-9的数字
                    # 统计输入数字以待后用
                    number=$(($number*10+$cmd))
                    ;;
                "") # 空字符 (相当于回车，因为输入分隔符为回车)
                    # 若之前未输入其他数字，默认输入1
                    if [ $number -eq 0 ]; then
                        # 将当前行数加上1
                        cur_line=$(($cur_line+$number))
                        # 若当前行数超出范围，则将当前行数设置为最后一行
                        if [ $cur_line -gt $num_line ]; then
                            cur_line=$num_line
                        fi
                        # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                        if [ ${char_line[$cur_line]} -lt $cur_column ]; then
                            cur_column=${char_line[$cur_line]}
                        fi
                        # 若当前行为空行，则手动将当前位置置为1
                        if [ $cur_column -eq 0 ]; then
                            cur_column=1
                        fi
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                    else # 若之前输入其他数字，则下移输入数字行数
                        # 将当前行数更新，加上输入的数字
                        cur_line=$(($cur_line+$number))
                        # 若当前行数超出范围，则将当前行数设置为最后一行
                        if [ $cur_line -gt $num_line ]; then
                            cur_line=$num_line
                        fi
                        # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                        if [ ${char_line[$cur_line]} -lt $cur_column ]; then
                            cur_column=${char_line[$cur_line]}
                        fi
                        # 若当前行为空行，则手动将当前位置置为1
                        if [ $cur_column -eq 0 ]; then
                            cur_column=1
                        fi
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                        # 将辅助计数变量重置为0
                        number=0
                    fi
                    ;;
                "G") # 移动到指定行
                    # 若之前未输入其他数字
                    if [ $number -eq 0 ]; then
                        # 将行数设置为最后一行
                        cur_line=$num_line
                        # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                        if [ ${char_line[$cur_line]} -lt $cur_column ]; then
                            cur_column=${char_line[$cur_line]}
                        fi
                        # 若当前行为空行，则手动将当前位置置为1
                        if [ $cur_column -eq 0 ]; then
                            cur_column=1
                        fi
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                    else # 若之前输入其他数字，则移动到指定行
                        # 将行数设置为指定行
                        cur_line=$number
                        # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                        if [ $cur_line -gt $num_line ]; then
                            cur_line=$num_line
                        fi
                        # 若当前行为空行，则手动将当前位置置为1
                        if [ ${char_line[$cur_line]} -lt $cur_column ]; then
                            cur_column=${char_line[$cur_line]}
                        fi
                        # 若当前行为空行，则手动将当前位置置为1
                        if [ $cur_column -eq 0 ]; then
                            cur_column=1
                        fi
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                        # 将辅助计数变量重置为0
                        number=0
                    fi
                    ;;
                " ") # 向后移动若干字符
                    # 若之前未输入其他数字
                    if [ $number -eq 0 ]; then
                        # 若当前位置右边尚有字符，则将当前位置右移一个字符
                        if [ $cur_column -lt ${char_line[$cur_line]} ]; then
                            cur_column=$(($cur_column+1))
                        # 若当前位置右边无字符且不为最后一行，则将当前位置移到下一行
                        elif [ $cur_line -lt $num_line ]; then
                            cur_line=$(($cur_line+1))
                            cur_column=1
                        fi
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                    else # 若之前输入其他数字，则向后移动指定字符数
                        # 循环移动指定字符数
                        while [ $number -gt 0 ]; do
                            # 若当前位置右边尚有字符，则将当前位置右移指定字符数
                            if [ $cur_column -lt ${char_line[$cur_line]} ]; then
                                cur_column=$(($cur_column+1))
                            # 若当前位置右边无字符且不为最后一行，则将当前位置移到下一行
                            elif [ $cur_line -lt $num_line ]; then
                                cur_line=$(($cur_line+1))
                                cur_column=1
                            fi
                            # 将待移动字符数减1
                            number=$(($number-1))
                        done
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                    fi
                    ;;
                "") # 向前移动若干字符
                    # 若之前未输入其他数字
                    if [ $number -eq 0 ]; then
                        # 若当前位置左边尚有字符，则将当前位置左移一个字符
                        if [ $cur_column -gt 1 ]; then
                            cur_column=$(($cur_column-1))
                        # 若当前位置左边无字符且不为第一行，则将当前位置移到上一行
                        elif [ $cur_line -gt 1 ]; then
                            cur_line=$(($cur_line-1))
                            cur_column=${char_line[$cur_line]}
                        fi
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                    else # 若之前输入其他数字，则向后移动指定字符数
                        # 循环移动指定字符数
                        while [ $number -gt 0 ]; do
                            # 若当前位置右边尚有字符，则将当前位置右移指定字符数
                            if [ $cur_column -gt 1 ]; then
                                cur_column=$(($cur_column-1))
                            # 若当前位置左边无字符且不为第一行，则将当前位置移到上一行
                            elif [ $cur_line -gt 1 ]; then
                                cur_line=$(($cur_line-1))
                                cur_column=${char_line[$cur_line]}
                            fi
                            # 将待移动字符数减1
                            number=$(($number-1))
                        done
                        # 将光标移到当前位置
                        printf "\e[${cur_line};${cur_column}H"
                    fi
                    ;;
                "d") # 剪切若干行
                    # 继续读取输入
                    read -n 1 -s key
                    # 若仍读取到d则进行操作
                    case $key in
                    "d")
                        # 若之前未输入其他数字
                        if [ $number -eq 0 ]; then
                            # 拷贝当前所在行到剪切板
                            copy=`sed -n "${cur_line}p" .temp_file_of_myvim`
                            # 删除当前所在行
                            sed -i "${cur_line}d" .temp_file_of_myvim
                            # 更新每行字符数
                            for ((i=$cur_line;i<$num_line;i++)); do
                                char_line[$i]=${char_line[$((i+1))]}
                            done
                            # 更新行数
                            unset char_line[$num_line]
                            # 更新当前行
                            num_line=$(($num_line-1))
                            # 若当前行溢出，则将其移到最后一行
                            if [ $cur_line -gt $num_line ]; then
                                cur_line=$num_line
                            fi
                            # 将当前列设为1
                            cur_column=1
                            # 刷新屏幕显示内容
                            refresh_screen
                        else
                            # 计算需要删除的最后一行
                            lastline=$((cur_line+number-1))
                            # 防止溢出
                            if [ lastline -gt num_line ] ; then
                                lastline=num_line
                            fi
                            # 计算防止溢出后需要删除的行数
                            num_change_line=$((lastline-cur_line+1))
                            # 拷贝对应行到剪切板
                            copy=`sed -n "${cur_line},${lastline}p" .temp_file_of_myvim`
                            # 删除对应行
                            sed -i "${cur_line},${lastline}d" .temp_file_of_myvim
                            # 更新每行字符数
                            for ((i=$cur_line;i<=$((num_line-number_change_line));i++)); do
                                char_line[$i]=${char_line[$((i+num_change_line))]}
                            done
                            # 更新每行字符数
                            for ((i=$((num_line-number_change_line+1));i<=$num_lines;i++)); do
                                unset char_line[$i]
                            done
                            # 更新行数
                            num_line=$(($num_line-$num_change_line))
                            # 若当前行溢出，则将其移到最后一行
                            if [ $cur_line -gt $num_line ]; then
                                cur_line=$num_line
                            fi
                            # 将当前列设为1 
                            cur_column=1
                            # 刷新屏幕显示内容  
                            refresh_screen
                            # 将辅助计数变量重置
                            number=0
                        fi
                        ;;
                    esac
                    ;;
                "y") # 拷贝若干行
                    # 继续读取输入
                    read -n 1 -s key
                    # 若仍读取到y则进行操作
                    case $key in
                    "y")
                        # 若之前未输入其他数字
                        if [ $number -eq 0 ]; then
                            # 拷贝当前所在行到剪切板
                            copy=`sed -n "${cur_line}p" .temp_file_of_myvim`
                        else # 若之前输入了其他数字
                            # 计算需要拷贝的最后一行
                            lastline=$((cur_line+number-1))
                            # 防止溢出
                            if [ $lastline -gt $num_line ] ; then
                                lastline=$num_line
                            fi
                            # 拷贝对应行到剪切板
                            copy=`sed -n "${cur_line},${lastline}p" .temp_file_of_myvim`
                            # 重置辅助计数变量
                            number=0
                        fi
                        ;;
                    esac
                    ;;
                "p") # 在下一行粘贴剪贴板内容
                    # 使用临时变量记录粘贴行数
                    temp_line=$cur_line
                    # 保存旧的分隔符设置
                    OLD_IFS="$IFS"
                    # 将输入分隔符设置为回车
                    IFS=$'\n'
                    # 逐行处理粘贴内容
                    for line in $copy; do
                        # 在下一行插入粘贴内容
                        sed "$temp_line a$line" -i .temp_file_of_myvim
                        # 将粘贴行移到下一行
                        temp_line=$(($temp_line+1))
                    done
                    # 恢复旧的分隔符设置
                    IFS="$OLD_IFS"
                    # 将当前位置下移一行
                    cur_line=$(($cur_line+1))
                    # 将当前列移到第一列
                    cur_column=1
                    # 刷新屏幕显示内容
                    refresh_screen
                    ;;
                "P") # 在上一行粘贴剪贴板内容
                    # 使用临时变量记录粘贴行数
                    temp_line=$cur_line
                    # 保存旧的分隔符设置
                    OLD_IFS="$IFS"
                    # 将输入分隔符设置为回车
                    IFS=$'\n'
                    # 逐行处理粘贴内容
                    for line in $copy; do
                        # 在下一行插入粘贴内容
                        sed "$temp_line i$line" -i .temp_file_of_myvim
                        # 将粘贴行移到下一行
                        temp_line=$(($temp_line+1))
                    done
                    # 恢复旧的分隔符设置
                    IFS="$OLD_IFS"
                    # 将当前列移到第一列
                    cur_column=1
                    # 刷新屏幕显示内容
                    refresh_screen
                    ;;
                "i") # 插入模式
                    # 打印插入模式提示信息
                    print_insert_info
                    # 切换为插入模式
                    mode="insert"
                    ;;
                "a") # 插入模式(从后一个字符开始插入)
                    # 若当前行不为空行，则将光标往后移一个字符
                    if [ ${char_line[$cur_line]} -gt 0 ]; then
                        cur_column=$(($cur_column+1))
                    fi
                    # 打印插入模式提示信息
                    print_insert_info
                    # 切换为插入模式
                    mode="insert"
                    ;;
                "o") # 插入模式(从下一行开始插入)
                    # 在当前行后插入一行空行
                    sed "${cur_line}a${cENTER}" -i .temp_file_of_myvim
                    # 将当前行移到下一行
                    cur_line=$((cur_line+1))
                    # 将当前列移到第一列
                    cur_column=1
                    # 将文件总行数+1
                    num_line=$((num_line+1))
                    # 更新各行字符数量
                    for ((i=$((num_line-1));i>=$cur_line;i--)); do
                        char_line[$((i+1))]=${char_line[$i]}
                    done
                    # 将当前行置空
                    char_line[$cur_line]=0
                    # 打印插入模式提示信息
                    print_insert_info
                    # 切换为插入模式
                    mode="insert"
                    ;;
                "O") # 插入模式(从上一行开始插入)
                    # 在当前行前插入一行空行
                    sed "${cur_line}i${cENTER}" -i .temp_file_of_myvim
                    # 将当前列移到第一列
                    cur_column=1
                    # 将文件总行数+1
                    num_line=$((num_line+1))
                    # 更新各行字符数量
                    for ((i=$((num_line-1));i>=$cur_line;i--)); do
                        char_line[$((i+1))]=${char_line[$i]}
                    done
                    # 将当前行置空
                    char_line[$cur_line]=0
                    # 打印插入模式提示信息
                    print_insert_info
                    # 切换为插入模式
                    mode="insert"
                    ;;
                "r") # 替换单个字符
                    # 打印替换提示信息
                    print_replace_info
                    # 读取需要替换的字符
                    read -n 1 -s char
                    # 仅在当前行存在字符时进行替换
                    if [ ${char_line[cur_line]} -gt 0 ]; then
                        # 使用awk删除将当前位置字符替换为输入的字符
                        awk -v FS="" -v OFS="" '{ 
                            if ("'"$cur_line"'" == NR) {
                                gsub(/.*/, "'"$char"'", $"'"$cur_column"'")
                            }
                            print > ".temp_file_of_myvim"
                        }' .temp_file_of_myvim
                        # 刷新屏幕显示内容
                        refresh_screen
                    fi
                    ;;
                "R") # 替换多个字符
                    print_replace_info
                    # 将模式切换为替换模式
                    mode="replace"
                    ;;
                "k") # 向上移动
                    if [ $cur_line -gt 1 ]; then
                        cur_line=$((cur_line-1))
                        # 若当前行为空行，则手动将当前位置置为1
                        if [ ${char_line[$((cur_line+1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                            cur_column=1
                        # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                        elif [ ${char_line[$cur_line]} -lt $cur_column ]; then
                            cur_column=${char_line[$cur_line]}
                            # 若当前行为空行，则手动将当前位置置为1
                            if [ $cur_column -eq 0 ]; then
                                cur_column=1
                            fi
                        fi
                        printf "\e[${cur_line};${cur_column}H"
                    fi   # 如果当前行不是第一行，则向上移动一行
                    ;;
                "j") # 向下移动
                    # 如果当前行不是最后一行，则向下移动一行
                    if [ $cur_line -lt $num_line ]; then
                        # 将行数设置为下一行
                        cur_line=$((cur_line+1))
                        # 若当前行为空行，则手动将当前位置置为1
                        if [ ${char_line[$((cur_line-1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                            cur_column=1
                        # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                        elif [ ${char_line[$cur_line]} -lt $cur_column ]; then
                            cur_column=${char_line[$cur_line]}
                            # 若当前行为空行，则手动将当前位置置为1
                            if [ $cur_column -eq 0 ]; then
                                cur_column=1
                            fi
                        fi
                        printf "\e[${cur_line};${cur_column}H"
                    fi   
                    ;;
                "l") # 向右移动
                    # 如果当前列不是最后一列，则向右移动一列
                    if [ $cur_column -lt ${char_line[$cur_line]} ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                        cur_column=$((cur_column+1)) 
                        printf "\e[${cur_line};${cur_column}H"
                    fi
                    ;;
                "h") # 向左移动
                    # 如果当前列不是第一列，则向左移动一列
                    if [ $cur_column -gt 1 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                        cur_column=$((cur_column-1))
                        printf "\e[${cur_line};${cur_column}H"
                    fi
                    ;;
                $cESC) # 如果输入的是ESC
                    # 判断是否是ESC[按键码
                    read -sn1 -t 0.01 key
                    # 如果是ESC[按键码，则继续判断按下的方向键
                    if [[ "$key" == "[" ]] ; then
                        read -sn1 -t 0.01 key
                        case $key in
                            A) # 上键
                                if [ $cur_line -gt 1 ]; then
                                    cur_line=$((cur_line-1))
                                    # 若当前行为空行，则手动将当前位置置为1
                                    if [ ${char_line[$((cur_line+1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                        cur_column=1
                                    # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                                    elif [ ${char_line[$cur_line]} -lt $cur_column ]; then
                                        cur_column=${char_line[$cur_line]}
                                        # 若当前行为空行，则手动将当前位置置为1
                                        if [ $cur_column -eq 0 ]; then
                                            cur_column=1
                                        fi
                                    fi
                                    printf "\e[${cur_line};${cur_column}H"
                                fi   # 如果当前行不是第一行，则向上移动一行
                                ;;
                            B) # 下键
                                # 如果当前行不是最后一行，则向下移动一行
                                if [ $cur_line -lt $num_line ]; then
                                    # 将行数设置为下一行
                                    cur_line=$((cur_line+1))
                                    # 若当前行为空行，则手动将当前位置置为1
                                    if [ ${char_line[$((cur_line-1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                        cur_column=1
                                    # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                                    elif [ ${char_line[$cur_line]} -lt $cur_column ]; then
                                        cur_column=${char_line[$cur_line]}
                                        # 若当前行为空行，则手动将当前位置置为1
                                        if [ $cur_column -eq 0 ]; then
                                            cur_column=1
                                        fi
                                    fi
                                    printf "\e[${cur_line};${cur_column}H"
                                fi   
                                ;;
                            C) # 右键
                                # 如果当前列不是最后一列，则向右移动一列
                                if [ $cur_column -lt ${char_line[$cur_line]} ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                    cur_column=$((cur_column+1)) 
                                    printf "\e[${cur_line};${cur_column}H"
                                fi
                                ;;
                            D) # 左键
                                # 如果当前列不是第一列，则向左移动一列
                                if [ $cur_column -gt 1 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                    cur_column=$((cur_column-1))
                                    printf "\e[${cur_line};${cur_column}H"
                                fi
                                ;;
                        esac
                    fi
                    ;;
                *) # 其他字符
                    ;;
            esac
            ;;
        "insert") # 插入模式
            # 保存旧的分隔符设置
            OLD_IFS="$IFS"
            # 将输入分隔符设置为回车
            IFS=$'\n'
            # 获取输入(无回显且单字符相应)
            read -n 1 -s cmd
            # 还原分隔符设置
            IFS=$OLD_IFS
            # 分析输入命令
            case $cmd in
                $cESC) # 如果输入的是ESC
                    # 判断是否是ESC[按键码
                    read -sn1 -t 0.01 key
                    # 如果是ESC[按键码，则继续判断按下的方向键
                    if [[ "$key" == "[" ]] ; then
                        read -sn1 -t 0.01 key
                        case $key in
                            A) # 上键
                                if [ $cur_line -gt 1 ]; then
                                    cur_line=$((cur_line-1))
                                    # 若当前行为空行，则手动将当前位置置为1
                                    if [ ${char_line[$((cur_line+1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                        cur_column=1
                                    # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                                    elif [ $((${char_line[$cur_line]}+1)) -lt $cur_column ]; then
                                        cur_column=$((${char_line[$cur_line]}+1))
                                        # 若当前行为空行，则手动将当前位置置为1
                                        if [ $cur_column -eq 0 ]; then
                                            cur_column=1
                                        fi
                                    fi
                                    printf "\e[${cur_line};${cur_column}H"
                                fi   # 如果当前行不是第一行，则向上移动一行
                                ;;
                            B) # 下键
                                # 如果当前行不是最后一行，则向下移动一行
                                if [ $cur_line -lt $num_line ]; then
                                    # 将行数设置为下一行
                                    cur_line=$((cur_line+1))
                                    # 若当前行为空行，则手动将当前位置置为1
                                    if [ ${char_line[$((cur_line-1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                        cur_column=1
                                    # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                                    elif [ $((${char_line[$cur_line]}+1)) -lt $cur_column ]; then
                                        cur_column=$((${char_line[$cur_line]}+1))
                                        # 若当前行为空行，则手动将当前位置置为1
                                        if [ $cur_column -eq 0 ]; then
                                            cur_column=1
                                        fi
                                    fi
                                    printf "\e[${cur_line};${cur_column}H"
                                fi   
                                ;;
                            C) # 右键
                                # 如果当前列不是最后一列，则向右移动一列
                                if [ $cur_column -lt $((${char_line[$cur_line]}+1)) ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                    cur_column=$((cur_column+1)) 
                                    printf "\e[${cur_line};${cur_column}H"
                                fi
                                ;;
                            D) # 左键
                                # 如果当前列不是第一列，则向左移动一列
                                if [ $cur_column -gt 1 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                    cur_column=$((cur_column-1))
                                    printf "\e[${cur_line};${cur_column}H"
                                fi
                                ;;
                        esac
                    else # 如果不是ESC[按键码，则认为是ESC
                        # 若当前光标位置在最后一个字符后
                        # 且当前行不为空行，则将光标移动到最后一个字符
                        if [ ${char_line[cur_line]} -lt $cur_column ] \
                        && [ ${char_line[cur_line]} -gt 0 ]; then
                            cur_column=$((cur_column-1))
                        fi
                        # 切换为命令模式
                        mode="command"
                        # 刷新屏幕内容
                        refresh_screen
                    fi
                    ;;
                "") # 如果输入的是退格键
                    # 在当前位置大于1时，删除当前位置前一个字符
                    if [ $cur_column -gt 1 ]; then
                        # 在第$cur_line行第$cur_column个字符处删除一个字符
                        awk -v FS="\n" -v OFS="" '{ 
                            if ('"$cur_line"' == NR) {
                                del=substr($1,1,'"$cur_column"'-2)
                                sub(/.{'"$((cur_column-1))"'}/, del, $1)
                            }
                            print > ".temp_file_of_myvim"
                        }' .temp_file_of_myvim
                        # 将当前行的字符数-1
                        char_line[$cur_line]=$((char_line[$cur_line]-1))
                        # 将当前所在字符位置-1
                        cur_column=$((cur_column-1))
                        # 刷新并打印插入模式提示信息
                        print_insert_info
                    fi
                    ;;
                " ") # 在当前位置插入空格
                    # 空格需要单独考虑，否则在bash变量$cmd传入时会被忽略
                    # 在第$cur_line行第$cur_column个字符处插入空格
                    awk -v FS="\n" -v OFS="" '{ 
                        if ('"$cur_line"' == NR) {
                            old=substr($1,1,'"$cur_column"'-1)
                            new=old" "
                            sub(/.{'"$((cur_column-1))"'}/, new, $1)
                        }
                        print > ".temp_file_of_myvim"
                    }' .temp_file_of_myvim
                    # 将当前行的字符数+1
                    char_line[$cur_line]=$((char_line[$cur_line]+1))
                    # 将当前所在字符位置+1
                    cur_column=$((cur_column+1))
                    # 刷新并打印插入模式提示信息
                    print_insert_info
                    ;;

                *) # 在当前位置插入新字符
                    # 在第$cur_line行第$cur_column个字符处插入新字符$cmd
                    awk -v FS="\n" -v OFS="" '{ 
                        if ('"$cur_line"' == NR) {
                            old=substr($1,1,'"$cur_column"'-1)
                            new=old"'$cmd'"
                            sub(/.{'"$((cur_column-1))"'}/, new, $1)
                        }
                        print > ".temp_file_of_myvim"
                    }' .temp_file_of_myvim
                    # 将当前行的字符数+1
                    char_line[$cur_line]=$((char_line[$cur_line]+1))
                    # 将当前所在字符位置+1
                    cur_column=$((cur_column+1))
                    # # 刷新屏幕内容
                    # refresh_screen
                    # 打印插入模式提示信息
                    print_insert_info
                    ;;
            esac
            ;;
        "lastline")
            read cmd
            case $cmd in
                "q") # 退出
                    # 若文件未改动，则直接退出
                    if diff $file .temp_file_of_myvim > /dev/null; then
                        # 删除临时文件
                        rm .temp_file_of_myvim
                        # 将光标移到原先行列位置
                        printf "\e[${cur_line};${cur_column}H"
                        # 重置字符属性
                        printf "\e[0m"
                        # 退出主循环
                        break;
                    else # 若文件已改动，则报错提示
                        # 返回命令模式
                        mode="command"
                        # 输出错误提示信息
                        print_error_info "ERROR：文件存在改动！请保存后退出！"
                        # 重置字符属性
                        printf "\e[0m"
                    fi
                    ;;
                "q!") # 不保存修改，直接退出
                    # 删除临时文件
                    rm .temp_file_of_myvim
                    # 将光标移到原先行列位置
                    printf "\e[${cur_line};${cur_column}H"
                    # 重置字符属性
                    printf "\e[0m"
                    # 退出主循环
                    break;
                    ;;
                "w") # 保存修改
                    # 重置字符属性
                    printf "\e[0m"
                    # 将临时文件保存到原文件中
                    cat .temp_file_of_myvim > $file
                    # 刷新屏幕内容
                    refresh_screen
                    # 切换到命令模式
                    mode="command"
                    ;;
                "wq") # 保存修改并退出
                    # 将临时文件保存到原文件中
                    cat .temp_file_of_myvim > $file
                    # 删除临时文件
                    rm .temp_file_of_myvim
                    # 重置字符属性
                    printf "\e[0m"
                    # 清屏
                    printf "\e[2J"
                    # 退出主循环
                    break;
                    ;;
                "e!") # 放弃对文件的所有修改，恢复文件到上次保存的位置。
                    # 重新读取上次保存的文件
                    cat $file > .temp_file_of_myvim
                    # 将当前行置为1
                    cur_line=1
                    # 将当前列置为1
                    cur_column=1
                    # 重置字符属性
                    printf "\e[0m"
                    # 刷新屏幕内容
                    refresh_screen
                    # 重新获取文件信息
                    get_line_info
                    # 将模式置为命令模式
                    mode="command"
                    ;;
                $cESC) # 如果按下ESC，则回到命令模式
                    # 重置字符属性
                    printf "\e[0m"
                    # 刷新屏幕内容
                    refresh_screen
                    # 将模式置于命令模式
                    mode="command"
                    ;;
                *) # 其他按键，则输出错误提示信息
                    # 返回命令模式
                    mode="command"
                    # 输出错误提示信息
                    print_error_info "ERROR：非法指令！"
                    # 重置字符属性
                    printf "\e[0m"
                    ;;
            esac
            ;;
        "replace") # 替换模式
            # 读取命令
            read -n 1 -s cmd
            # 判断按键
            case $cmd in
                $cESC) # 如果输入的是ESC
                    # 判断是否是ESC[按键码
                    read -sn1 -t 0.01 key
                    # 如果是ESC[按键码，则继续判断按下的方向键
                    if [[ "$key" == "[" ]] ; then
                        read -sn1 -t 0.01 key
                        case $key in
                            A) # 上键
                                if [ $cur_line -gt 1 ]; then
                                    cur_line=$((cur_line-1))
                                    # 若当前行为空行，则手动将当前位置置为1
                                    if [ ${char_line[$((cur_line+1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                        cur_column=1
                                    # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                                    elif [ $((${char_line[$cur_line]}+1)) -lt $cur_column ]; then
                                        cur_column=$((${char_line[$cur_line]}+1))
                                        # 若当前行为空行，则手动将当前位置置为1
                                        if [ $cur_column -eq 0 ]; then
                                            cur_column=1
                                        fi
                                    fi
                                    printf "\e[${cur_line};${cur_column}H"
                                fi   # 如果当前行不是第一行，则向上移动一行
                                ;;
                            B) # 下键
                                # 如果当前行不是最后一行，则向下移动一行
                                if [ $cur_line -lt $num_line ]; then
                                    # 将行数设置为下一行
                                    cur_line=$((cur_line+1))
                                    # 若当前行为空行，则手动将当前位置置为1
                                    if [ ${char_line[$((cur_line-1))]} -eq 0 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                        cur_column=1
                                    # 若当前行数字符数小于当前位置，则将当前位置设置为最后一个字符
                                    elif [ $((${char_line[$cur_line]}+1)) -lt $cur_column ]; then
                                        cur_column=$((${char_line[$cur_line]}+1))
                                        # 若当前行为空行，则手动将当前位置置为1
                                        if [ $cur_column -eq 0 ]; then
                                            cur_column=1
                                        fi
                                    fi
                                    printf "\e[${cur_line};${cur_column}H"
                                fi   
                                ;;
                            C) # 右键
                                # 如果当前列不是最后一列，则向右移动一列
                                if [ $cur_column -lt $((${char_line[$cur_line]}+1)) ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                    cur_column=$((cur_column+1)) 
                                    printf "\e[${cur_line};${cur_column}H"
                                fi
                                ;;
                            D) # 左键
                                # 如果当前列不是第一列，则向左移动一列
                                if [ $cur_column -gt 1 ] && [ ${char_line[$cur_line]} -gt 0 ]; then
                                    cur_column=$((cur_column-1))
                                    printf "\e[${cur_line};${cur_column}H"
                                fi
                                ;;
                        esac
                    else # 如果不是ESC[按键码，则认为是ESC
                        # 若当前光标位置在最后一个字符后
                        # 且当前行不为空行，则将光标移动到最后一个字符
                        if [ ${char_line[cur_line]} -lt $cur_column ] \
                        && [ ${char_line[cur_line]} -gt 0 ]; then
                            cur_column=$((cur_column-1))
                        fi
                        # 切换为命令模式
                        mode="command"
                        # 刷新屏幕内容
                        refresh_screen
                    fi
                    ;;
                "") # 如果输入的是退格键
                    # 在当前位置大于1时，删除当前位置前一个字符
                    if [ $cur_column -gt 1 ]; then
                        # 在第$cur_line行第$cur_column个字符处删除一个字符
                        awk -v FS="\n" -v OFS="" '{ 
                            if ('"$cur_line"' == NR) {
                                del=substr($1,1,'"$cur_column"'-2)
                                sub(/.{'"$((cur_column-1))"'}/, del, $1)
                            }
                            print > ".temp_file_of_myvim"
                        }' .temp_file_of_myvim
                        # 将当前行的字符数-1
                        char_line[$cur_line]=$((char_line[$cur_line]-1))
                        # 将当前所在字符位置-1
                        cur_column=$((cur_column-1))
                        # 刷新并打印替换模式提示信息
                        print_replace_info
                    fi
                    ;;
                *) # 其他字符
                    # 在当前位置替换字符
                    awk -v FS="" -v OFS="" '{ 
                        if ("'"$cur_line"'" == NR) {
                            gsub(/.*/, "'"$cmd"'", $"'"$cur_column"'")
                        }
                        print > ".temp_file_of_myvim"
                    }' .temp_file_of_myvim
                    # 将当前所在字符位置向右移动一个字符
                    cur_column=$((cur_column+1))
                    # 若溢出，则增加当前行的字符数量
                    if [ $cur_column -gt $((${char_line[$cur_line]}+1)) ]; then
                        char_line[$cur_line]=$((${char_line[$cur_line]}+1))
                    fi
                    # 刷新并打印替换模式提示信息
                    print_replace_info
                    ;;
            esac
            ;;
    esac
done

# 清屏
clear
