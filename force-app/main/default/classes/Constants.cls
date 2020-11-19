public with sharing class Constants {
    static final Integer DEFAULT_ROWS = 5;
    static final String SELECT_ONE = Label.Select_One;
    static final String INVENTORY_LEVEL_LOW = Label.Inventory_Level_Low;
    static final List<Schema.PicklistEntry> PRODUCT_FAMILY = Product2.Family.getDescribe().getPicklistValues();
    static final String DRAFT_ORDER_STATUS = 'Draft';
    static final String ACTIVATED_ORDER_STATUS = 'Activated';
    static final String INVENTORY_ANNOUNCEMENTS = 'Inventory Announcements';
    static final String ERROR_MESSAGE = 'An error has occurred, please take a screenshot with the URL and send it to IT.';
    static final Id STANDARD_PRICEBOOK_ID = [SELECT Id, Name, IsStandard FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
}
