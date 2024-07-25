@isTest(seeAllData = false)
public class sensorRecordsControllerTest {
    
    //method for creating all test data
    @testSetup
    public static void testData(){
        
        Base_Station__c bs = new Base_Station__c();
        bs.Name = 'testTest';
        bs.Status__c = 'Active';
        insert bs;
        
        String csvContent = 'Status,SensorModel,BaseStationId\n' + // Header
                            'Active,testModel1,' + bs.Id + '\n' + // Data row 1
                            'Inactive,testModel2,' + bs.Id; // Data row 2
        
        Sensor__c sensor = new Sensor__c();
        sensor.Status__c = 'Active';
        sensor.Sensor_model__c = 'test Test';
        sensor.Base_Station__c = bs.Id;
        insert sensor;
        
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf(csvContent);
        insert newFile;
        
    }
    
    //method for checking file Creation Scenario
    @isTest
    public static void testScenarioContentDocument(){
        
        Id conId = [Select id, ContentDocumentId from ContentVersion where Title = 'TestFile'].ContentDocumentId;   
        sensorRecordsController.uploadCSV(conId);      
    }
    
    //method for checking LWC controller
    @isTest
    public static void testScenarioFetchAccount(){
        List<Sensor__c> sens = [Select id, Sensor_model__c from Sensor__c where Sensor_model__c = 'test Test'];
        assert.areEqual(1, sens.size());
        sensorRecordsController.getSensors();
    }
    
    //method for checking LWC Custom Metadata
    @isTest
    public static void testScenarioFetchCustomMetadata(){
        
        PageNumber__mdt mtd = new PageNumber__mdt();
        sensorRecordsController.getCustomMetadata();
    }
    
    @isTest
    public static void testScenarioDownloadCSV(){
        sensorRecordsController.downloadSensorRecordsCSV();
    }
    
}