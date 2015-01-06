<!--- TODO: add usage notes for the format struct --->
<cffunction name="SpreadsheetFormatRow" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="format" type="struct" required="true" />
	<cfargument name="row" type="numeric" required="true" />
	
	<cfset arguments.spreadsheet.formatRow(arguments.format, arguments.row) />
</cffunction>