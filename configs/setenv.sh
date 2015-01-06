#!/bin/sh

JAVA_OPTS="$JAVA_OPTS -Xms256m -Xmx512m -XX:MaxPermSize=128m ";
export JAVA_OPTS;

CATALINA_OPTS="$CATALINA_OPTS -Djava.library.path=/webroot/WEB-INF/lib -Djava.library.path=/webroot/WEB-INF/railo/lib -javaagent:/sites/webroot/WEB-INF/lib/railo-inst.jar ";
export CATALINA_OPTS;
