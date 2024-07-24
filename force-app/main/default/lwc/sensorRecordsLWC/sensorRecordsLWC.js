/*******************************************************************************************
* @Author       Nika Gurchiani
* @Date         22.07.2024
* @controller   sensorRecordsController
* @Group        JetBI Bootcamp
* @Description  This is CSV file handler and LWC datatable with actions for JETBI Project
*******************************************************************************************/

import { LightningElement, api, track, wire } from 'lwc';
import uploadFileClass from '@salesforce/apex/sensorRecordsController.uploadCSV';
import getSensors from '@salesforce/apex/sensorRecordsController.getSensors';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import getMetadata from '@salesforce/apex/sensorRecordsController.getCustomMetadata';
import downloadSensorRecordsCSV from '@salesforce/apex/sensorRecordsController.downloadSensorRecordsCSV';

const actions = [
    { label: 'Delete', name: 'delete' },
];

const columns = [
    { label: 'Name', fieldName: 'nameLink', type: 'url' , typeAttributes:{label: { fieldName: 'Name' }}},
    { label: 'Sensor model', fieldName: 'Sensor_model__c' },
    { label: 'Status', fieldName: 'Status__c'},
    { label: 'Base Station name', fieldName: 'BaseStation'},  
    {
        type: 'action',
            typeAttributes: { rowActions: actions },
                },
];

export default class sensorRecordsLWC extends LightningElement {
    
    sensors = [];
    columns = columns;
    wiredSensors;
    totalRecords = 0;
    totalPages; 
    startingPoint = 0;
    pageNumber = 1;
    
    @api recordId;
    @track uploadedFiles;
    @track recordNumber;
    @track recordsPerPage =[];
    
    
    //Options for records per page
    get options(){
        return [
            {label:'10', value:'10'},
            {label:'25', value:'25'},
            {label:'50', value:'50'},
            {label:'100', value:'100'},
            {label:'200', value:'200'}
        ];
    } 
    
    
    /************************************************************************
    * @Description Imparative call to apex, upload sensors from CSV file
    *****************************************************************************/
    handleUploadFinished(event) {
        this.uploadedFiles = event.detail.files;
        
        if (this.uploadedFiles.length > 0) {
            const fileId = this.uploadedFiles[0].documentId;
            uploadFileClass({ fileId })
                .then(result => {
                    this.showNotification('Success', "Record created successfully!", 'success');
                    this.success = true;
                    return refreshApex(this.wiredSensors);
                })
                .catch(error => {
                    
                    this.showNotification('Error', 'An error occurred while creating records','error');
                    
                });
        }
    }
    
    
    /************************************************************************
     @Description call this method when you need toast notification
    *****************************************************************************/
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
                message,
                variant,
                });
        this.dispatchEvent(evt);
    }
    
    
    /************************************************************************
    * @Description This method handles Delete row action
    *****************************************************************************/
    handleRowAction(event) {
        
        const recId = event.detail.row.Id;
        deleteRecord(recId).then(result => {
            
            this.showNotification('Success',"Record deleted successfully!",'success');
            return refreshApex(this.wiredSensors);
            //this.updateDisplayedRecords();
            
        }).catch((error) => {
            
            this.showNotification('Error',',An error occurred while deleting records','Error');
        })
            }
    
    
    /************************************************************************
    * @Description This wire is responsible for fetching data for Sensors Datatable
    *****************************************************************************/
    @wire(getSensors)
    getourSensors(result) {
        
        this.wiredSensors = result;
        
        if (result.data) {
            
            this.totalRecords = result.data.length;
            
            result.data = JSON.parse(JSON.stringify(result.data));
            result.data.forEach(res => {
                res.nameLink = '/' + res.Id;
            });
            
            this.sensors = result.data.map( row => {
                return { ...row, Sensor_model__c: row.Sensor_model__c, Status__c: row.Status__c, BaseStation: row.Base_Station__r ? row.Base_Station__r.Name : ''};
                    })
                this.paginationHelper();
        } else if (result.error) {
            
            this.error = result.error;
            result.sensors = undefined;
        }
    }
    

    /************************************************************************
    * @Description This wire is responsible for fetching Custom Metadata
    *****************************************************************************/
    @wire(getMetadata)
    getcustomMetadata({error,data}){
        
        if(data){
            this.recordNumber = data;
            this.error = undefined;
            this.paginationHelper();
            
        } else if(error){
            this.error = error;
            this.recordNumber = undefined;
        }
    }
    
    //On Change handler for Records Per page
    handleChange(event){    
        this.recordNumber = event.target.value;   
        this.paginationHelper();
    }
    
    
    /************************************************************************
    * @Description All below methods are responsible for paginatioon operations
    *****************************************************************************/
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }
    
    //PaginationHelper
    paginationHelper() {
        this.recordsPerPage = [];
        // calculate total pages
        this.totalPages = Math.ceil(this.totalRecords / this.recordNumber);
        
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.recordNumber; i < this.pageNumber * this.recordNumber; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsPerPage.push(this.sensors[i]);
        }
    }
    
    //Disable pagination buttons accordingly
    get disableFirst() {
        return this.pageNumber == 1;
    }
    get disableLast() {
        return this.pageNumber == this.totalPages;
    }


    downloadCSV() {
        downloadSensorRecordsCSV({ recordId: this.recordId })
            .then(result => {
                let csvContent = "data:text/csv;charset=utf-8," + result;
                const encodedUri = encodeURI(csvContent);
                const link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", "sensorRecords.csv");
                document.body.appendChild(link); // Mozilla firefox specific
                link.click(); 
                
                // Show success toast message
                this.showNotification('Success', 'The CSV file has been downloaded.', 'success');
            })
            .catch(error => {
                console.error('Error downloading the CSV file', error);
                // Show error toast message
                this.showNotification('Error', 'Failed to download the CSV file.', 'error');
            });
    }
}