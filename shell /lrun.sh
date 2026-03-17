## lrun
## ./lrun ip_hdfs "scp filename.txt %VAR%:/tmp/."

#!/bin/sh

if [ "${2}" = "" ];then
   echo "Title  : Local Run"
   echo "Explain: lrun machine_List command"
   echo ""
   echo "Date   : 2018-11-15"
   echo "Author : adaM(lds@tom.com)"
   exit 0
fi

MS=${1}
CS="${2}"

for MLIST in `cat ${MS}`
do
   echo '--- Run --- : ' ${CS/\%VAR\%/${MLIST}}
   ${CS/\%VAR\%/${MLIST}}
done

exit 1
