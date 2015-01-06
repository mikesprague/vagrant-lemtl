<cffunction name="SpreadsheetDeleteColumns" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="range" type="string" required="true" />
	
	<cfset arguments.spreadsheet.deleteColumns(arguments.range) />
</cffunction>