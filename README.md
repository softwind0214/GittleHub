# Project Info

| Section | Description |
|---|---|
| Name | GittleHub |
| Brief | A little github app, allowing login and explore infos. |
| Functions | Login/out, feeds, search, friends, personal infos. |
| License | MIT |
| Terminal | iPhone / iPad / Mac |

# Requirements

<p>Basicly, this is a light-weight frontend of github service.</p>
<p>It allows users to log in to their accounts and explore news and information.</p>

## BRD

For base business, app should have following pages:
1. Home
2. Search
3. Profile
4. Projects
5. Friends

For users, app should hold their accounts, including:
1. Login
2. Logout
3. Interaction with others

For the UI design, the app should adhere to human - interface guidelines, providing simple, intuitive, and efficient user flows:
1. Login with biometry
2. Common error tips and retry
3. Explore without login

## PRD

Firstly, we defined each pages as following:
| Page | Feature | Login Required | Guest Mode |
|---|---|---|---|
| Home | Feeds for user | NO | App slogun and BIG "login with github" |
| Search | Search in github | NO | Same |
| Friends | View friends list and their homepage | YES | App slogun and BIG "login with github" |
| Projects | View user's projects list | YES | App slogun and BIG "login with github" |
| Me | User's profile and settings | NO | Settings, and login button |

Secondary, we defined basic flows for user accounts:
| Feature | Detail |
| --- | --- |
| Login UI | Single login page with a popup UI, with Face ID if supports |
| Online Functions | View feeds, projects, friends, profile, follow/unfollow others |
| Offline Functions | Search on github, other local settings. |

In addition, there are some other non - business features:
| Feature | Detail |
| --- | --- |
| Darkmode | App can switch and perform differently |
| Multi-Language | zh-Hans / en-US / ... |
| Screen compatibility | Autolayout in both portrait and laudscape |

## UI Design

* Uniformly styled icons and backgrounds
* Common accent color
* Well-designed list layouts for both portait and landscape orientation
* Well-designed colors and images in both light/dark mode

# R & D & QA

## Technology Stack

| Section | Description |
|---|---|
| Coding Language | Swift 6 |
| Project Hosting | Swift Project Manager |
| UI Framework | SwiftUI |
| API | Github RESTful API |
| Persistence | UserDefaults |
| Security | AES / Keychain / FaceID |

## Architecture

### Compoment Layer

* App
    - GittleHubApp.swift    ->  App entry
    - ContentView.swift     ->  Main UI framework
* Biz
    - Context.swift         ->  Shared context values
    - Feed
        - Feed.swift        ->  Biz namespace
        - Feed.Model.swift  ->  Models 
        - Feed.UI.swift     ->  Views
        - Feed.VM.swift     ->  ViewModels
    - Login
    - Me
    - Projects
    - Search
* SDKs
    - Log
    - Network
    - Persistence
    - Security
    - UI

### Biz flow

* Use the MVVM design pattern to adopt the coding-style of SwiftUI
* View and model are two-way binded
* Data flow: user to view to vm, then vm perform biz logic and modifies models, and triggle published values to modify view back.

### Key Tech Points

* Login With Github
    - Apply for a GitHub app
    - Integrate the complete process of `Authenticating with the GitHub App on behalf of a user`
    - Use hybrid view container to perform authenticating and intercept callback url as if it's an server
    - Get the user's bearer token for following requests

* View Timeline
    - Request the API of user received events
    - There are too many types of events, we need to display them case by case

* Light/Dark Mode
    - Automatically follow the mode of system
    - Define dark mode variants for every color used in app
    - Define dark mode variants for images and icons
    - Check each page and adopt the colors for both modes

* Localization
    - Use the latest localization solution (xcstrings)
    - Define zh-Hans as the basic language
    - Use LocalizedKey in all views, and configure Chinese and English translations for all keys

* Persistence
    - Use `app gourp` to cache data

* Network Request
    - Create netowrk request interface based on Alamofire
    - Protocol oriented designing
    - Adopt a SwiftUI-inspired declarative chaining syntax
    - Multi-layer API designing: more configurable / less convenience layer and less configurable / more convenience layer
    - Adopt async programming style

## Test

Both function unit test and UI test are supported, and run correctly.

# Collaborate

## Get Started

* Fork the repo
* `git clone`
* Open the project with Xcode, and wait for SPM downloading all dependancies
* Adjust the signing configs for yourself
* Run and debug

## Add a Feature

* If you are adding a new biz feature, it's strongly recommended to create a new folder in `Biz` folder, and create your own views, vms, models.
* If you are modifying base SDKs, it's strongly recommended to create test cases and ensure all of them run correctly.