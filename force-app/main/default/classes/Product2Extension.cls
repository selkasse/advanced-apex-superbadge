public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}
    public List<ChartHelper.ChartData> chart {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        chart = ChartHelper.GetInventory();
        addRows();
    }

    public void AddRows(){
        for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> familyOptions = new List<SelectOption>();
        
        familyOptions.add(new SelectOption ('', Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry: Constants.PRODUCT_FAMILY){

            familyOptions.add(new SelectOption (entry.getValue(), entry.getLabel()));
        }
        return familyOptions;
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){

        Savepoint sp = Database.setSavepoint();

        try {
            // insert productsToInsert;
            List<Product2> products = new List<Product2>();
            List<PriceBookEntry> priceBookEntrires = new List<PriceBookEntry>();

            for(ProductWrapper wrapper: productsToInsert){
                if(!String.isBlank(wrapper.productRecord.Name) && !String.isBlank(wrapper.productRecord.Family) && 
                   wrapper.productRecord.Family!=Constants.SELECT_ONE && wrapper.productRecord.isActive &&
                   wrapper.pricebookEntryRecord.UnitPrice!=null && wrapper.productRecord.Initial_Inventory__c!=null && 
                   wrapper.productRecord.Initial_Inventory__c!=0 && wrapper.pricebookEntryRecord.UnitPrice!=0){

                       products.add(wrapper.productRecord);
                       priceBookEntrires.add(wrapper.priceBookEntryRecord);
                   }
            }

            insert products;


            Map<Id, PriceBookEntry> productToEntryMap = new Map<Id, PriceBookEntry>();

            for(ProductWrapper wrapper: productsToInsert){
                
                productToEntryMap.put(wrapper.productRecord.id, wrapper.priceBookEntryRecord);
                   
            }

            for(ProductWrapper wrapper: productsToInsert){
                productToEntryMap.get(wrapper.productRecord.id).Product2Id = wrapper.productRecord.id;
            }
            insert priceBookEntrires;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Constants.ERROR_MESSAGE));
            Database.rollback(sp);
            return null;
        }
        return null;
    }

    
    public class ProductWrapper {
        public Product2 productRecord {get;set;}
        public PriceBookEntry pricebookEntryRecord {get;set;}

        public ProductWrapper(){
            productRecord = new Product2();
            pricebookEntryRecord = new PriceBookEntry();
            pricebookEntryRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;

            // productRecord = new Product2(Initial_Inventory__c =0, Name='Test Product', isActive=true); pricebookEntryRecord = new PricebookEntry(Unitprice=0.0);

            
        }
    }

}