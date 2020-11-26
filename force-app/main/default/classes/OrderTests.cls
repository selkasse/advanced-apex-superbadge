@isTest (seeAllData=false)
private class OrderTests {

    @TestSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(Constants.DEFAULT_ROWS * 3);
    }

    static testMethod void OrderUpdate_UnitTest(){
        Test.startTest();

        List<Order> orders = [SELECT Id, Status FROM Order];
        List<Product2> originalProducts = [SELECT Id, Quantity_Ordered__c FROM Product2];
        Map<Id, Product2> originalProductMap = new Map<Id, Product2>();
        
        for(Order order: orders){
            order.status = Constants.ACTIVATED_ORDER_STATUS;
        }

        for(Product2 product: originalProducts){
            originalProductMap.put(product.id, product);
        }
        
        update orders;

        List<Product2> updatedProducts = [SELECT Id, Quantity_Ordered__c FROM Product2];

        for(Product2 product: updatedProducts){

            TestDataFactory.VerifyQuantityOrdered(originalProductMap.get(product.Id), product, Constants.DEFAULT_ROWS);
        }

        Test.stopTest();
    }

    static testMethod void OrderExtension_UnitTest(){
        Test.startTest();
        
        PageReference pageRef = Page.OrderEdit;
        Test.setCurrentPage(pageRef);

        Order testOrder = [SELECT Id, AccountId, Name, Status, EffectiveDate, Pricebook2Id FROM Order LIMIT 1];
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(testOrder);

        OrderExtension ext = new OrderExtension(stdcontroller);

        // * Assert that the orderRecord is not null
        System.assertEquals(true, ext.orderRecord.Id != null);

        // * Assert that the orderItemMap is not null
        System.assertEquals(true, ext.orderItemMap.size() > 0);

        // * Assert that pieData is not null
        System.assertEquals(true, ext.pieData != null);

        // * Assert that pieData contains the correct number of OrderItems
        System.assertEquals(true, ext.pieData.size() == ext.orderRecord.OrderItems.size());

        // * Assert that orderItemList is not null
        System.assertEquals(true, !ext.orderItemList.isEmpty());

        // * Simulate changing the Quantity from 0 to 1 for an OrderItem in orderItemList
        Decimal totalBefore = ext.total;
        Integer pieSizeBefore = ext.pieData.size();
        Decimal unitPrice;
        OrderItem newItem;
        
        for(OrderItem oi: ext.orderItemList){
            if(oi.Quantity == 0){
                newItem = oi;
                oi.Quantity += 1;
                unitPrice = oi.UnitPrice;

                break;
            }
        }
        
        ext.OnFieldChange();
        
        // * Assert that the OnFieldChange() method correctly updates the total and pieData
        System.assertEquals(true, ext.total == totalBefore + unitPrice);
        System.assertEquals(true, ext.pieData.size() == pieSizeBefore + 1);

        System.debug(ext.pieData.size());
        System.debug(pieSizeBefore);


        // * Simulate selecting a family from the picklist
        ext.selectedFamily = Constants.PRODUCT_FAMILY[0].getLabel();
        ext.SelectFamily();

        for(PricebookEntry entry: ext.entries) {
            System.assertEquals(true, entry.Product2.Family == ext.selectedFamily);
        }

        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(ext.entries);
        
        // * Get full results
        ext.selectedFamily = null;
        ext.SelectFamily();

        // * Assert that the Previous button is greyed out
        System.assertEquals(false, ext.getHasPrevious());

        // * Assert that the Next button is enabled
        System.assertEquals(true, ext.getHasNext());

        System.assertEquals(1, ext.getPageNumber());
        
        System.assertEquals(ext.GetTotalPages(), (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS));
        
        // * Simulate pagination
        ext.Next();
        ext.Previous();
        ext.Last();
        System.assertEquals(3, ext.getPageNumber());
        ext.First();
        System.assertEquals(1, ext.getPageNumber());

        // * Validate GetFamilyOptions
        List<String> selectOptions = new List<String>();
        for(SelectOption option: ext.getFamilyOptions()) {
            if(option.getLabel() != Constants.SELECT_ONE){
                selectOptions.add(option.getLabel());
            }
        }

        for(Schema.PicklistEntry entry: Constants.PRODUCT_FAMILY){
            System.assertEquals(true, selectOptions.contains(entry.getLabel()));
        }

        // * Validate Save() method
        Integer newItemBefore = [SELECT Id FROM OrderItem WHERE Id = :newItem.Id].size();
        System.assertEquals(0, newItemBefore);
        ext.Save();
        Integer newItemAfter = [SELECT Id FROM OrderItem WHERE Id = :newItem.Id].size();
        System.assertEquals(1, newItemAfter);


        Test.stopTest();
    }

}