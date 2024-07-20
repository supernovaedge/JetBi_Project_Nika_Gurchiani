@isTest
public class fileUploadControllerTest {
    
    //method for creating all test data
    @testSetup
    public static void testData(){
 
        Base_Station__c bs = new Base_Station__c();
        bs.Name = 'testTest';
        bs.Status__c = 'Active';
        insert bs;
        
        Sensor__c sensor = new Sensor__c();
        sensor.Status__c = 'Active';
        sensor.Sensor_model__c = 'test Test';
        sensor.Base_Station__c = bs.Id;
        insert sensor;
        
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('Active, testTestTest,'+ bs.Id);
        insert newFile;
        
    }
    
    //method for checking file Creation Scenario
    @isTest
    public static void testScenarioContentDocument(){
        
        Id conId = [Select id, ContentDocumentId from ContentVersion where Title = 'TestFile'].ContentDocumentId;   
        fileUploadController.uploadFile(conId);      
    }
    
    //method for checking LWC controller
    @isTest
    public static void testScenarioFetchAccount(){
        Sensor__c sens = [Select id, Sensor_model__c from Sensor__c where Sensor_model__c = 'test Test'];
        
        fileUploadController.getSensors();
    }
   
    //method for checking LWC Custom Metadata
    @isTest
    public static void testScenarioFetchCustomMetadata(){
        
        PageNumber__mdt mtd = new PageNumber__mdt();
        fileUploadController.getCustomMetadata();
    }
    
}