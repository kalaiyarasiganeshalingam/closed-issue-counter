import ballerina/io;
import ballerina/task;
import github_spreadsheet_integration.github;
import github_spreadsheet_integration.gsheet;
import ballerina/time;
import ballerina/regex;

configurable string github_access_token = ?;
configurable string repositoryOwner = "ballerina-platform";

github:Configuration config = {
    accessToken: github_access_token
};

public isolated function scheduleTask(gsheet:Client gsheetClient, string spreadsheetId, 
                                        string sheetname, json payload, int? count = ()) returns error|task:JobId {
    string civliInString = (check payload.startTime).toString();
    
    time:Civil startTime = {day: 0, hour: 0, minute: 0, month: 0, year: 0};
    if (civliInString != "") {
        startTime = check time:civilFromString(civliInString);
    }
    decimal interval = check decimal:fromString((check payload.interval));
    if (count is int) {
        return check task:scheduleJobRecurByFrequency(new Job(gsheetClient, spreadsheetId, sheetname, payload), interval, count, startTime);
    } else {
        return check task:scheduleJobRecurByFrequency(new Job(gsheetClient, spreadsheetId, sheetname, payload), interval, startTime = startTime);
    }
}

function getColsedIssueCounts(string[][] entries, string date) returns string[][] {
    string[][] totalCount = [[date]];
    github:Client|error githubClient = new (config);
        if (githubClient is github:Client) {
        
        foreach string[] entry in entries {
            string[] count =[];
            string[] orgname = regex:split(entry[0], ":");
            json|error issueCount;
            if (orgname.length() > 1) {
                issueCount = githubClient->getRepositoryIssueList(repositoryOwner, orgname[0], date, orgname[1]);
            } else {
                issueCount = githubClient->getRepositoryIssueList(repositoryOwner, orgname[0], date);
            }
            if (issueCount is json) {
                json|error value = issueCount.data.search.issueCount;
                if (value is json) {
                    count.push(value.toString());
                    totalCount.push(count);
                } else {
                    io:println(value);
                }
            } else {
                io:println(issueCount);
            }
        }
    } else {
        io:println(githubClient);
    }
    return totalCount;
}
