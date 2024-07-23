/*******************************************************************************************
* @Name         sensorRecordsController
* @Author       Nika Gurchiani
* @Date         20.06.2024
* @TestClass    sensorRecordsControllerTest
* @Group        JetBI Bootcamp
* @Description  This class is created to handle Sensor Creation as well as the LWC logics
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Nika            20.06.2024           Initial Creation                                                      
*******************************************************************************************/
public class sensorRecordsController {
    
    /****************************************************************************************************************************************
    * @Description  This Method is used to return CSV string for Sensor records.
    *********************************************************************************************************************************************/
    @AuraEnabled
    public static String downloadSensorRecordsCSV() {
        // Query for Sensor records
        List<Sensor__c> sensors = [SELECT Status__c, Sensor_Model__c, Base_Station__c, Base_Station__r.Name FROM Sensor__c ORDER BY CreatedDate DESC];
        
        // CSV column headers
        String csvString = 'Status,Sensor Model,Base Station ID,Base Station Name\n';
        
        // Append each record data to the CSV string
        for(Sensor__c sensor : sensors) {
            String baseStationId = sensor.Base_Station__c != null ? sensor.Base_Station__c : '';
            String baseStationName = sensor.Base_Station__r != null ? sensor.Base_Station__r.Name : '';
            csvString += sensor.Status__c + ',' + sensor.Sensor_Model__c + ',' + baseStationId + ',' + baseStationName + '\n';
        }
        
        return csvString;
    }


    /****************************************************************************************************************************************
    * @Description  This Method is used to upload CSV and create Sensor__c records.
    *********************************************************************************************************************************************/
    @auraenabled
    public static void uploadCSV(String fileId) {

        List<Sensor__c> sensorsToInsert = new List<Sensor__c>();
        
        // Fetch the uploaded CSV file content
        ContentVersion csvFile = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId LIMIT 1];
        
        if (csvFile  != null) {
            // Convert CSV file content to String
            String csvData = csvFile.VersionData.toString();
            
            List<String> rows = csvData.split('\n');
            
            for (Integer i = 1; i < rows.size(); i++) { // Skip header row
                String row = rows[i];
                         
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
    * @Description  This Method is used to get Custom metadata values in LWC
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