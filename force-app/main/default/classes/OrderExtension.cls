/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public List<PricebookEntry> entries;


    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();

        total = 0;
        
        loadStandardSetController(selectedFamily);

        orderItemMap = new Map<id,OrderItem>();

        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }

        
        for(OrderItem oi: orderRecord.OrderItems){
            
            orderItemMap.put(oi.Product2Id, oi);
            
            if(oi.Quantity > 0){
                if(pieData == null){
                    pieData = new List<ChartHelper.ChartData>();
                    String name = oi.Product2.Name;
                    Decimal val = oi.Quantity * oi.UnitPrice;
                    ChartHelper.ChartData chart = new ChartHelper.ChartData(name, val);
        
                    total += val;
        
                    pieData.add(chart);
                }
            }

        }

        loadProducts();
    }

    public void loadStandardSetController(String family){
        if (family == null){
            
            entries = [SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c, IsActive
                                            FROM PricebookEntry
                                            WHERE IsActive = TRUE];
        }

        else {
            entries = [SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c, IsActive
                                            FROM PricebookEntry
                                            WHERE IsActive = TRUE
                                            AND Product2.Family = :family];
        }

        standardSetController = new ApexPages.StandardSetController(entries);
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }

    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void loadProducts() {
        orderItemList = new List<OrderItem>();

        for(SObject obj: standardSetController.getRecords()){
            PricebookEntry entry = (PricebookEntry) obj;

            if(orderItemMap.containsKey(entry.Product2Id)){
                orderItemList.add(orderItemMap.get(entry.Product2Id));
            }
            else {
                OrderItem oi = new OrderItem();
                oi.PricebookEntryId = entry.Id;
                oi.Product2Id = entry.Product2Id;
                oi.Product2 = entry.Product2;
                oi.UnitPrice = entry.UnitPrice;
                oi.Quantity = 0;
                orderItemList.add(oi);
                orderItemMap.put(oi.Product2Id, oi);
            }
        }
    }
    


    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        pieData = new List<ChartHelper.ChartData>();
        total = 0;

        for(OrderItem oi: orderItemList){
            String name = oi.Product2.Name;
            Decimal val = oi.Quantity * oi.UnitPrice;

            if(val > 0) {
                ChartHelper.ChartData chart = new ChartHelper.ChartData(name, val);
                pieData.add(chart);
                total += val;
            }



            orderItemMap.put(oi.Product2Id, oi);
        }
       

    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        loadStandardSetController(selectedFamily);
        loadProducts();
    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        System.Savepoint sp = Database.setSavepoint();

        
        try {
            List<OrderItem> itemsToSave = new List<OrderItem>();
            List<OrderItem> itemsToDelete = new List<OrderItem>();

            if(orderRecord.Pricebook2Id == null) {
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            
            upsert orderRecord;
            
            for(OrderItem oi: orderItemMap.values()){
                if(oi.Quantity > 0){
                    if(oi.OrderId == null){
                        oi.OrderId = orderRecord.Id;
                    }
                    itemsToSave.add(oi);
                }
                else if(oi.Id != null){
                    itemsToDelete.add(new OrderItem(id=oi.Id));
                    oi.Id = null;
                }
            }
            
            upsert itemsToSave;
            delete itemsToDelete;
        }
        catch(Exception e){
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE));
        }

    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
        loadProducts();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        loadProducts();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        loadProducts();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        loadProducts();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> familyOptions = new List<SelectOption>();
        
        familyOptions.add(new SelectOption ('', Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry: Constants.PRODUCT_FAMILY){

            familyOptions.add(new SelectOption (entry.getValue(), entry.getLabel()));
        }
        return familyOptions;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}