public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        System.debug('inside afterupdate');
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS && oldList[i].Status != Constants.ACTIVATED_ORDER_STATUS ){
                orderIds.add(newList[i].Id);
            }
        }

        RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        // * Declare a Map named "productMap" of Ids to Product2 records
        Map<Id, Product2> productMap = new Map<Id, Product2>();

        // * Loop through a query of OrderItems related to the activatedOrderIds
        for(OrderItem oi: [
                    SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity
                    FROM OrderItem
                    WHERE OrderId IN :activatedOrderIds
                ]){
                    // * Populate the map with the Id of the related Product2 as the key and Product2 record as the value
                    productMap.put(oi.Product2Id, oi.Product2);
                }
        

        
        // * we want to get the quantity ordered for the given product from ALL order items
        // * remember that Quantity is a field on OrderItem, representing how many were ordered for that order
        // * Quantity Ordered is a field on the Product itself, representing the total number ordered
        // * I believe the issue with the logic below is that it will not calculate properly
        // * If there are multiple Order Items that have the same product, it will continue to update 
        // *    in the loop, BEFORE it has been saved to the database
        // * Therefore, we need to sum up all of the values and then only update the value once

        // for(OrderItem oi: [SELECT Id, Product2Id, Product2.Quantity_Ordered__c, Quantity
        //                     FROM OrderItem
        //                     WHERE Product2Id IN :productMap.keySet()] ){
        //                         Product2 p = oi.Product2;
        //                         // p.Quantity_Ordered__c -= oi.Quantity;
        //                         p.Quantity_Ordered__c += oi.Quantity;
                                
        //                         productsToUpdate.add(p);
                                
        //                     }

        // * Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
        for(AggregateResult oi: [SELECT Product2Id, SUM(Quantity) aggregateQuantity 
                            FROM OrderItem 
                            WHERE Product2Id IN :productMap.keySet()
                            GROUP BY Product2Id]){
                                productMap.get((String)oi.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(oi.get('aggregateQuantity'));
                            }


        // * Perform an update on the records in the productMap
        if(productMap.values().size() > 0){

            update productMap.values();
        }


    }

}