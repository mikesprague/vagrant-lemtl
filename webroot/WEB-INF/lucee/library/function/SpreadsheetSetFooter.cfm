<!--- TODO: seems a bit odd that all arguments are required and that you have to pass 
			"" for the ones you don't want to set, but we'll match CF 9 behavior for now --->
<cffunction name="SpreadsheetSetFooter" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="leftFooter" type="string" required="true" />
	<cfargument name="centerFooter" type="string" required="true" />
	<cfargument name="rightFooter" type="string" required="true" />
	
	<cfset arguments.spreadsheet.setFooter(arguments.leftFooter, arguments.centerFooter, arguments.rightFooter) />
</cffunction>