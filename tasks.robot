*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${False}    #Library used for working with Browser
Library           RPA.Robocorp.Vault    #Library used for credential usage from env.json
Library           RPA.HTTP    #Library used for Download File
Library           RPA.Excel.Files    #Library used to working with Excel or csv files.
Library           RPA.Robocloud.Items
Library           RPA.Desktop.Windows
Library           RPA.PDF
Library           DateTime
Library           String
Library           OperatingSystem
Library           RPA.Tables
Library           RPA.Desktop
Library           RPA.Tasks
Library           RPA.Archive
Library           RPA.Dialogs

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open Order Web Site
    ${user_input}    Taking User Input for URL of order csv
    Download the orders file    ${user_input}
    Fill the order using data from the csv File
    Creating a Zip archives
    Log out and close the browser
    Log    Done.

*** Keywords ***
Open Order Web Site
    Open Available Browser    https://robotsparebinindustries.com/
    ${Secret}=    Get Secret    robotsparebin
    Input Text    username    ${Secret}[username]
    Input Password    password    ${Secret}[password]
    #Input Text    username    maria
    #Input Password    password    thoushallnotpass
    Submit Form
    Wait Until Page Contains Element    id:sales-form
    Click Element If Visible    xpath://a[contains(@href, '#/robot-order')]
    Wait Until Element Contains    xpath://button[contains(.,'OK')]    OK
    Click Element If Visible    xpath://button[contains(.,'OK')]

*** Keywords ***
Taking User Input for URL of order csv
    Add heading    Advance Order Robot
    Add text input    DownloadSite    label=Enter URL of the orders CSV file
    ${user_input}    Run dialog    height=500    width=400    title=Advance Order Robot
    [Return]    ${user_input}

*** Keywords ***
Download the orders file
    [Arguments]    ${user_input}
    Download    ${user_input.DownloadSite}    overwrite=True
    #Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

*** Keywords ***
Fill the order using data from the csv File
    ${orders_list}=    Read table from CSV    orders.csv    header=True
    FOR    ${order_number}    IN    @{orders_list}
        Fill and submit the one order    ${order_number}
    END

*** Keywords ***
Fill and submit the one order
    [Arguments]    ${order_number}
    Select From List By Value    head    ${order_number}[Head]
    Select Radio Button    body    ${order_number}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order_number}[Legs]
    Input Text    address    ${order_number}[Address]
    ${Date}=    Get Current Date
    ${CurrDate}=    Get Substring    ${Date}    0    10
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview
    Click Element If Visible    id:order
    Click Element If Visible    id:order
    Click Element If Visible    id:order
    Click Element If Visible    id:order
    Click Element If Visible    id:order
    Wait Until Element Is Visible    id:receipt
    ${order_receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt_html}    ${OUTPUT_DIR}${/}${CurrDate}${/}order-${order_number}[Order number]-receipt.pdf
    RPA.Browser.Selenium.Screenshot    id:robot-preview    ${OUTPUT_DIR}${/}${CurrDate}${/}order-${order_number}[Order number]-preview.png
    Wait Until Element Is Visible    id:receipt
    Open Pdf    ${OUTPUT_DIR}${/}${CurrDate}${/}order-${order_number}[Order number]-receipt.pdf
    Add Watermark Image To Pdf    ${OUTPUT_DIR}${/}${CurrDate}${/}order-${order_number}[Order number]-preview.png    ${OUTPUT_DIR}${/}${CurrDate}${/}order-number-${order_number}[Order number].pdf
    Close Pdf
    Remove File    ${OUTPUT_DIR}${/}${CurrDate}${/}order-${order_number}[Order number]-preview.png
    Remove File    ${OUTPUT_DIR}${/}${CurrDate}${/}order-${order_number}[Order number]-receipt.pdf
    #Add To Archive    ${OUTPUT_DIR}${/}${CurrDate}${/}order-number-${order_number}[Order number].pdf    ${OUTPUT_DIR}${/}orders-${CurrDate}.zip
    Wait Until Element Is Visible    id:order-another
    Click Button    id:order-another
    Wait Until Element Contains    xpath://button[contains(.,'OK')]    OK
    Click Element If Visible    xpath://button[contains(.,'OK')]

*** Keywords ***
Creating a Zip archives
    ${Date}=    Get Current Date
    ${CurrDate}=    Get Substring    ${Date}    0    10
    Archive Folder With ZIP    ${OUTPUT_DIR}${/}${CurrDate}    orders-${CurrDate}.zip    recursive=True    include=*.pdf    exclude=/.*

*** Keywords ***
Log out and close the browser
    Click Button    Log out
    Close Browser
