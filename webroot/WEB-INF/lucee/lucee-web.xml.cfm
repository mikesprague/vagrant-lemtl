<?xml version="1.0" encoding="UTF-8"?><!-- copy from Railo context --><cfLuceeConfiguration hspw="d65fbec83110f91519b3485759cfb13ee24bdbb5640ee4680c03f15b4bc16b86" pw="f76d0a69568e8afa331cc07973d31292f73500ec941a12614c22c16b0e5f7140" salt="1714DD27-3C96-422B-AB3BEB2D595511F0" version="4.5"><cfabort/>

<!-- 
Path placeholders:
	{lucee-web}: path to the railo web directory typical "{web-root}/WEB-INF/railo"
	{lucee-server}: path to the railo server directory typical where the railo.jar is located
	{lucee-config}: same as {lucee-server} in server context and same as {lucee-web} in web context}
	{temp-directory}: path to the temp directory of the current user of the system
	{home-directory}: path to the home directory of the current user of the system
	{web-root-directory}: path to the web root
	{system-directory}: path to thesystem directory
	{web-context-hash}: hash of the web context
-->
	
	
	
	
    <!--
    arguments:
		close-connection - 	write connection-close to response header
		suppress-whitespace	-	supress white space in response
		show-version - show railo version uin response header
	 -->
	<setting/>

<!--	definition of all database used inside your application. 										-->
<!--	above you can find some definition of jdbc drivers (all this drivers are included at railo) 	-->
<!--	for other database drivers see at: 																-->
<!--	 - http://servlet.java.sun.com/products/jdbc/drivers 											-->
<!--	 - http://sourceforge.net 																		-->
<!--	or ask your database distributor 																-->

	<data-sources>
	</data-sources>
	
	<resources>
    	<!--
        arguments:
		lock-timeout   - 	define how long a request wait for a lock
	 	-->
    	<resource-provider arguments="case-sensitive:true;lock-timeout:1000;" class="lucee.commons.io.res.type.ram.RamResourceProvider" scheme="ram"/>
    </resources>
    
    <remote-clients directory="{lucee-web}remote-client/"/>
	
	
	<!--
		deploy-directory - directory where java classes will be deployed
		custom-tag-directory - directory where the custom tags are
		tld-directory / fld-directory - directory where additional Function and Tag Library Deskriptor are.
		temp-directory - directory for temporary files (upload aso.)
	 -->
	<file-system deploy-directory="{lucee-web}/cfclasses/" fld-directory="{lucee-web}/library/fld/" temp-directory="{lucee-web}/temp/" tld-directory="{lucee-web}/library/tld/">
	</file-system>
	
	<!--
	scope configuration:
	
		cascading (expanding of undefined scope)
			- strict (argument,variables)
			- small (argument,variables,cgi,url,form)
			- standard (argument,variables,cgi,url,form,cookie)
			
		cascade-to-resultset: yes|no
			when yes also allow inside "output type query" and "loop type query" call implizid call of resultset
			
		merge-url-form:yes|no
			when yes all form and url scope are synonym for both data
		
		client-directory:path to directory where client scope values are stored
		client-directory-max-size: max size of the client scope directory
	-->
	<scope client-directory="{lucee-web}/client-scope/" client-directory-max-size="100mb"/>
		
	<mail>
	</mail>
	
	<!--
	define path to search directory
		directory: path
		engine-class: class that implement the Search Engine. Class must be subclass of railo.runtime.search.SearchEngine
	-->	
	<search directory="{lucee-web}/search/" engine-class="lucee.runtime.search.lucene.LuceneSearchEngine"/>
	
	<!--
	define path to scedule task directory
		directory: path
	-->	
	<scheduler directory="{lucee-web}/scheduler/"/>
	
	<mappings>
	<!--
	directory mapping:
		
		trusted: yes|no
			trusted cache -> recheck every time if there are changes in the called cfml file or not.
		virtual:
			virtual path of the application
			example: /somedir/
			
		physical: 
			physical path to the apllication
			example: d:/projects/app1/webroot/somedir/
			
		archive:
			path to a archive file:
			example: d:/projects/app1/rasfiles/somedir.ras
		primary: archive|physical
			define where railo first look for a called cfml file.
			for example when you define physical you can partiquel overwrite the archive.
		-->
		<mapping archive="{lucee-web}/context/lucee-context.lar" physical="{lucee-web}/context/" primary="physical" readonly="yes" toplevel="yes" trusted="true" virtual="/lucee/"/>
	</mappings>	
	
	<custom-tag>
		<mapping physical="{lucee-web}/customtags/" trusted="yes"/>
	</custom-tag>
	
	<ext-tags>
		<ext-tag class="lucee.cfx.example.HelloWorld" name="HelloWorld" type="java"/>
	</ext-tags>
	
	<!--
	component:
		
		base: 
			path to base component for every component that have no base component defined 
		data-member-default-access: remote|public|package|private
			access type of component data member (variables in this scope)
		use-shadow: if true component variable scope has a second scope, not only the this scope
	-->
	<component base="/lucee/Component.cfc" data-member-default-access="public" use-shadow="yes"> 
	</component>
	
	<!--
	regional configuration:
		
		locale: default: system locale
			define the locale 
		timezone: default:maschine configuration
			the ID for a TimeZone, either an abbreviation such as "PST", 
			a full name such as "America/Los_Angeles", or a custom ID such as "GMT-8:00". 
		timeserver: [example: swisstime.ethz.ch] default:local time
			dns of a ntp time server
	-->
	<regional/>
	
	<!--
		enable and disable debugging
	 -->
	<debugging template="/lucee/templates/debugging/debugging.cfm"/>
		
	<application cache-directory="{lucee-web}/cache/" cache-directory-max-size="100mb"/>
		
		
		
		
