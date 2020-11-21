@isTest (seeAllData=true)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();
            Product2 prod = new Product2(name='Test',isActive=true);
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController(prod);

            Product2Extension ext = new Product2Extension(stdcontroller);
            
            ext.addRows();
            ext.save();
        Test.stopTest();
    }

}