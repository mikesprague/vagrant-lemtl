<cffunction name="SpreadsheetDeleteRow" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="row" type="numeric" required="true" />
	
	<cfset arguments.spreadsheet.deleteRow(arguments.row) />
</cffunction>