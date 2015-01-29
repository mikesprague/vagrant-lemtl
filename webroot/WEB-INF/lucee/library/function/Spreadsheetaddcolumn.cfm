<!--- Compatibility note: ACF does not yet support a "delimiter" argument --->
<cffunction name="SpreadsheetAddColumn" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="data" type="string" required="true" hint="Delimited list of values" />
	<cfargument name="startRow" type="numeric" required="false" />
	<cfargument name="startColumn" type="numeric" required="false" />
	<cfargument name="insert" type="boolean" required="false" />
	<cfargument name="delimiter" type="string" required="false" default="," />
	
	<cfif StructKeyExists(arguments, "startRow") and not StructKeyExists(arguments, "startColumn")>
		<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet" 
				message="Invalid Argument Combination" 
				detail="If a StartRow is specified, StartColumn is required." />
	</cfif>
			
	<cfset Local.args.data = arguments.data />
	<cfset Local.args.delimiter = arguments.delimiter />
	
	<cfif StructKeyExists(arguments, "startRow")>
		<cfset Local.args.startRow = arguments.startRow />
	</cfif>
	
	<cfif StructKeyExists(arguments, "startColumn")>
		<cfset Local.args.column = arguments.startColumn />
	</cfif>
	
	<cfif StructKeyExists(arguments, "insert")>
		<cfset Local.args.insert = arguments.insert />
	</cfif>
	
	<cfset arguments.spreadsheet.addColumn( argumentCollection=Local.args ) />
</cffunction>
