/*******************************************************************************************
* @Name         fileUploadController 
* @Author       Nika Gurchiani
* @Date         20.06.2024
* @TestClass    fileUploadControllerTest
* @Group        JetBI Bootcamp
* @Description  This class is created to handle Sensor Creation as well as the LWC logics
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Nika            20.06.2024           Initial Creation                                                      
*******************************************************************************************/

public class fileUploadController {
    /****************************************************************************************************************************************
* @Description  This Method is used to get CSV and create Sensor__c records. 
*********************************************************************************************************************************************/
    @auraenabled
    public static void uploadFile(String fileId) {

        List<Sensor__c> sensorsToInsert = new List<Sensor__c>();
        
        // Fetch the uploaded CSV file content
        ContentVersion csvFile = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId LIMIT 1];
        
        if (csvFile  != null) {
            // Convert CSV file content to String
            String csvData = csvFile.VersionData.toString();
            
            List<String> rows = csvData.split('\n');
            
            for (String row : rows) {   
                         
                List<String> data = row.split(',');
                System.Debug('deb'+data);
                Sensor__c record = new Sensor__c();
                record.Status__c = data[0];
                record.Sensor_Model__c = data[1];
                record.Base_Station__c = Id.ValueOf(data[2].ReplaceAll('\r', ''));
                sensorsToInsert.add(record);
            }
        }
        database.insert(sensorsToInsert,false);
    }
 
/****************************************************************************************************************************************
* @Description  This Method is used LWC to fetch Sensor Records on LWC datatable
*********************************************************************************************************************************************/
    @auraenabled(cacheable =true)
    public static List<Sensor__c> getSensors(){
        return [Select id, Name, Base_Station__r.Name, Sensor_model__c, Status__c  from Sensor__c Order By CreatedDate DESC];
    }

      /****************************************************************************************************************************************
* @Description  This Method is used to get Custome metadata values in LWC
*********************************************************************************************************************************************/
    
    @AuraEnabled (cacheable=true)
    public static List<String> getCustomMetadata(){
        List<String> pageSizeOptions = new List<string>();
        
        for(PageNumber__mdt mtd :[Select MasterLabel, DeveloperName from PageNumber__mdt]) {
            
            pageSizeOptions.add((String) mtd.MasterLabel);
        }
        return pageSizeOptions;
    }
}