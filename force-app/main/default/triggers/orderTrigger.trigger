/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (
    before update, after update
) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
    }
}