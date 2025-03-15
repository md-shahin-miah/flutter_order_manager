## Flutter Order Manager

A comprehensive order management application built with Flutter, following clean architecture principles and modern Flutter development practices.
 
#Overview

Flutter Order Manager is a mobile application designed for restaurants and food delivery services to manage their orders efficiently. The app allows tracking orders through different stages (Incoming, Ongoing, Ready, Rejected), managing customer information, and handling order details.

#Features

    Order Status Management: Track orders through their lifecycle (Incoming → Ongoing → Ready)
    Order status maintain: All status is updatable (Using SQLite)
        1.Saving time to local db when creating oreder - Created time (Current date time), Pickup time (30 minutes from created time),Delivery time (30 minutes from Pickup time)
        2.Order status ongoing to ready, changing with time and saving to SQLite
    Real-time Order Timer: Visual countdown showing how long orders have been in the system
    Order Details: View comprehensive order information including items, prices, and customer notes
    Customer Management: Store and access customer contact information
    Create order: Processing a 5 minutes interval task to create random orders.
    Sound Notifications: Audio alerts for new orders using native platform integration
    Overlay blink: A view with sound on the bottom will blink until user click it (Sound and view will close when user clicked)
    Order Rejection: Ability to reject orders with appropriate status tracking using SQLite


#Might have color issues due to usage of color picker extension

#Architecture

The project follows Clean Architecture principles with the following layers:

    Domain: Contains business logic, entities, and use cases
    Data: Implements repositories and data sources
    Presentation: UI components, screens, and state management

#Technologies Used

    Flutter: UI framework (3.27.3)
    Riverpod: State management
    SQLite: Local database for order storage(All CRUD operations maintained )
    GetIt: Dependency injection
    Go Router: Navigation management
    Method Channels: Native platform integration for sound
    Isolates: Background processing for order creation timer 
    Google Fonts: Typography with Inter font family
