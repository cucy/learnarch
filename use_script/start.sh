#!/bin/sh
IDENTIFIER=$1
PORT=$2
BASEDIR=`dirname $0`/..
BASEDIR=`(cd "$BASEDIR"; pwd)`
PROJECT_NAME="@project.artifactId@";
MAIN_CLASS="$PROJECT_NAME-@project.version@.jar";
ENCRYPT_KEY="9b2ee8c79a194f6354175f46d5407b1a";
LOG_PATH="/export/logs/www.credit.com/$PROJECT_NAME/"
GC_PATH=$LOG_PATH$PORT"-gc.log"
HS_ERR_PATH=$LOG_PATH$PORT"-hs_err.log"
HEAP_DUMP_PATH=$LOG_PATH$PORT"-heap_dump.hprof"
SUCCESS=0
FAIL=9

if [ ! -n "$IDENTIFIER" ]; then  
	echo $"Usage: $0 {identifier} {port}"
	exit $FAIL
fi

if [ ! -n "$PORT" ]; then 
	echo $"Usage: $0 {identifier} {port}"
	exit $FAIL
fi
if [ ! -d $LOG_PATH ]; 
then     
    mkdir -p $LOG_PATH; 
fi
if [ -z "$JAVACMD" ] ; then
  if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
      # IBM's JDK on AIX uses strange locations for the executables
      JAVACMD="$JAVA_HOME/jre/sh/java"
    else
      JAVACMD="$JAVA_HOME/bin/java"
    fi
  else
    JAVACMD=`which java > /dev/null 2>&1`
	echo  "Error: JAVA_HOME is not defined correctly."
    exit $ERR_NO_JAVA
  fi
fi

if [ ! -x "$JAVACMD" ] ; then
  echo "We cannot execute $JAVACMD"
  exit $ERR_NO_JAVA
fi

if [ -e "$BASEDIR" ]
then
  JAVA_OPTS="-Xms1024M -Xmx1024M -Xss256K -XX:+UseAdaptiveSizePolicy -XX:+UseParallelGC -XX:+UseParallelOldGC -XX:GCTimeRatio=39 -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$GC_PATH -XX:+HeapDumpOnOutOfMemoryError -XX:ErrorFile=$HS_ERR_PATH -XX:HeapDumpPath=$HEAP_DUMP_PATH"
fi

CLASSPATH=$CLASSPATH_PREFIX:
EXTRA_JVM_ARGUMENTS=""

cd "$BASEDIR/lib";

echo "starting application $PROJECT_NAME......"
exec "$JAVACMD" $JAVA_OPTS \
				$EXTRA_JVM_ARGUMENTS \
				-Dapp.name="$PROJECT_NAME" \
				-Dapp.port="$PORT" \
				-Dbasedir="$BASEDIR" \
				-jar $MAIN_CLASS \
				--project.identifier="$IDENTIFIER" \
				--server.port="$PORT" \
				--encrypt.key="$ENCRYPT_KEY" \
				"$@" > /dev/null &
				
for i in {1..60}
do
	jcpid=`ps -ef | grep -v "grep" | grep "$MAIN_CLASS" | grep "app.port=$PORT" | sed -n '1P' | awk '{print $2}'`
	if [ $jcpid ]; then
		echo "The $PROJECT_NAME start finished, PID is $jcpid"
		exit $SUCCESS
	else
		echo "starting the application .. $i"
		sleep 1
	fi
done
echo "$PROJECT_NAME start failure!"
