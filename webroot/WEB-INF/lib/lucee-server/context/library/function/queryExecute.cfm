<!--- 
 *
 * Copyright (c) 2014, the Railo Company Ltd. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 ---><cfscript>
function QueryExecute(required caller, required string sql, any params, struct options={}) callerscopes=true {
   
   //dump(caller);
   //abort;
   if(!isNull(arguments.params))arguments.options.params=arguments.params;
   
   if(!isNull(arguments.caller.local)) {
	   arguments.caller.local.____sqlString=arguments.sql;
	   arguments.caller.local.____attributeCollection=arguments.options;

	   // make the callers scope my own
	   structClear(local);
	   structAppend(local,arguments.caller.local);
	   local.____argumentsScope=arguments.caller.arguments;
	   structClear(arguments);
	   structAppend(arguments,local.____argumentsScope);
	   structDelete(local,"____argumentsScope",false);
   }
   else {
   		local.____attributeCollection=arguments.options;
   		local.____sqlString=arguments.sql;
   	}

   query name="local.____rtn" attributeCollection="#local.____attributeCollection#" {
      echo(local.____sqlString);
   }

   if(isNull(local.____rtn)) return;
   return local.____rtn;
}
</cfscript>