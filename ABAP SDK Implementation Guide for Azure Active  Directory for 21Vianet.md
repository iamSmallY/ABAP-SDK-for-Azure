

<p align="center">
<img width="450" height="100" src="MD%20image/1.png"> 
</p>

<H1 align="center">
<font size="16"> 
  <b> Implementation guide for Azure Active Directory for 21Vianet </b>
</font> 
</H1>

<p align="center"

<https://github.com/iamSmallY/ABAP-SDK-for-Azure>
</p>

<p align="right">
Author: iamSmallY
</p>
<p align="right">
Modified from: Implementation guide for Azure Active Directory
</p>
<p align="right">
Version: 1.0
</p>

<h2 class="title">
    Contents
</h2>

<div id="TOC">
    <ul>
        <li>
            <a href="#What is Azure Active Directory?">1. What is Azure Active Directory? </a>
        </li>
        <li>
            <a href="#Prerequisites">2. Prerequisites </a>
        </li>
        <li>
            <a href="#How to setup Azure Active Directory in Azure?">3. How to setup Azure Active Directory in Azure? </a>
        </li>
        <li>
            <a href="#Generate keys for your application">4. Generate keys for your application </a>
        </li>
        <li>
            <a href="#Steps to use AAD authentication from SAP using ABAP SDK for Azure">5. Steps to use AAD authentication from SAP using ABAP SDK for Azure </a>
        </li>
    </ul>
</div>

