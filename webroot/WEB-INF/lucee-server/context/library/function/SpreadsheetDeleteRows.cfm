<cffunction name="SpreadsheetDeleteRows" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="range" type="string" required="true" />
	
	<cfset arguments.spreadsheet.deleteRows(arguments.range) />
</cffunction>