<!--
LOGGING
===========================

Possible Layouts:
- - - - - - - - - - - - - -

Classic: 
 Same layout as with Railo 1 - 4.1

HTML: 
a HTML table, possible arguments are 
- locationinfo (boolean): By default, it is set to false which means there will be no location information output by this layout. If the the option is set to true, then the file name and line number of the statement at the origin of the log statement will be output.
- title: The Title option takes a String value. This option sets the document title of the generated HTML document.

XML:
The output of the XMLLayout consists of a series of log4j:event elements as defined in the log4j.dtd. It does not output a complete well-formed XML file. The output is designed to be included as an external entity in a separate file to form a correct XML file.
- locationinfo (boolean): By default, it is set to false which means there will be no location information output by this layout. If the the option is set to true, then the file name and line number of the statement at the origin of the log statement will be output.
- properties: Sets whether MDC key-value pairs should be output, default false.

Pattern:
A flexible layout configurable with pattern string. 
- pattern: This is the string which controls formatting and consists of a mix of literal content and conversion specifiers. for more details see: http://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html

<layout-class>:
A full class path to a Layout class available in the enviroemnt with a empty constructor.
for every argument defined railo tries to call a matching setter method


Possible Appenders:
- - - - - - - - - - - - - -

Console: 
logs events to to the error or output stream
- streamtype: "output" or "error" 

Resource:
Logs error to a resource (locale file, ftp, zip, ...)
- path: path to the locale file
-charset (default:resource charset): charset used to write the file
- maxfiles (default:10): maximal files created
- maxfilesize (default:1024*1024*10): the maxial size of a log file created

<appender-class>:
A full class path to a Appender class available in the enviroemnt with a empty constructor.
for every argument defined railo tries to call a matching setter method

 -->
	<logging>
		<logger appender="resource" appender-arguments="path:{lucee-config}/logs/remoteclient.log" layout="classic" level="info" name="remoteclient"/>
		<logger appender="resource" appender-arguments="path:{lucee-config}/logs/requesttimeout.log" layout="classic" name="requesttimeout"/>
		<logger appender="resource" appender-arguments="path:{lucee-config}/logs/mail.log" layout="classic" name="mail"/>
		<logger appender="resource" appender-arguments="path:{lucee-config}/logs/scheduler.log" layout="classic" name="scheduler"/>
		<logger appender="resource" appender-arguments="path:{lucee-config}/logs/trace.log" layout="classic" name="trace"/>
		<logger appender="resource" appender-arguments="path:{lucee-config}/logs/application.log" layout="classic" level="info" name="application"/>
		<logger appender="resource" appender-arguments="path:{lucee-config}/logs/exception.log" layout="classic" level="info" name="exception"/>	
	</logging>		
<rest/><gateways/><orm/><datasource/></cfLuceeConfiguration>