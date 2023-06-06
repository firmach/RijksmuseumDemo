# RijksmuseumDemo

This is an iOS demo app that leverages the Rijksmuseum API. The application comprises two main screens:

- **Items List Screen:** This screen supports both grid and table view layouts, employing the latest UICollectionView APIs. As the user scrolls, items are requested and loaded page by page. The app displays a loading indicator during this process, and notifies the user of any potential errors.
- **Item Details Screen:** This screen fetches and showcases detailed information about the selected item, along with some additional data.

The user interface is built entirely from code, and it utilizes modern concurrency techniques, such as actors and async/await.
