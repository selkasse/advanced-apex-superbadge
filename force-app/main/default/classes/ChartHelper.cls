public without sharing class ChartHelper {
    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        // * these will be aggregated by Product Family
        for(AggregateResult family: [SELECT Family, SUM(Quantity_Remaining__c) aggregateQuantity
                                        FROM Product2
                                        GROUP BY Family
                                        HAVING SUM(Quantity_Remaining__c) > 0]){
                                            String name = (String)family.get('Family');
                                            Decimal val = (Decimal)family.get('aggregateQuantity');
                                            ChartData cd = new ChartData(name, val);
                                            cht.add(cd);
                                        }
        //  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}