@IsTest
public class SObjectTableTest {

	public static SObjectTable.SObjectStrategy createStrategy(){
		Integer page = 0;
		Integer perPage = 10;
		Map<String, List<Object>> filters = new Map<String, List<Object>>();
		String orderField = 'Name';
		String orderName = 'Desc';

		SObjectTable.SObjectStrategy strategy = new SObjectTable.SObjectStrategy();
		strategy.fieldsSet = new Set<String>{
			'Id',
			'Name'
		};

		strategy.sobjectName = 'Account';
		strategy.searchColumns = new Set<String>{
			'Name'
		};

		strategy.setOrderDesc('CreatedDate');

		//INPUT DATA
		strategy.perPage = perPage;
		strategy.page = page;
		strategy.setOrder(orderField, orderName, true);
		strategy.addFilters(filters, true);

		return strategy;
	}
    
    static testMethod void testFieldFormating() {
		Test.startTest();

		SObjectTable.SObjectStrategy strategy = SObjectTableTest.createStrategy();
        strategy.searchString = 'Test';

        strategy.addFilter('Name', new Set<Object>{
        	'Test 123'
        });

        strategy.addFilter('NumberOfEmployees', new Set<Object>{
        	'!NUMBER(0)'
        });

        strategy.addFilter('IsDeleted', new Set<Object>{
        	'!BOOLEAN(true)'
        });

        strategy.addFilter('LastActivityDate', new Set<Object>{
        	'!DATE(2020-03-01)'
        });

        strategy.addFilter('CreatedDate', new Set<Object>{
        	'!DATETIME(2020-04-09T11:18:12.422+02:00)'
        });

        //RESPONSE
        SObjectTable.TablePagination tableElement = SObjectTable.paginationData(strategy);

        Test.stopTest();
    }

    static testMethod void testKeywords() {
		SObjectTable.SObjectStrategy strategyGT = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyLT = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyGTE = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyLTE = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyISNULL = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyISNOTNULL = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyNOT = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyBETWEEN = SObjectTableTest.createStrategy();
		SObjectTable.SObjectStrategy strategyLIKE = SObjectTableTest.createStrategy();
		//SObjectTable.SObjectStrategy strategyQUERY = SObjectTableTest.createStrategy();
		//SObjectTable.SObjectStrategy strategyQUERYIN = SObjectTableTest.createStrategy();
		
		Test.startTest();

        strategyGT.addFilter('NumberOfEmployees', new Set<Object>{
        	'!GT(2)'
        });

        strategyLT.addFilter('NumberOfEmployees', new Set<Object>{
        	'!LT(2)'
        });

        strategyGTE.addFilter('NumberOfEmployees', new Set<Object>{
        	'!GTE(2)'
        });

        strategyLTE.addFilter('NumberOfEmployees', new Set<Object>{
        	'!LTE(2)'
        });

        strategyISNULL.addFilter('NumberOfEmployees', new Set<Object>{
        	'!ISNULL()'
        });

        strategyISNOTNULL.addFilter('NumberOfEmployees', new Set<Object>{
        	'!ISNOTNULL()'
        });

        strategyNOT.addFilter('IsDeleted', new Set<Object>{
        	'!NOT(true)'
        });

        strategyBETWEEN.addFilter('NumberOfEmployees', new Set<Object>{
        	'!BETWEEN(0,10)'
        });

        strategyLIKE.addFilter('Name', new Set<Object>{
        	'!LIKE(Test)'
        });

        //strategyQUERY.addFilter('CreatedBy', new Set<Object>{
        //	'!QUERY(SELECT Id FROM User)'
        //});
        //strategyQUERYIN.addFilter('NumberOfEmployees', new Set<Object>{
        //	'!QUERYIN(0,10)'
        //});

        SObjectTable.paginationData(strategyGT);
        SObjectTable.paginationData(strategyLT);
        SObjectTable.paginationData(strategyGTE);
        SObjectTable.paginationData(strategyLTE);
        SObjectTable.paginationData(strategyISNULL);
        SObjectTable.paginationData(strategyISNOTNULL);
        SObjectTable.paginationData(strategyNOT);
        SObjectTable.paginationData(strategyBETWEEN);
        SObjectTable.paginationData(strategyLIKE);
        //SObjectTable.paginationData(strategyQUERY);
        //SObjectTable.paginationData(strategyQUERYIN);

        Test.stopTest();
    }


}