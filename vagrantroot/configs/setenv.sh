#!/bin/sh

JAVA_OPTS="$JAVA_OPTS -Xms256m -Xmx512m -XX:MaxPermSize=128m ";
export JAVA_OPTS;

CATALINA_OPTS="$CATALINA_OPTS -javaagent:/var/www/sites/default/WEB-INF/lib/lucee-inst.jar ";
export CATALINA_OPTS;
