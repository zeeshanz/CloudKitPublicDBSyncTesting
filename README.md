While syncing with CloudKit's private database is pretty simple, but syncing with its public database can be a nightmare. There is no clear guidance on how to implement CloudKit to iOS realtime sync when using public database.

This code shows how to to do this successfully. Just replace in `Constants.swift` the name of your CloudKit container whose public database you want to sync.
