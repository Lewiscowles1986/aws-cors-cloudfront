# Using Cloudfront to avoid CORS while maintaining separate deploys

This repo demonstrates avoiding CORS by mapping separate origins (don't have to be websites, but I've used example.com and https://jsonplaceholder.typicode.com/) to allow you to bypass CORS

This is intended for devs with de-coupled frontend and backend, which they own, to talk to one another.

It is NOT intended to help you bypass CORS for no good reason, or for bad-actor stuff.
