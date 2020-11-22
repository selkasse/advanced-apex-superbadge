/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.

        CollaborationGroup collabGroup = new CollaborationGroup();
        collabGroup.Name = 'TEST' +  Constants.INVENTORY_ANNOUNCEMENTS;
        collabGroup.CollaborationType = 'Public';
        collabGroup.CanHaveGuests = false;
        collabGroup.IsArchived = false;
        collabGroup.IsAutoArchiveDisabled = false;
        return collabGroup;
        
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.

        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> families = fieldResult.getPicklistValues();

        List<Product2> products = new List<Product2>(cnt);
        for(Integer i=0 ; i < cnt ; i++){
            Product2 product = new Product2();
            product.Name = 'Test Product ' + String.valueOf(i);
            product.IsActive = true;
            String family;
            try {
                family = Constants.PRODUCT_FAMILY[i].getLabel();
            }
            catch (Exception e){
                family = Constants.PRODUCT_FAMILY[0].getLabel();
            }
            product.Family = family;
            product.Initial_Inventory__c = 10;
            products[i] = product;
        }

        return products;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> entries = new List<PricebookEntry>();

        for(Product2 product: prods){
            PricebookEntry entry = new PricebookEntry();
            entry.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            entry.Product2Id = product.Id;
            entry.IsActive = true;
            entry.UnitPrice = Integer.valueOf((Math.random() * 10));
            entries.add(entry);
        }

        return entries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accounts = new List<Account>();

        for(Integer i = 0; i < cnt; i++){
            Account account = new Account();
            account.Name = 'Test Account ' + i;
            accounts.add(account);
        }

        return accounts;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0 ; i < cnt ; i++){
            Contact contact = new Contact();
            contact.AccountId = accts[i].Id;
            contact.FirstName = 'Test';
            contact.LastName = 'Contact ' + String.valueOf(i);
            contacts.add(contact);
        }

        return contacts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> orders = new List<Order>();
        for (Integer i = 0 ; i < cnt ; i++){
            Order order = new Order();
            order.AccountId = accts[i].Id;
            order.Name = 'Test Order ' + String.valueOf(i);
            order.Status = Constants.DRAFT_ORDER_STATUS;
            order.EffectiveDate = System.TODAY();
            order.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            orders.add(order);
        }

        return orders;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> items = new List<OrderItem>();
        for(Integer i = 0 ; i < cnt ; i++){
            OrderItem item = new OrderItem();
            item.OrderId = ords[i].Id;
            item.Quantity = Constants.DEFAULT_ROWS;
            item.PricebookEntryId = pbes[i].Id;
            item.UnitPrice = pbes[i].UnitPrice;
            items.add(item);
        }

        return items;
    }

    // * This method should perform an assertion that verifies that updatedProduct's Quantity_Ordered__c field 
    // *    is equal to the sum of the originalProduct's Quantity_Ordered__c field
    // *    and the value of qtyOrdered.
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
        System.assertEquals(updatedProduct.Quantity_Ordered__c, originalProduct.Quantity_Ordered__c + qtyOrdered);
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        CollaborationGroup collab = ConstructCollaborationGroup();
        insert collab;

        List<Product2> products = ConstructProducts(cnt);
        insert products;

        List<PricebookEntry> pricebookEntries = ConstructPricebookEntries(products);
        insert pricebookEntries;

        List<Account> accounts = ConstructAccounts(cnt);
        insert accounts;

        List<Contact> contacts = ConstructContacts(cnt, accounts);
        insert contacts;

        List<Order> orders = ConstructOrders(cnt, accounts);
        insert orders;

        List<OrderItem> items = ConstructOrderItems(cnt, pricebookEntries, orders);
        insert items;

    }

}