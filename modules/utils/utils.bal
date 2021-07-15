import ballerina/io;
import ballerina/regex;
import github_spreadsheet_integration.gsheet;

public isolated function addRepoDetails(gsheet:Client gsheetClient, string spreadsheetId, 
                                        string sheetname, string path) returns string|error {
    string[] listResult = check io:fileReadLines(path);
    string[][] records = [];
    foreach string item in listResult {
        records.push(regex:split(item, ","));
    }
    int lastIndex = records.length() + 2;
    check gsheetClient->addData(spreadsheetId, sheetname, "A2:C" + (records.length() + 2).toString(), records);
    return "Data added.";
}

