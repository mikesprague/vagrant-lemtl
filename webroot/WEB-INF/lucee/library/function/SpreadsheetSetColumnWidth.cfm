<cffunction name="SpreadsheetSetColumnWidth" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="column" type="numeric" required="true" />
	<cfargument name="width" type="numeric" required="true" hint="Width in points" />
	
	<cfset arguments.spreadsheet.setColumnWidth(arguments.column, arguments.width) />
</cffunction>