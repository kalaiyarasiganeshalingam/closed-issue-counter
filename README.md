# closed-issue-counter

This project is used to schedule the recurrence task to get the number of issues resolved in every label of a GitHub repo on a given date and add that count into the spreadsheet.

## Prerequisites

* Ballerina Swan Lake Beta1 Installed

* Update the `config.toml` file with spreadsheet and github credentials.
    * Obtain spreadsheet credential
        * Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard to create a new project.
        * Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
        * On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**.
        * Select an application type, enter a name for the application, and specify a redirect URI (enter https://developers.google.com/oauthplayground if you want to use 
         [OAuth 2.0 playground](https://developers.google.com/oauthplayground) to receive the authorization code and obtain the access token and refresh token).
        * Click **Create**. Your client ID and client secret appear. 
        * In a separate browser window or tab, visit [OAuth 2.0 Playground](https://developers.google.com/oauthplayground). 
          Click on the `OAuth 2.0 Configuration` icon in the top right corner and click on `Use your own OAuth credentials` and
          provide your `OAuth Client ID` and `OAuth Client Secret`.
        * Then click **Authorize APIs**.
        * When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the access token and refresh token.
    * To obtain github credential, see [Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) or [GitHub OAuth App token](https://docs.github.com/en/developers/apps/creating-an-oauth-app).
    
## Run the App

To run this, move into the csv-data-cleaner and execute the below command.

    bal run

## Sample request

### Create Spread Sheet

    curl -v -X POST http://localhost:9092/issue/createSpreadSheet/[SPREAD_SHHET_NAME]
    Eg: curl -v -X POST http://localhost:9092/issue/createSpreadSheet/test
### Create Sheet

    curl -v -X POST http://loc9092/issue/createSheet/[SPREAD_SHEET_ID]/[SHEET_NAME]
    Eg: curl -v -X POST http://localhost:9092/issue/createSheet/xxxxx/test

### Add issue details into the created/new sheet

    curl -v -X POST http://localhost:9092/issue/addRecord/[SPREAD_SHEET_ID]/[SHEET_NAME] --data "[ISSUE_DETAILS_FILE]"
    Eg: curl -v -X POST http://localhost:9092/issue/addRecord/xxxxx/test --data "data.txt"
    Note: Default details are in the `data.txt` file. You can use that file or create a new file with data which should be separated by `,`.

### Schedule the recurrence task forever to update issues' count

    curl -v -X POST http://localhost:9092/issue/updateCount/[SPREAD_SHEET_ID]/[SHEET_NAME] --data "{\"startTime\":\"START_TIME\", \"lastIndex\": \"LAST_DATA_ROW_OF_THE_SHEET\", \"columnNames\": \"[COLUMN_NAMES_TO_BE_UPDATED]\", \"interval\":\"DURATION_BETWEEN_EVERY_TRIGGER\"}"
    Eg: curl -v -X POST http://localhost:9092/issue/updateCount/xxxxxx/test --data "{\"startTime\":\"2021-06-30T13:21:00.000+05:30[Asia/Colombo]\", \"lastIndex\": \"96\", \"columnNames\": \"D,E,F,G\", \"interval\":\"10\"}"

### Schedule the recurrence task with a specific trigger count to update issues' count

    curl -v -X POST http://localhost:9092/issue/updateCount/[SPREAD_SHEET_ID]/[SHEET_NAME]/[TRIGGER_COUT] --data "{\"startTime\":\"START_TIME\", \"lastIndex\": \"LAST_DATA_ROW_OF_THE_SHEET\", \"columnNames\": \"[COLUMN_NAMES_TO_BE_UPDATED]\", \"interval\":\"DURATION_BETWEEN_EVERY_TRIGGER\"}"
    Eg: curl -v -X POST http://localhost:9092/issue/updateCount/1COOMrOmm4EctKrcDWW2tHm9yP3zliW2QVzgr-hqu87Q/test/5 --data "{\"startTime\":\"2021-06-30T13:21:00.000+05:30[Asia/Colombo]\", \"lastIndex\": \"96\", \"columnNames\": \"D,E,F,G\", \"interval\":\"10\"}"

### Shutdown service
    curl -v http://localhost:9092/csv/shutdown

