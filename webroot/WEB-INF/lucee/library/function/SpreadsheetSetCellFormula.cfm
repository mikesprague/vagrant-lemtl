<cffunction name="SpreadsheetSetCellFormula" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="formula" type="string" required="true" />
	<cfargument name="row" type="numeric" required="true" />
	<cfargument name="column" type="numeric" required="true" />
	
	<cfset arguments.spreadsheet.setCellFormula(arguments.formula, arguments.row, arguments.column) />
</cffunction>