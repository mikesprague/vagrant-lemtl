<cffunction name="SpreadsheetSetHeader" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="leftHeader" type="string" required="true" />
	<cfargument name="centerHeader" type="string" required="true" />
	<cfargument name="rightHeader" type="string" required="true" />
	
	<cfset arguments.spreadsheet.setHeader(arguments.leftHeader, arguments.centerHeader, arguments.rightHeader) />
</cffunction>