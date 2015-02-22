<!--- TODO: file write/read error --->
<cffunction name="SpreadsheetReadBinary" returntype="binary" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	
	<cfreturn arguments.spreadsheet.readBinary() />
</cffunction>