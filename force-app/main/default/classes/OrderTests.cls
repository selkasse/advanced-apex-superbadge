@isTest (seeAllData=false)
private class OrderTests {

    @TestSetup
    static void SetupTestData(){
        TestDataFactory.InsertTestData(Constants.DEFAULT_ROWS);
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

}