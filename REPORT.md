# MP Report

## Team

- Name(s): Your Name(s)
- AID(s): A12345678

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [X] The app builds without error
- [X] I tested the app in at least one of the following platforms (check all that apply):
  - [ ] iOS simulator / MacOS
  - [X] Android emulator
- [X] There are at least 3 separate screens/pages in the app
- [X] There is at least one stateful widget in the app, backed by a custom model class using a form of state management
- [X] Some user-updateable data is persisted across application launches
- [X] Some application data is accessed from an external source and displayed in the app
- [X] There are at least 5 distinct unit tests, 5 widget tests, and 1 integration test group included in the project

## Questionnaire

Answer the following questions, briefly, so that we can better evaluate your work on this machine problem.

1. What does your app do?

   I developed a News Reader app that allows users to browse and search for news articles. The app features three main screens: a home screen displaying the latest news headlines, a detailed article view for reading full articles, and a bookmarks screen where users can access their saved articles. Users can search for specific news topics and bookmark articles they want to read later.

2. What external data source(s) did you use? What form do they take (e.g., RESTful API, cloud-based database, etc.)?

   I used a RESTful API for fetching news data through my NewsService class. I used the News API (newsapi.org) RESTful API service for fetching news data. This API provides endpoints for both top headlines and article searches, returning JSON data that I parse into Article objects in my app.

3. What additional third-party packages or libraries did you use, if any? Why?

   I used several key packages:
provider for state management, which helps manage the app's data flow and UI updates
http for making API requests to the news service
shared_preferences for local data persistence of bookmarked articles
flutter_test and integration_test for testing capabilities

4. What form of local data persistence did you use?

   I used SharedPreferences for local data persistence. This is used specifically to store and retrieve bookmarked articles across app launches. The articles are serialized to JSON before storage and deserialized when loading. This implementation can be seen in the NewsProvider class where _saveBookmarkedArticles() and _loadBookmarkedArticles() methods handle the persistence logic.

5. What workflow is tested by your integration test?

  My integration test (app_test.dart) tests the core user workflow of the app:

App launch and initial home screen loading
Verification of the search field presence
Navigation to the bookmarks screen
Verification of the empty bookmarks state
Navigation back to home screen
Testing the search functionality by entering a search term
Waiting for and verifying search results
This test ensures that the main user interactions and navigation flows work correctly in an integrated environment.

## Summary and Reflection

When developing this news reader app, there are several architectural choices that I made. For state management, I decided to go with the Provider package since it provides a clear separation of widgets and enables the rebuilding of widgets. To manage API interactions, I created a custom NewsService class to make all network calls with the code being easily mockable for tests. To retain data I employed SharedPreferences for bookmarked articles that I serialized into JSON format for storage. When implemented, I made one of the most critical decisions of the project and placed the bookmark toggle exactly on the article cards so that the user does not have to go to another page to perform the bookmark function, I used a semi-transparent circular button placed on the article image. 

I also liked the use of tests as a driving force that allows for detecting problems as soon as possible and creating solid envelopes. The hardest thing, which was faced during the development of widget tests, was the problem of asynchronous operations. It was rather enjoyable to create the bookmarking feature with the ability to store data, as it made a difference for the users.

