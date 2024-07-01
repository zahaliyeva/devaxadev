/**  http://developer.force.com/cookbook/recipe/trigger-pattern-for-tidy-streamlined-bulkified-triggers

 * Class TriggerFactory
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */

public with sharing class TriggerFactory {

/**
 * private static method to control the execution of the handler
 * Arguments:   ITrigger handler - A Trigger Handler to execute
 */

	private static void execute(ITrigger handler) {
		String handlerName = String.valueOf(handler).split(':').get(0);
		if (Trigger.isBefore) {

			 // Call the bulk before to handle any caching of data and enable bulkification
			 handler.bulkBefore();
			 logGovernorLimits(handlerName);
			 // Iterate through the records to be deleted passing them to the handler.
			 if (Trigger.isDelete)
			  {
				  for (SObject so : Trigger.old)
				   {
					   handler.beforeDelete(so);
				   }

				  handler.beforeDelete(Trigger.old);
				  logGovernorLimits(handlerName);
			  }

			 // Iterate through the records to be inserted passing them to the handler.

			 else if (Trigger.isInsert)
			  {

				  for (SObject so : Trigger.new)
				   {
					   handler.beforeInsert(so);
				   }

				  handler.beforeInsert(Trigger.new);
				  logGovernorLimits(handlerName);
			  }

			 // Iterate through the records to be updated passing them to the handler.

			 else if (Trigger.isUpdate)
			  {
				  for (SObject so : Trigger.old)
				   {
					   handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
				   }

				  handler.beforeUpdate(Trigger.old, Trigger.new);
				  logGovernorLimits(handlerName);
			  }

		 }

		if (Trigger.isAfter)
		 {
			 // Call the bulk after to handle any caching of data and enable bulkification
			 handler.bulkAfter();
			 logGovernorLimits(handlerName);

			 // Iterate through the records deleted passing them to the handler.
			 if (Trigger.isDelete)
			  {

				  for (SObject so : Trigger.old)
				   {
					   handler.afterDelete(so);
				   }

				  handler.afterDelete(Trigger.old);
				  logGovernorLimits(handlerName);
			  }

			 else if (Trigger.isUndelete)
			  {

				  for (SObject so : Trigger.new)
				   {
					   handler.afterUndelete(so);
				   }

				  handler.afterUndelete(Trigger.new);
                  logGovernorLimits(handlerName);
			  }

			 // Iterate through the records inserted passing them to the handler.

			 else if (Trigger.isInsert)
			  {

				  for (SObject so : Trigger.new)
				   {
					   handler.afterInsert(so);
				   }

				  handler.afterInsert(Trigger.new);
				  logGovernorLimits(handlerName);

			  }

			 // Iterate through the records updated passing them to the handler.

			 else if (Trigger.isUpdate)
			  {
				  for (SObject so : Trigger.old)
				   {
					   handler.afterUpdate(so, Trigger.newMap.get(so.Id));
				   }

				  handler.afterUpdate(Trigger.old, Trigger.new);
				  logGovernorLimits(handlerName);
			  }


		 }

		// Perform any post processing
		handler.andFinally();
		logGovernorLimits(handlerName);

	}


/**
 * private static method to get the appropriate handler for the object type.
 * Modify this method to add any additional handlers.
 * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
 * Returns:     ITrigger - A trigger handler if one exists or null.
 */



//----------------------------------------------------------------------------------------------------------------------------------


//V.02
	public static void createHandler(String className,List<sObject> trignew)
	{
		// Get a handler appropriate to the object being processed
		ITrigger handler = getHandler(className);
		system.debug(''+handler);

		// Make sure we have a handler registered, new handlers must be registered in the getHandler method.
		if (handler == null)
		 {
			 throw new IllegalArgumentException('No Trigger Handler registered for Class Name: ' + className);
		 }

		// Execute the handler to fulfil the trigger
		execute(handler);
	}

//V.02
	public static void createHandler(String className)
	{
		// Get a handler appropriate to the object being processed
		ITrigger handler = getHandler(className);
		system.debug(handler);

		// Make sure we have a handler registered, new handlers must be registered in the getHandler method.
		if (handler == null)
		 {
			 throw new IllegalArgumentException('No Trigger Handler registered for Class Name: ' + className);
		 }

		// Execute the handler to fulfil the trigger
		execute(handler);
	}

//V.02
	private static ITrigger getHandler(String className) {
		Type t = Type.forName(className+'');
		return (ITrigger)t.newInstance();
	}

	private static void logGovernorLimits(String handlerName){
		System.debug('Context: ' + handlerName + ' Method: afterUpdate' + ' Number of Queries used in this Apex code so far: ' + Limits.getQueries() + '/' + Limits.getLimitQueries());
		System.debug('Context: ' + handlerName + ' Method: afterUpdate' + ' Number of rows queried in this Apex code so far: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows());
		System.debug('Context: ' + handlerName + ' Method: afterUpdate' + ' Number of DML statements used so far: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements());
		System.debug('Context: ' + handlerName + ' Method: afterUpdate' + ' Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime() + '/' +  Limits.getLimitCpuTime());
	}

}