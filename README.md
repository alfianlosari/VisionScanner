# VisionScanner

## Description
* iOS App where user can scan an image and get powerful image analysis such as Labels, Faces, OCR.
User can store and share the results via pdf to another people.
Powered by Google Cloud Vision API

## User Experience
* The App consists of Home Screen where user can see all the vision result that they have taken in descending order based on date taken and a Detail screen where they can see and share their image analysis results.
* User can scan new image by tapping the scan button and select the source image from Camera or Photo Library
* After selecting the image, the app will analyze the image by using Google Cloud Vision API
* The results will be categorized in 3 categories:
 1.  Labels which provide contextual sets of categories.
 2. Faces which detect multiple faces within an image, along with the associated key facial attributes like emotional state or wearing headwear.
 3. OCR which detect and extract text within an image, with support for a broad range of languages, along with support for automatic language identification.
* The results will be persisted in Core Data
* User can share their image result analysis by generating PDF and using activity view controller to select action they want to take with the generated PDF.
* User can delete the image results within the home screen by swiping to delete or detail screen by selecting the trash button.

## Installation
* Clone the project and build using Xcode 8.3