<!--- TODO: only supporting HSSF (non-xslx format) for now --->
<cffunction name="SpreadsheetRead" returntype="any" output="false">
	<cfargument name="src" type="string" required="true" hint="Path to an existing workbook file on disk" />
	<!---
		Not sure we can distinguish between a sheet "name" and index without
		requiring named arguments. So full compatibility with the ACF version 
		probably is not possible. This is not critical since sheets can be activated 
		later ..

	<cfargument name="sheetName" type="string" required="false" hint="Sheet name to activate" />
	<cfargument name="sheet" type="numeric" required="false" hint="Sheet number to activate" />
	
	<cfif structKeyExists(arguments, "sheetName") and structKeyExists(arguments, "sheet")>
			<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet" 
					message="Invalid Argument Combination" 
					detail="Either specify a 'SheetName' OR 'Sheet', but not both.">
	</cfif>	
	--->	

	<!--- To avoid confusion with ACF's function, (which also 
		accepts sheetName and sheet index) let's throw an error 
		if too many arguments are supplied --->
	<cfif structCount( arguments ) gt 1>		
		<cfthrow type="org.cfpoi.spreadsheet.Spreadsheet" 
					message="Too Many Arguments" 
					detail="SpreadsheetRead() only supports a 'src' argument" />
	</cfif>
			
	<cfreturn CreateObject("component", "org.cfpoi.spreadsheet.Spreadsheet").init( argumentCollection=arguments ) />
</cffunction>
