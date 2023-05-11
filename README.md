# Take profits!

## Motivation

WAGMI and HODL are crypto memes that do more harm than good. DCAing into crypto is a good strategy but knowing when to exit (taking profits) is just as important. Otherwise you just keep reentering the market.

This tool can help you exit trades with a profit.

## How it works

This tool creates a lambda function that will be triggered every 6 hours (you can change the interval). The function will check if any of your trades have reached your defined profit target and will notify you via Slack if that's the case. Then it's up to you to decide if you want to sell or not.

## Pre-requisites

You need 4 things to run this:

- An AWS account where the function will be deployed
- A list of trades. Check the data folder for examples on how to format your trades
- The [serverless framework](https://www.serverless.com/framework/docs/getting-started) installed on your machine
- A Slack webhook URL to receive notifications. Once you have that, create an env.json file in the root of the project with the following content:

```
{
  "SLACK_WEBHOOK_URL": "/your_unique_string"
}
```
