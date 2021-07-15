import ballerina/http;
import ballerina/task;
import ballerina/jballerina.java;
import github_spreadsheet_integration.gsheet;
import github_spreadsheet_integration.schedule;
import github_spreadsheet_integration.utils;

configurable string sheet_refresh_token = ?;
configurable string sheet_client_id = ?;
configurable string sheet_client_secret = ?;

gsheet:SpreadsheetConfiguration spreadsheetConfig = {
    oauthClientConfig: {
    clientId: sheet_client_id,
    clientSecret: sheet_client_secret,
    refreshToken: sheet_refresh_token,
    refreshUrl: gsheet:REFRESH_URL
}};

gsheet:Client gsheetClient = check new(spreadsheetConfig);

listener http:Listener issueCounter = new (9092);

service /issue on issueCounter {

    resource function post createSpreadSheet/[string sheetName]() returns string|error {
        return check gsheetClient->createSpreadsheet(sheetName);
    }

    resource function post createSheet/[string spreadSheetId]/[string sheetName]() returns string|error {
        return check gsheetClient->addSheet(spreadSheetId, sheetName);
    }

    resource function post addRecord/[string spreadSheetId]/[string sheetName](@http:Payload string path) returns string|error {
        return check utils:addRepoDetails(gsheetClient, spreadSheetId, sheetName, path);
    }

    resource function post updateCount/[string spreadSheetId]/[string sheetName](@http:Payload json payload) returns error|string {
        task:JobId id = check schedule:scheduleTask(gsheetClient, spreadSheetId, sheetName, payload);
        return id.toString();
    }

    resource function post updateCount/[string spreadSheetId]/[string sheetName]/[int count](@http:Payload json payload) returns error|string {
        if (count > 0) {
            task:JobId id = check schedule:scheduleTask(gsheetClient, spreadSheetId, sheetName, payload, count);
            return id.toString();
        } else {
            return error("Count should be grater than 1.");
        }
    }

    resource function get shutdown () {
        system_exit(0);
        return;
    }
}

function system_exit(int arg0) = @java:Method {
    name: "exit",
    'class: "java.lang.System",
    paramTypes: ["int"]
} external;
