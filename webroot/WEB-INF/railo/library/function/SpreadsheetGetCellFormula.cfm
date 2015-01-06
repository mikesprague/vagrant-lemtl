<!--- Returns a string for a single cell, or an array of structs if row and column are omitted. 
		Structs contain the following keys:
		* formula
		* row
		* column
--->
<cffunction name="SpreadsheetGetCellFormula" returntype="any" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="row" type="numeric" required="false" />
	<cfargument name="column" type="numeric" required="false" />
	
	<cfset var args = StructNew() />
	
	<cfif StructKeyExists(arguments, "row")>
		<cfset args.row = arguments.row />
	</cfif>
	
	<cfif StructKeyExists(arguments, "column")>
		<cfset args.column = arguments.column />
	</cfif>
	
	<cfreturn arguments.spreadsheet.getCellFormula(argumentcollection = args) />
</cffunction>