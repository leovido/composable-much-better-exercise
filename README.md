
<div style="block: inline">
    <img alt="AppView for composable-much-better-exercise; Christian Ray Leovido" src="https://user-images.githubusercontent.com/18484997/137920419-cac28727-659d-4881-a9ef-73773557716e.png" width="30%">
<img alt="AppView for composable-much-better-exercise; Christian Ray Leovido" src="https://user-images.githubusercontent.com/18484997/137920437-ad21c431-3da6-4ffa-ba8f-c4fb51f4e2cd.png" width="30%">
  
  <img alt="SpendView" src="https://user-images.githubusercontent.com/18484997/137920444-053aa9db-49de-4c52-a65e-6011e7761eb4.png" width="30%" >
  
  </div>

# composable-much-better-exercise (TCA) [![Swift Version](https://img.shields.io/badge/swift-5.5-orange)](https://github.com/apple/swift) ![iOS version](https://img.shields.io/badge/iOS%20version-15.0-blue) ![architecture](https://img.shields.io/badge/architecture-TCA-brightgreen) ![Follow](https://img.shields.io/twitter/follow/c_leovido?style=social)

Simple finance iOS app.

## Technical overview
- [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture)
- Swift Package Manager
- Unit tests
- UI tests
- Modularisation


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

All features are isolated within their own components. 

These components are stored in folders here: [MuchBetterDependencies > Sources](https://github.com/kuriishu27/composable-much-better-exercise/tree/main/MuchBetterDependencies/Sources)


## Screenshots

<img src="https://user-images.githubusercontent.com/18484997/137920419-cac28727-659d-4881-a9ef-73773557716e.png" alt="AppView for composable-much-better-exercise; Christian Ray Leovido"
	title="AppView for composable-much-better-exercise" width="250" align=left />
  
<img src="https://user-images.githubusercontent.com/18484997/137920437-ad21c431-3da6-4ffa-ba8f-c4fb51f4e2cd.png" alt="AppView for composable-much-better-exercise; Christian Ray Leovido"
	title="AppView with TransactionView for composable-much-better-exercise" width="250" align=left />
  
  <img src="https://user-images.githubusercontent.com/18484997/137920444-053aa9db-49de-4c52-a65e-6011e7761eb4.png" alt="AppView for composable-much-better-exercise; Christian Ray Leovido"
	title="Spend for composable-much-better-exercise" width="250" align=left />
  



