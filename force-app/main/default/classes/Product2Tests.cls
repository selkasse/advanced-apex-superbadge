@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();
            PageReference pageRef = Page.Product2New;
            Test.setCurrentPage(pageRef);
            
            Product2 prod = new Product2(name='Test',isActive=true);
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController(prod);

            Product2Extension ext = new Product2Extension(stdcontroller);
            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
            ext.addRows();
            System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size());

            Integer counter = 1;


            for(Integer i = 0 ; i < Constants.DEFAULT_ROWS ; i++){
                Product2Extension.ProductWrapper wrapper = ext.productsToInsert[i];
                wrapper.productRecord.Name = 'Test Product ' + String.valueOf(counter);
                wrapper.productRecord.Family = Constants.PRODUCT_FAMILY[Integer.valueOf(Math.random() * Constants.PRODUCT_FAMILY.size())].getLabel();
                wrapper.productRecord.IsActive = true;
                wrapper.productRecord.Initial_Inventory__c = 10;

                wrapper.pricebookEntryRecord.UnitPrice = Math.random() * 10;
                counter++;
            }
            ext.save();

            List<Product2> insertedProducts = [SELECT Id, Name FROM Product2];
            System.assertEquals(Constants.DEFAULT_ROWS, insertedProducts.size());

        Test.stopTest();
    }

}