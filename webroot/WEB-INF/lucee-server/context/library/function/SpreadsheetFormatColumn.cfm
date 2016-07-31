<!--- TODO: add usage notes for the format struct --->
<cffunction name="SpreadsheetFormatColumn" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="format" type="struct" required="true" />
	<cfargument name="column" type="numeric" required="true" />
	
	<cfset arguments.spreadsheet.formatColumn(arguments.format, arguments.column) />
</cffunction>