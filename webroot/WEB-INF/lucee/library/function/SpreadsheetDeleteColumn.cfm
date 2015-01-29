<cffunction name="SpreadsheetDeleteColumn" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="column" type="numeric" required="true" />
	
	<cfset arguments.spreadsheet.deleteColumn(arguments.column) />
</cffunction>