/* license goes here */
component output="false" accessors="true" extends="mura.baseobject" hint="This provides validation to entities" {

	public struct function getValidationsByContext(required any object, string context="") {

		var contextValidations = {};
		var validationStruct = arguments.object.getValidations();

		// Loop over each proeprty in the validation struct looking for rule structures
		for(var property in validationStruct.properties) {

		// For each array full of rules for the property, loop over them and check for the context
			for(var r=1; r<=arrayLen(validationStruct.properties[property]); r++) {

			var rule = validationStruct.properties[property][r];

			// Verify that either context doesn't exist, or that the context passed in is in the list of contexts for this rule
			if(!structKeyExists(rule, "contexts") || listFindNoCase(rule.contexts, arguments.context)) {

					if(!structKeyExists(contextValidations, property)) {
						contextValidations[ property ] = [];
					}

					for(var constraint in rule) {
						if(constraint != "contexts" && constraint != "conditions") {
							var constraintDetails = {
								constraintType=constraint,
								constraintValue=rule[ constraint ]
							};
							if(structKeyExists(rule, "conditions")) {
								constraintDetails.conditions = rule.conditions;
							}
							if(structKeyExists(rule, "rbkey") and len(rule.rbkey)) {
								constraintDetails.rbkey = rule.rbkey;
							} else if(structKeyExists(rule, "message") and len(rule.message)) {
								constraintDetails.message = rule.message;
							}

							arrayAppend(contextValidations[ property ], constraintDetails);
						}
					}
				}
			}
		}

		return contextValidations;
	}



	public boolean function getConditionsMeetFlag( required any object, required string conditions) {

		var validationStruct = arguments.object.getValidations();

		var conditionsArray = listToArray(arguments.conditions);

		// Loop over each condition to check if it is true
		for(var x=1; x<=arrayLen(conditionsArray); x++) {

			var conditionName = conditionsArray[x];

			// Make sure that the condition is defined in the meta data
			if(structKeyExists(validationStruct, "conditions") && structKeyExists(validationStruct.conditions, conditionName)) {

				var allConditionConstraintsMeet = true;

				// Loop over each propertyIdentifier for this condition
				for(var conditionPropertyIdentifier in validationStruct.conditions[ conditionName ]) {

					// Loop over each constraint for the property identifier to validate the constraint
					for(var constraint in validationStruct.conditions[ conditionName ][ conditionPropertyIdentifier ]) {
						if(structKeyExists(variables, "validate_#constraint#") && !invokeMethod("validate_#constraint#", {object=arguments.object, propertyIdentifier=conditionPropertyIdentifier, constraintValue=validationStruct.conditions[ conditionName ][ conditionPropertyIdentifier ][ constraint ]})) {
							allConditionConstraintsMeet = false;
						}
					}
				}

				// If all constraints of this condition are meet, then we no that one condition is meet for this rule.
				if( allConditionConstraintsMeet ) {
					return true;
				}
			}
		}

		return false;
	}

	public any function getPopulatedPropertyValidationContext(required any object, required string propertyName, string context="") {

		var validationStruct = arguments.object.getValidations();

		if(structKeyExists(validationStruct, "populatedPropertyValidation") && structKeyExists(validationStruct.populatedPropertyValidation, arguments.propertyName)) {
			for(var v=1; v <= arrayLen(validationStruct.populatedPropertyValidation[arguments.propertyName]); v++) {
				var conditionsMeet = true;
				if(structKeyExists(validationStruct.populatedPropertyValidation[arguments.propertyName][v], "conditions")) {
					conditionsMeet = getConditionsMeetFlag(object=arguments.object, conditions=validationStruct.populatedPropertyValidation[arguments.propertyName][v].conditions);
				}
				if(conditionsMeet) {
					return validationStruct.populatedPropertyValidation[arguments.propertyName][v].validate;
				}
			}

		}

		return arguments.context;
	}

	public any function validate(required any object, string context="") {

		var errorsStruct={};

		// If the context was 'false' then we don't do any validation
		if(!isBoolean(arguments.context) || arguments.context) {
			// Get the valdiations for this context
			var contextValidations = getValidationsByContext(object=arguments.object, context=arguments.context);

			//writeDump(var=contextValidations,abort=true);

			// Loop over each property in the validations for this context
			for(var propertyIdentifier in contextValidations) {

				// First make sure that the proerty exists
				//if(arguments.object.hasProperty( propertyIdentifier )) {
					var requiredAttrs={};

					// Loop over each of the constraints for this given property looking for required attributes
					for(var c=1; c<=arrayLen(contextValidations[ propertyIdentifier ]); c++) {
						if(contextValidations[ propertyIdentifier ][c].constraintType == 'required'){
							requiredAttrs[propertyIdentifier]=true;
						}
					}

					// Loop over each of the constraints for this given property
					for(var c=1; c<=arrayLen(contextValidations[ propertyIdentifier ]); c++) {

						// Check that one of the conditions were meet if there were conditions for this constraint
						var conditionMeet = true;
						if(structKeyExists(contextValidations[ propertyIdentifier ][c], "conditions")) {
							conditionMeet = getConditionsMeetFlag( object=arguments.object, conditions=contextValidations[ propertyIdentifier ][ c ].conditions );
						}

						//Only validate if the property has a value when not required
						if(contextValidations[ propertyIdentifier ][c].constraintType != 'required'
							&& isSimpleValue(arguments.object.getValue(propertyIdentifier))
							&& !len(arguments.object.getValue(propertyIdentifier))
							&& !structKeyExists(requiredAttrs,propertyIdentifier)){
							conditionMeet=false;
						}

						// Now if a condition was meet we can actually test the individual validation rule
						if(conditionMeet) {
							validateConstraint(object=arguments.object, propertyIdentifier=propertyIdentifier, constraintDetails=contextValidations[ propertyIdentifier ][c], errorsStruct=errorsStruct, context=arguments.context);
						}
					}
				//}
			}
		}

		return errorsStruct;
	}


	public any function validateConstraint(required any object, required string propertyIdentifier, required struct constraintDetails, required any errorsStruct, required string context) {
		if(structKeyExists(variables, "validate_#arguments.constraintDetails.constraintType#")) {

			var isValid = invokeMethod("validate_#arguments.constraintDetails.constraintType#", {object=arguments.object, propertyIdentifier=arguments.propertyIdentifier, constraintValue=arguments.constraintDetails.constraintValue});
			
			if(!isValid) {
				if(structKeyExists(arguments.constraintDetails,'rbkey')){
					arguments.errorsStruct[arguments.propertyIdentifier]=getBean('settingsManager').getSite(arguments.object.getSiteID()).getRBFactory().getKey(arguments.constraintDetails.rbkey);
				} else if(structKeyExists(arguments.constraintDetails,'message')){
					arguments.errorsStruct[arguments.propertyIdentifier]=arguments.constraintDetails.message;
				} else {
					arguments.errorsStruct[arguments.propertyIdentifier]="The property named '#arguments.propertyIdentifier#' is not valid";
				}
				
				//writeDump(var=constraintDetails,abort=true);
			}
		}

	}


	// ================================== VALIDATION CONSTRAINT LOGIC ===========================================

	public boolean function validate_required(required any object, required string propertyIdentifier, boolean constraintValue=true) {


		if(constraintValue){
			var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
			if(!isNull(propertyValue) && (isObject(propertyValue) || (isArray(propertyValue) && arrayLen(propertyValue)) || (isStruct(propertyValue) && structCount(propertyValue)) || (isSimpleValue(propertyValue) && len(propertyValue)) || isNumeric(propertyValue) )) {
				return true;
			}

			return false;
		}

		return true;
	}

	public boolean function validate_dataType(required any object, required string propertyIdentifier, required any constraintValue) {

		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier, arguments.constraintValue);
		
		//Translate from db types to CF types
		if(arguments.constraintValue=='datetime'){
			arguments.constraintValue='date';
		} else if (listFindNoCase('varchar,char,text,longtext,mediumtext,clob,nvarchar',arguments.constraintValue)){
			arguments.constraintValue='string';
		} else if (listFindNoCase('tinyint,int,smallint',arguments.constraintValue)){
			arguments.constraintValue='integer';
		} else if (arguments.constraintValue=='double'){
			arguments.constraintValue='float';
		}

		if(listFindNoCase("any,array,binary,boolean,component,creditCard,date,time,email,eurodate,float,numeric,guid,integer,query,range,ssn,social_security_number,string,telephone,url,uuid,usdate,zipcode",arguments.constraintValue)) {
			if(isNull(propertyValue) || isValid(arguments.constraintValue, propertyValue) || (arguments.constraintValue == 'Date' && propertyValue == '')) {
				return true;
			} else {
				return false;
			}
		} else if (arguments.constraintValue == 'json'){
			if(isNull(propertyValue)) {
				return true;
			} else if(!isJSON(propertyValue)) {
				return false;
			} else {
				var val=deserializeJSON(propertyValue);
				if(isStruct(val) || isArray(val)) {
					return true;
				}
				return false;
			}
		} 
		//else {
		// 	throw("The validation file: #arguments.object.getClassName()#.json has an incorrect dataType constraint value of '#arguments.constraintValue#' for one of it's properties.  Valid values are: any,array,binary,boolean,component,creditCard,date,time,email,eurodate,float,numeric,guid,integer,query,range,regex,regular_expression,ssn,social_security_number,string,telephone,url,uuid,usdate,zipcode");
		// }

		return true;
	}

	public boolean function validate_format(required any object, required string propertyIdentifier, required any constraintValue) {

		return validate_dataType(argumentCollection=arguments);
	}

	public boolean function validate_minValue(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(isNull(propertyValue) || (isNumeric(propertyValue) && propertyValue >= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}

	public boolean function validate_maxValue(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(isNull(propertyValue) || (isNumeric(propertyValue) && propertyValue <= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}

	public boolean function validate_minLength(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(isNull(propertyValue) || (isSimpleValue(propertyValue) && len(propertyValue) >= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}

	public boolean function validate_maxLength(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(isNull(propertyValue) || (isSimpleValue(propertyValue) && len(propertyValue) <= arguments.constraintValue) ) {
			return true;
		}
		return false;
	}

	public boolean function validate_minCollection(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(isNull(propertyValue) || (isArray(propertyValue) && arrayLen(propertyValue) >= arguments.constraintValue) || (isStruct(propertyValue) && structCount(propertyValue) >= arguments.constraintValue)) {
			return true;
		}
		return false;
	}

	public boolean function validate_maxCollection(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(isNull(propertyValue) || (isArray(propertyValue) && arrayLen(propertyValue) <= arguments.constraintValue) || (isStruct(propertyValue) && structCount(propertyValue) <= arguments.constraintValue)) {
			return true;
		}
		return false;
	}

	public boolean function validate_minList(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if((!isNull(propertyValue) && isSimpleValue(propertyValue) && listLen(propertyValue) >= arguments.constraintValue) || (isNull(propertyValue) && arguments.constraintValue == 0)) {
			return true;
		}
		return false;
	}

	public boolean function validate_maxList(required any object, required string propertyIdentifier, required numeric constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if((!isNull(propertyValue) && isSimpleValue(propertyValue) && listLen(propertyValue) <= arguments.constraintValue) || (isNull(propertyValue) && arguments.constraintValue == 0)) {
			return true;
		}
		return false;
	}

	public boolean function validate_method(required any object, required string propertyIdentifier, required string constraintValue) {
		// not safe for public validation
		//return arguments.object.invokeMethod(arguments.constraintValue);
	}

	public boolean function validate_lte(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(!isNull(propertyValue) && !isNull(arguments.constraintValue) && propertyValue <= arguments.constraintValue) {
			return true;
		}
		return false;
	}

	public boolean function validate_lt(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(!isNull(propertyValue) && !isNull(arguments.constraintValue) && propertyValue < arguments.constraintValue) {
			return true;
		}
		return false;
	}

	public boolean function validate_gte(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue =getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(!isNull(propertyValue) && !isNull(arguments.constraintValue) && propertyValue >= arguments.constraintValue) {
			return true;
		}
		return false;
	}

	public boolean function validate_gt(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(!isNull(propertyValue) && !isNull(arguments.constraintValue) && propertyValue > arguments.constraintValue) {
			return true;
		}
		return false;
	}

	public boolean function validate_eq(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(!isNull(propertyValue) && !isNull(arguments.constraintValue) && propertyValue == arguments.constraintValue) {
			return true;
		}
		return false;
	}

	public boolean function validate_neq(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(!isNull(propertyValue) && !isNull(arguments.constraintValue) && propertyValue != arguments.constraintValue) {
			return true;
		}
		return false;
	}

	public function getValueForValidation(required any object, required string propertyIdentifier , constraintValue='') {
		var validationContextId = arguments.object.get('validationContextId');
		if(len(validationContextId) 
			&& isDefined('request.muraValidationContext') 
			&& structKeyExists(request.muraValidationContext,'#validationContextId#')
			&& structKeyExists(request.muraValidationContext['#validationContextId#'],'#arguments.propertyIdentifier#')){

			if(listFindNoCase('date,datetime',arguments.constraintValue)){
				return arguments.object.parseDateArg(request.muraValidationContext['#validationContextId#'][arguments.propertyIdentifier]);
			} else {
				return request.muraValidationContext['#validationContextId#'][arguments.propertyIdentifier];
			}
		} else {
			return arguments.object.invokeMethod("get#arguments.propertyIdentifier#");
		}	
	}

	public boolean function validate_inList(required any object, required string propertyIdentifier, required string constraintValue) {
		var propertyValue = getValueForValidation(arguments.object,arguments.propertyIdentifier);
		if(!isNull(propertyValue) && listFindNoCase(arguments.constraintValue, propertyValue)) {
			return true;
		}
		return false;
	}

	public boolean function validate_regex(required any object, required string propertyIdentifier, required string constraintValue) {
		var fileManager=getBean('fileManager');
		if(fileManager.isPostedFile(arguments.propertyIdentifier)){
			var propertyValue = fileManager.getPostedClientFileName(arguments.propertyIdentifier);
		} else {
			var propertyValue =  getValueForValidation(arguments.object,arguments.propertyIdentifier);
		}

		if(isNull(propertyValue) || isValid("regex", propertyValue, arguments.constraintValue)) {
			return true;
		}
		return false;
	}

}
