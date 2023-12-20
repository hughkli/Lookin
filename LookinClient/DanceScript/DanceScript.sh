#!/bin/bash

# 二进制产物路径
build_path=$1
# 跳转的方法名，DanceUI 主要有两类：View.body、ViewModifier.body(content:)
subprogram_name=$3

root_path="$(dirname "$0")"
echo $root_path

process_string() {
    local original="$1"
    # 删除 "<>" 及其内部的所有内容
    local step1=$(
        echo $original | \
        perl -p -e 's/(<([^<>]|(?1))*>)*//g'
    )
    # 删除括号中的第一个单词以外的所有内容，并去掉括号
    local step2=$(echo "$step1" | sed -E 's/([^ ]+)[^)]*/\1/g')
    # 如果括号中的单词是 "unknown"，就删除括号及其内容
    local cleanType=$(echo "$step2" | sed -e 's/(//g' -e 's/)//g' -e 's/unknown//g')

    local -a arr=() #定义数组

    # 通过 . 将cleanType分割，并过滤掉空元素
    for word in ${cleanType//./ }; do
        if [[ -n $word ]]; then
            arr+=("$word")
        fi
    done

    # 输出数组元素
    echo "${arr[@]}"
}

# 类型名转换(用于符号检查)：DanceUIApp.ContentView.(unknown context at $10628778c).TestTypeView<Int> -> [DanceUIApp, ContentView, TestTypeView]
# 类型名：TestTypeView
read -a structure_name_array <<< "$(process_string "$2")"
echo "${structure_name_array[@]}"
last_index=$(( ${#structure_name_array[@]}-1 ))
structure_name=${structure_name_array[$last_index]}
echo $structure_name

# 二进制文件时间戳，唯一标识
file_creation_time=$(stat -f "%B" "${build_path}")
echo $file_creation_time

# 工程名
filename=$(basename "$build_path")
echo $filename

file_path="${root_path}/temp/${filename}"
dir_path="$file_path/${file_creation_time}"

# 创建目录: /temp/DanceUIApp/1702555003/
if [ -d ${file_path} ]; then
    if [ ! -d ${dir_path} ]; then
        rm -r ${file_path}
        mkdir -p $dir_path
    fi
else
    mkdir -p $dir_path
fi

dsym_file_name="${dir_path}/DanceUIViewDebug_${filename}_${file_creation_time}.dSYM"
echo $dsym_file_name

# 检查 dSYM 文件： /temp/DanceUIApp/1702555003/DanceUIViewDebug_DanceUIApp_1702555003.dSYM
if [ -d ${dsym_file_name} ]; then
    echo "File ${dsym_file_name} exists."
else
    # dsymutil 通过二进制产物生成对应的 dSYM 文件，用于存储源码调试信息
    dsymutil ${build_path} -o ${dsym_file_name}
    echo "File ${dsym_file_name} does not exist."
fi

result_path="${dir_path}/$structure_name.txt"

# 检查符号查找文件：/temp/DanceUIApp/1702555003/xxx.txt
if [ ! -f ${result_path} ]; then
    # dwarfdump 通过 dSYM 文件查找对应的源码调试信息
    dwarfdump --name $structure_name ${dsym_file_name} -c > ${result_path}
fi

# 类型源码查找：ContentView.body

found_contentview=false
in_bodyget=false
linkage_type_name_match=false
declare -a result
while IFS= read -r line; do

    # 检查类型名: DW_AT_name    ("ContentView")
    if [[ "$line" == *"DW_AT_name"* ]]; then
        if [[ $line == *"${structure_name}"* ]]; then
            echo $line
            found_contentview=true
        fi
    fi
  
    # 检查方法符号：DW_AT_linkage_name    ("$s10DanceUIApp11ContentViewV4bodyQrvg")
    if $found_contentview && [[ "$line" == *"DW_AT_linkage_name"* ]]; then
        echo $line
        all_in_str=true
        for item in "${structure_name_array[@]}"; do
            if [[ $line != *$item* ]]; then
                all_in_str=false
                break
            fi
        done

        if [ "$all_in_str" = true ]; then
            linkage_type_name_match=true
            echo $line
        fi
    fi

    # 检查方法名：DW_AT_name    ("body.get")
    if $found_contentview && [[ "$line" == *"DW_AT_name"* ]]; then
        if [[ $line == *"${subprogram_name}"* ]]; then
            echo $line
            in_bodyget=true
        fi
    fi

    # 满足条件的源文件路径：DW_AT_decl_file    ("/Users/bytedance/chenyi/DanceUI/DanceUI/Example/DanceUIApp/ContentView.swift")
    if $in_bodyget && $linkage_type_name_match && [[ "$line" == *"DW_AT_decl_file"* ]]; then
        file=$(echo "$line" | cut -d '"' -f 2)  # Extract file name from the line
        echo $line
        result[0]=$file
    fi

    # 满足条件的源文件行号：DW_AT_decl_line    (6)
    if $in_bodyget && $linkage_type_name_match && [[ "$line" == *"DW_AT_decl_line"* ]]; then
        line_number=$(echo "$line" | sed 's/[^0-9]*//g')  # Extract line number from the line
        echo $line
        result[1]=$line_number
        break
    fi
done < ${result_path}

# Open xed editor with file name and line number
if [ ${#result[@]} -eq 2 ]; then
    xed --line ${result[1]} ${result[0]}
else
    echo "Cannot find file name and line number."
fi
