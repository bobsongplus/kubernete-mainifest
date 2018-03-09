#!/bin/bash
echo '*==========================================================*'
echo '|  本脚本工具基于ab(Apache benchmark)，请先安装好ab, awk   |'
echo '|  注意：                                                  |'
echo '|     shell默认最大客户端数为1024                          |'
echo '|     如超出此限制，请使用管理员执行以下命令：             |'
echo '|     ulimit -n 655350                                 |'
echo '*==========================================================*'

function usage() {
    echo '  命令格式：'
    echo '  ab-test-tools.sh'
    echo '      -N|--count 总请求数，缺省 : 5w'
    echo '      -C|--clients 并发数, 缺省 : 100'
    echo '      -R|--rounds 测试次数, 缺省 : 10 次'
    echo '      -S|-sleeptime 间隔时间, 缺省 : 10 秒'
    echo '      -I|--min 最小并发数,　缺省: 0'
    echo '      -X|--max 最大并发数，缺省: 0'
    echo '      -J|--step 次递增并发数'
    echo '      -T|--runtime 总体运行时间,设置此项时最大请求数为5w'
    echo '      -P|--postfile post数据文件路径'
    echo '      -U|--url 测试地址'
    echo ''
    echo '  测试输出结果*.out文件'

    exit;
}


# 定义默认参数量
# 总请求数
count=50000
# 并发数
clients=100O
# 测试轮数
rounds=10
# 间隔时间
sleeptime=10
# 最小并发数
min=0
# 最大数发数
max=0
# 并发递增数
step=0
# 测试地址
url=''
# 测试限制时间
runtime=0
# 传输数据
postfile=''


ARGS=`getopt -a -o N:C:R:S:I:X:J:U:T:P:h -l count:,client:,round:,sleeptime:,min:,max:,step:,runtime:,postfile:,help -- "$@"`
[ $? -ne 0 ] && usage
eval set -- "${ARGS}"

while true
do
    case "$1" in
    -N|--count)
        count="$2"
        shift
        ;;

    -C|--client)
        clients="$2"
        shift
        ;;

    -R|--round)
        rounds="$2"
        shift
        ;;

    -S|--sleeptime)
        sleeptime="$2"
        shift
        ;;

    -I|--min)
        min="$2"
        shift
        ;;

    -X|--max)
        max="$2"
        shift
        ;;

    -J|--step)
        step="$2"
        shift
        ;;

    -U|--url)
        url="$2"
        shift
        ;;

    -T|--runtime)
        runtime="$2"
        shift
        ;;

    -P|--postfile)
        postfile="$2"
        shift
        ;;

    -h|--help)
        usage
        ;;

    --)
        shift
        break
        ;;
    esac
shift
done

# 参数检查
if [ x$url = x ]
then
    echo '请输入测试url，非文件/以为结束'
    exit
fi

flag=0
if [ $min != 0 -a $max != 0 ]
then
    if [ $max -le $min ]
    then
        echo '最大并发数不能小于最小并发数'
        exit
    fi

    if [ $step -le 0 ]
    then
        echo '并发递增步长不能<=0'
        exit
    fi

    if [ $min -lt $max ]
    then
        flag=1
    fi
fi


# 生成ab命令串
cmd="ab -k -r"

#　数据文件
if [ x$postf != x ]
then
    cmd="$cmd -p $postf"
fi

if [ x$tl != x -a $tl != 0 ]
then
    max=50000;
    cmd="$cmd -t$tl"
fi
cmd="$cmd -n$count"

echo '-----------------------------';
echo '测试参数';
echo "  总请求数：$count";
echo "  并发数：$clients";
echo "  重复次数：$rounds 次";
echo "  间隔时间：$sleeptime 秒";
echo "  测试地址：$url";

if [ $min != 0 ];then
echo "  最小并发数：$min";
fi

if [ $max != 0 ];then
echo "  最大并发数：$max";
fi

if [ $step != 0 ];then
echo " 每轮并发递增：$step"
fi


# 指定输出文件名
datestr=`date +%Y%m%d%H%I%S`
outfile="$datestr.out";

# runtest $cmd $outfile $rounds $sleeptime
function runtest() {
    # 输出命令
    echo "";
    echo '  当前执行命令：'
    echo "  $cmd"
    echo '------------------------------'

    # 开始执行测试
    cnt=1
    while [ $cnt -le $rounds ];
    do
        echo "第 $cnt 轮 开始"
        $cmd >> $outfile
        echo "\n\n" >> $outfile
        echo "第 $cnt 轮 结束"
        echo '----------------------------'

        cnt=$(($cnt+1))

        if [ $cnt -le $rounds ]; then
            echo "等待 $sleeptime 秒"
            sleep $sleeptime
        fi
    done
}


temp=$cmd;
if [ $flag != 0 ]; then
    cur=$min
    over=0
    while [ $cur -le $max ]
    do
        cmd="$temp -c$cur $url"
        runtest $cmd $outfile $rounds $sleeptime

        cur=$(($cur+$step))
        if [ $cur -ge $max -a $over != 1 ]; then
           cur=$max
           over=1
        fi
    done
else
    cmd="$cmd -c$clients $url"
    runtest $cmd $outfile $rounds $sleeptime
fi


# 分析结果
if [ -f $outfile ]; then
echo '本次测试结果如下：'
echo '+------+----------+----------+---------------+---------------+---------------+--------------------+--------------------+'
echo '| 序号 | 总请求数 |  并发数  |   失败请求数  |   每秒事务数  |  平均事务(ms) | 并发平均事务数(ms) |　  总体传输字节数  |'
echo '+------+----------+----------+---------------+---------------+---------------+--------------------+--------------------+'

comp=(`awk '/Complete requests/{print $NF}' $outfile`)
concur=(`awk '/Concurrency Level:/{print $NF}' $outfile`)
fail=(`awk '/Failed requests/{print $NF}' $outfile`)
qps=(`awk '/Requests per second/{print $4F}' $outfile`)
tpr=(`awk '/^Time per request:(.*)\(mean\)$/{print $4F}' $outfile`)
tpr_c=(`awk '/Time per request(.*)(mean, across all concurrent requests)/{print $4F}' $outfile`)
trate=(`awk '/Transfer rate/{print $3F}' $outfile`)

for ((i=0; i<${#comp[@]}; i++))
do
    echo -n "|"
    printf '%6s' $(($i+1))
    printf "|"

    printf '%10s' ${comp[i]}
    printf '|'

    printf '%10s' ${concur[i]}
    printf '|'

    printf '%15s' ${fail[i]}
    printf '|'

    printf '%15s' ${qps[i]}
    printf '|'

    printf '%15s' ${tpr[i]}
    printf '|'

    printf '%20s' ${tpr_c[i]}
    printf '|'

    printf '%20s' ${trate[i]}
    printf '|'

    echo '';
    echo '+-----+----------+----------+---------------+---------------+---------------+--------------------+--------------------+'
done
echo ''
fi
