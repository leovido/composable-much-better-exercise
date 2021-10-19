# composable-much-better-exercise (TCA)
Finance demo iOS app. 

## Technical overview
This is a project demonstrating the capabilities of [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) and Swift Package Manager.
TCA allows developers to fully encapsulate state, actions and environment to control its side effects.

This allows for easier dependency management where we can have more control of what goes where when needed.

Compared to other ways of building and developing applications, TCA allows for building new **Features** in parallel in a big team.

## About the app
The application logs in silenty in the background requesting for a token that will be used to fetch the balance and transactions from the user.

## For developers running the code
To run the app, open the .xcworspace file and Xcode will start fetching the dependencies. All you need to do is select "composable-much-better-exercise" scheme and run the app with a Simulator @ iOS 15.0.

By default, the app will run in "mock" mode. This is to avoid any third party real API requests. This can be swapped easily by changing **.mock** from the @main AppView's store to **.live**

## Features

- App
- Login
- Balance
- Transactions
- Spend

All features are isolated within their own components. These components are stored in folders here: [MuchBetterDependencies > Sources](https://github.com/kuriishu27/composable-much-better-exercise/tree/main/MuchBetterDependencies/Sources)


