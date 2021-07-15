import ballerina/task;
import ballerina/io;
import github_spreadsheet_integration.gsheet;
import ballerina/regex;
import ballerina/time;

class Job {

    *task:Job;
    gsheet:Client gsheetClient;
    string spreadsheetId; 
    string sheetname;
    string lastIndex = "";
    string[] columnNames = [];
    int i = 0;

    public function execute() {
        io:println("Job started to executed.");
        string[][]|error repoDetails = self.gsheetClient->getData(self.spreadsheetId, self.sheetname, string `B3:B${self.lastIndex}`);
        time:Utc date = time:utcNow();
        time:Civil civil = time:utcToCivil(date);
        string months = civil.month.toString();
        if (months.length() == 1) {
            months = "0" + months;
        }
        string days = civil.day.toString();
        if (days.length() == 1) {
            days = "0" + days;
        }
        string dateInString = (civil.year).toString() + "-" + months + "-" + days;
        if repoDetails is string[][] {
        
            string[][]|error colsedIssueCounts = getColsedIssueCounts(repoDetails, dateInString);
            if colsedIssueCounts is string[][] {
                if (self.i >= self.columnNames.length()) {
                    self.i = 0;
                }
                string columnName = self.columnNames[self.i];
                error? data = self.gsheetClient->addData(self.spreadsheetId, self.sheetname, string `${columnName}2:${columnName}${self.lastIndex}`, colsedIssueCounts);
                if (data is error) {
                    io:println("Error:", data);
                } else {
                    io:println("Closed issue count of " + dateInString + " updated successfully!");
                }

            } else {
                io:println("Error:", colsedIssueCounts);
            }
        } else {
            io:println("Error:", repoDetails);
        }
        self.i = self.i + 1;
    }

    isolated function init(gsheet:Client gsheetClient, string spreadsheetId, 
                                        string sheetname, json payload) {
        self.gsheetClient = gsheetClient;
        self.spreadsheetId = spreadsheetId; 
        self.sheetname = sheetname;
        json|error unionResult = payload.lastIndex;
        if unionResult is json {
            self.lastIndex = unionResult.toString();
        }
        unionResult = payload.columnNames;
        if unionResult is json {
            self.columnNames = regex:split(unionResult.toString(), ",");
        }
    }
}