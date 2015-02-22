<cffunction name="SpreadsheetAddFreezePane" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="freezeColumn" type="numeric" required="true" />
	<cfargument name="freezeRow" type="numeric" required="true" />
	<cfargument name="column" type="numeric" required="false" 
		hint="Column number to appear immediately after the freeze column" />
	<cfargument name="row" type="numeric" required="false" 
		hint="Row number to appear immediately after the freeze row" />
	
	<cfset var args = StructNew() />
	
	<cfset args.splitColumn = arguments.freezeColumn />
	<cfset args.splitRow = arguments.freezeRow />
	
	<cfif StructKeyExists(arguments, "column")>
		<cfset args.leftmostColumn = arguments.column />
	</cfif>
	
	<cfif StructKeyExists(arguments, "row")>
		<cfset args.topRow = arguments.row />
	</cfif>
	
	<cfset arguments.spreadsheet.addFreezePane(argumentcollection = args) />
</cffunction>