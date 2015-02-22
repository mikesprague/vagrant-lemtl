<cffunction name="SpreadsheetClearCellRange" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="startRow" type="numeric" required="true" />
	<cfargument name="startColumn" type="numeric" required="true" />
	<cfargument name="endRow" type="numeric" required="true" />
	<cfargument name="endColumn" type="numeric" required="true" />
	
	<cfset arguments.spreadsheet.clearCellRange( arguments.startRow, arguments.startColumn, arguments.endRow, arguments.endColumn ) />
</cffunction>