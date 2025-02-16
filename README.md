
---

_Project created by **Andrea De Lorenzis**_

---

# Budget Buddy: Personal Finance Application

## Presentation

BudgetBuddy is a personal finance management app developed as a project during the "Mobile Devices Programming and User Interfaces" course of the Master’s in Computer Science at the University of Urbino. Its main goal is to provide users with a simple yet effective tool to monitor and manage their daily finances. It’s available on both Android and Web platforms.

The main features of the app are:

- **Transaction Management:** Users can record their transactions by categorizing expenses and deposits, helping them keep track of outflows and inflows in an organized manner.
- **Visual Analysis of Movements:** Through various charts, users can view the categorization of transactions, offering a clear overview of their spending habits.
- **Financial Planning:** The app allows users to create a financial plan for a specific period, enabling them to calculate the projected balance and profits month by month.

---

## ## Use Cases

1. A user, Mario, uses BudgetBuddy to record his daily expenses and incomes. He enters the details of each transaction—like rent, grocery shopping, or utility bill payments—and can set transactions as recurring so they’re automatically added on specific dates.
2. At the end of the month, Mario checks the app’s charts to see a summary of all transactions, comparing them with previous months. He notices he spends too much on dining out and decides to cut back next month.
3. Mario wants to save for a trip. He uses the financial planning feature to view his financial situation over the next six months. By entering his initial balance and estimating monthly expenses and deposits, the app calculates how much he can save each month and what his balance will be at the end of the period, helping him reach his goal.

---

## ## User Experience

### Splash Screen

The splash screen is the first thing users see when opening the app. It uses the loading time to display a branding logo.

<p align="center"> <img src="assets/screenshots/splash_screen.png" alt="Splash screen" width="200"/> </p>

### Authentication

If the user’s session expires, they are taken to the "Sign In" page to reauthenticate. First-time users must go to the "Sign Up" page to create a new account. If a user has previously logged in but can’t remember their credentials, they can request a password reset via email using the dedicated page.

For login, you can use the following demo account to test a pre-populated profile with mock data:

- email: mariorossi@gmail.com
- password: 123456

<p align="center"> <img src="assets/screenshots/login_screen.png" alt="Login screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/signup_screen.png" alt="Signup screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/forgot_password.png" alt="Forgot Password screen" width="200"/> </p>

### Transaction Log

After logging in, users are directed to the "History" page, which shows a log of all transactions. Here, they can add a new transaction using the button at the bottom right or, by long-pressing on an existing transaction, enter selection mode to choose one for editing or multiple for deletion.

<p align="center"> <img src="assets/screenshots/history_screen.png" alt="History screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/add_transaction.png" alt="Add Transaction screen" width="196" style="margin-right: 20px"/> <img src="assets/screenshots/edit_transaction.png" alt="Edit Transaction screen" width="200"/> </p>

### Charts

If data has been added on the "History" page, the "Charts" page displays a graph breaking down the user’s expenses by category. By selecting the dropdown menu at the top, the same graph can be viewed for the account's incomes.

<p align="center"> <img src="assets/screenshots/charts_screen.png" alt="Charts screen" width="200"/> </p>

### Financial Planning

If the user hasn’t created a financial plan yet, the "Budget" page shows a "Create budget" button to start a new plan. Clicking it takes you to a page where you can select the start and end dates for the forecast along with the initial monthly balance. Once completed, you can fill in the list of planned transactions month by month by swiping left or right. Returning to the main "Budget" page, the button is replaced by a summary page showing the plan’s progress from start to finish, including profit and balance for each month. An edit button allows users to return to the detailed month-by-month view to make changes, including adjusting the budget period.

<p align="center"> <img src="assets/screenshots/create_budget_screen.png" alt="Create budget screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/budget_period_screen.png" alt="Budget period screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/budget_month_screen.png" alt="Budget month screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/budget_screen.png" alt="Budget screen" width="200"/> </p>

### Profile

The "Profile" page displays user information such as first name, last name, and the email used for authentication. If logged in via email and password, these details—and the password—can be changed using dedicated buttons. Users can also log out to return to the login page.

<p align="center"> <img src="assets/screenshots/profile_screen.png" alt="Profile screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/change_password_screen.png" alt="Change password screen" width="200" style="margin-right: 20px"/> <img src="assets/screenshots/account_info_screen.png" alt="Account info screen" width="207"/> </p>

---

## Technologies

The main additional packages used are:

- **firebase_core**, **firebase_auth**, **cloud_firestore**, **google_sign_in**: to utilize Firebase services;
- **fl_charts**: for generating charts;
- **uuid**: for generating unique client-side IDs.

The app uses **Firebase** as its backend for implementing authentication via **Firebase Auth** and data persistence through the **Firestore** database. Two authentication methods are provided: Email/Password and Google Sign In.

The database is composed of a series of collections and documents. Upon registration, a new document is created in the "**users**" collection, named after the UID provided by the authentication service, linking each user to their Firestore data. Each user document includes two fields ("balance" and "email") and initializes two additional collections:

- **transactions:** contains a document for each historical transaction added by the user;
- **budget:** contains various fields that define a financial plan, such as "startDate", "initialBalance", and a "monthlyTransactions" map that lists transactions for each month.

For efficient state management and HTTP calls, several Flutter constructs are used, including:

- **FutureBuilder:** handles asynchronous calls that require waiting for a response, effectively managing states such as loading, errors, and received data.
- **ValueListenable:** listens for state changes in specific values, which is especially useful when data changes don’t require a complete widget rebuild.
- **Streams:** using StreamBuilder, widgets are built that react to data arriving asynchronously in a continuous stream, such as changes in the user's authentication session (login, logout, etc.).

---
