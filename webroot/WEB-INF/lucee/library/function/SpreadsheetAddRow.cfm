<!--- Compatibility note: ACF does not yet support a "delimiter" argument --->
<cffunction name="SpreadsheetAddRow" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="data" type="string" required="true" hint="Delimited list of values" />
	<cfargument name="row" type="numeric" required="false" hint="Target row number. If omitted, data is added to the next unpopulated row" />
	<cfargument name="column" type="numeric" required="false" hint="Target column number" />
	<cfargument name="insert" type="boolean" default="true" hint="If true, data is inserted as a new row. Otherwise, existing data is overwritten" />
	<cfargument name="delimiter" type="string" default="," hint="Delimiter for the list of values. (Default is a comma)" />
	<cfargument name="handleEmbeddedCommas" type="boolean" default="true" hint="When true, values enclosed in single quotes are treated as a single element like in ACF. Only applies when the delimiter is a comma."  />
	
	<cfset var args = StructNew() />
	
	<cfset args.data 		= arguments.data />
	<cfset args.insert 		= arguments.insert />
	<cfset args.delimiter 	= arguments.delimiter />
	<cfset args.handleEmbeddedCommas 	= arguments.handleEmbeddedCommas />
	
	<cfif StructKeyExists(arguments, "row")>
		<cfset args.startRow = arguments.row />
	</cfif>
	
	<cfif StructKeyExists(arguments, "column")>
		<cfset args.startColumn = arguments.column />
	</cfif>
	
	<cfset arguments.spreadsheet.addRow(argumentcollection = args) />
</cffunction>