* [5.1 Creation of RFC destination to Azure Active Directory](#heading--1-1)
* [5.2 Configuration](#heading--1-3)
    * [ZREST_CONFIG ](#heading--1-4)
    * [ZREST_CONF_MISC ](#heading--1-5)
    * [ZADF_CONFIG ](#heading--1-6)
   
   
<div id="TOC">
    <ul>
        <li>
        <a href="#ABAP SDK Monitor">6. ABAP SDK Monitor </a>
        </li>
        <li>
            <a href="#Auto re-processing of failed messages">7. Auto re-processing of failed messages </a>
        </li>
    </ul>
</div>

<div id="What is Azure Active Directory?">
    <h2>
        <a href="#TOC">What is Azure Active Directory?</a>
    </h2>
    <p>
    </p>
</div>

Azure Active Directory (Azure AD) provides an easy way for businesses to manage identity and access, both in the cloud and on-premises. Your users can use the same work or school account for single sign-on to any cloud and on- premises web application. Users can use their favorite devices, including iOS, Mac OS X, Android, and Windows. An Organization can protect sensitive data and applications both on-premises and in the cloud with integrated multi- factor authentication ensuring secure local and remote access. Azure AD extends your on-premises directories so that information workers can use a single organizational account to securely and consistently access their corporate resources. Azure AD also offers comprehensive reports, analytics, and self-service capabilities to reduce costs and enhance security. The Azure AD SLA ensures that your business always runs smoothly and can be scaled to enterprise levels.

For more details on Azure Active directory, visit [Microsoft Azure
Active Directory](https://docs.microsoft.com/en-us/previous-versions/azure/azure-services/mt168838(v%3Dazure.100))

<div id="Prerequisites">
    <h2>
        <a href="#TOC">Prerequisites</a>
    </h2>
    <p>
        Make sure you have installed ABAP SDK for Azure in your SAP system. Refer document ‘ABAP SDK for Azure –
        GitHub’ for more details. 
    </p>
</div>

Visit <https://github.com/iamSmallY/ABAP-SDK-for-Azure>

<div id="How to setup Azure Active Directory in Azure?">
    <h2>
        <a href="#TOC">How to setup Azure Active Directory in Azure?</a>
    </h2>
</div>

Login to [Microsoft Azure portal - managed by 21Vianet](https://portal.azure.cn/#home)
> **Note**:If you do not have an account already. please create a new Azure account. You can start free Once you are logged into portal, ,  go to all services and search for Azure Active Directory and Select
“Azure Active Directory” as shown below.

![](MD%20image/21Vianet/1.jpeg)

Create a new tenant for your organization in case it hasn’t been created.
[https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-access-create-new-tenant](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-access-create-new-tenant)

Click on ‘App Registrations’ on left side menu as shown below and click the button ‘New Registration’

![](MD%20image/21Vianet/2.jpeg)

Specify details of your Application and press 'Register' button.

![](MD%20image/21Vianet/3.jpeg)

Application is created successfully.

![](MD%20image/21Vianet/4.jpeg)

<div id="Generate keys for your application">
    <h2>
        <a href="#TOC">Generate keys for your application</a>
    </h2>
</div>

1.	Once your application is created, go to your application by clicking on it.
Copy the application id which will be required in the implementation of code in ABAP SDK. This application id is client Id. Click on 'Certificates & secrets',

![](MD%20image/21Vianet/5.jpeg)

2.	Then click on 'New client secret' button as shown in the below screen. Then press 'Add' button on the popup dialog.

![](MD%20image/21Vianet/6.jpeg)

**Copy this key and it will be used in ABAP SDK implementation. Please remember you won’t be able to retrieve this key once you leave the screen.**

<div id="Steps to use AAD authentication from SAP using ABAP SDK for Azure">
    <h2>
        <a href="#TOC">Steps to use AAD authentication from SAP using ABAP SDK for Azure</a>
    </h2>
</div>

<div id="heading--1-1">
    <h3>
        <a href="#TOC">5.1 Creation of RFC destination to Azure Active Directory</a>
    </h3>
    <p>
    Go to transaction SM59 in your SAP system and create new RFC destination of type ‘G’. Maintain your Azure Active directory endpoint in the Target host and Event Hub name in path prefix for authorization token as shown below.
    </p>
</div>

Target host: **login.partner.microsoftonline.cn**

Port: 443

Path Prefix: **/\<TanentID\>/oauth2/v2.0/token**

For Tenant ID details and creating a new tenant id in Azure Active Directory, please refer this document section
‘How to setup Azure Active Directory in Azure?’

![](MD%20image/21Vianet/8.png)

Now go to ‘Logon & Security’ tab and choose radio button SSL ‘Active’ and select SSL certificate ‘DFAULT SSL Client (Standard)’.

![](MD%20image/21Vianet/9.png)

Do a connection test to make sure it is working. RFC destination is working.

![](MD%20image/21Vianet/10.png)

<div id="heading--1-3">
    <h3>
        <a href="#TOC">5.2 Configuration</a>
    </h3>
    <p>
   ABAP SDK has following main configuration tables and they need to be maintained. We will create a new Interface ID to establish connection between SAP system and target Azure Active Directory (AAD). A new Interface ID needs to be created for each AAD namespace.
    </p>
</div>

**ZREST_CONFIG** – Master Table for Interface ID Maintenance. You must define a new Interface name and maintain the RFC destination that was created for target Event hub.

**ZREST_CONF_MISC** – This is an Interface Miscellaneous table which contains information on Alerts and re-processing of failed messages automatically.

**ZADF_CONFIG** – This is an Interface extension table. This stores data that is more specific to Azure Services like SAS keys, AAD secrets and processing Method.

<div id="heading--1-4">
    <h3>
        <a href="#TOC">ZREST_CONFIG</a>
    </h3>
    <p>
   Create a new Interface ID like ‘DEMO_AAD’ and Maintain the RFC destination you created earlier.
    </p>
</div>

![](MD%20image/52.png)

<div id="heading--1-5">
    <h3>
        <a href="#TOC">ZREST_CONF_MISC</a>
    </h3>
    <p>
   Create an entry in table ‘ZREST_CONF_MISC’ for the above interface Id ‘DEMO_AAD’.
    </p>
</div>

Details of configuration:

•	METHOD is ‘POST’.

•	MAX_RETRY is number of retry in case of service failure.

•	EMAIL_ID is the email id for sending alerts.

•	MAIL_BODY_TXT is Text Id to be maintained for the mail content.

•	RETRY_METHOD is type of retrial (Regular ‘0’ or exponential ‘1’)

![](MD%20image/53.png)

<div id="heading--1-6">
    <h3>
        <a href="#TOC">ZADF_CONFIG</a>
    </h3>
    <p>
   Create an entry in table ‘ZADF_CONFIG’ for the above interface Id ‘DEMO_AAD’.
    </p>
</div>

Details of configuration:

•	INTERFACE_TYPE is ‘Azure Active Directory’.

•	SAS_KEY is the shared access key. This is the key which   generated in AAD under section ‘Generate keys for your application’ Step 7 (refer Page 8). You need to change this key in this config table whenever key is changed in Azure.

•	URI is left blank. This may be required for future versions.

•	SERVICE_TYPE can be synchronous(S) or asynchronous(A)

•	IS_TRY is a reprocessing flag, maintain as blank or ‘X’. it can be configured for reprocessing in case of failure of services.

>**Note**:This field can be utilized in our future release to control the reprocessing based on value of X. Presently it's should be enabled as blank.

![](MD%20image/54.png)

<div id="ABAP SDK Monitor">
    <h2>
        <a href="#TOC">ABAP SDK Monitor </a>
    </h2>
    <p>
We have provided an Interface Monitor (Transaction ZREST_UTIL), using this monitor you can view history of all the messages that were posted to Azure Services. Incase you have a scheduled a background job to post messages to Azure, you can view the statuses of the messages in this monitor. This Monitor can be used for troubleshooting and re-processing of the message as well.
    </p>
</div>

Go to transaction ZREST_UTIL and provide your Interface ID in the selection screen and execute to view all the messages

![](MD%20image/56.png)

In this monitor, you can view the status of the HTTPs message and its headers, response, payload and so on. In case of errors, you can also re-process the message from this tool.

![](MD%20image/57.png)

<div id="Auto re-processing of failed messages">
    <h2>
        <a href="#TOC">Auto re-processing of failed messages</a>
    </h2>
     <p>
     For auto-processing of messages in case of failures, you must schedule a background job for program ‘ZREST_SCHEDULER’ as a pre-requisite
     <p>
</div>



















