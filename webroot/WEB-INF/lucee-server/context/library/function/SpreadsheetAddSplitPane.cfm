<cffunction name="SpreadsheetAddSplitPane" returntype="void" output="false">
	<cfargument name="spreadsheet" type="org.cfpoi.spreadsheet.Spreadsheet" required="true" />
	<cfargument name="xpos" type="numeric" required="true" />
	<cfargument name="ypos" type="numeric" required="true" />
	<cfargument name="splitcol" type="numeric" required="true" />
	<cfargument name="splitrow" type="numeric" required="true" />
	<cfargument name="position" type="string" required="false" 
		hint="Valid values are LOWER_LEFT, LOWER_RIGHT, UPPER_LEFT, UPPER_RIGHT" />
	
	
	<cfset var args = StructNew() />
	
	<cfset args.xSplitPos = arguments.xpos />
	<cfset args.ySplitPos = arguments.ypos />
	<cfset args.leftmostColumn = arguments.splitcol />
	<cfset args.topRow = arguments.splitrow />
	
	<cfif StructKeyExists(arguments, "position")>
		<cfset args.activePane = arguments.position />
	</cfif>
	
	<cfset arguments.spreadsheet.createSplitPane(argumentcollection = args) />
</cffunction>