# iron-router-progress

Implements a simple progress bar, when loading different routes.
Remember to use the `dev` branch of https://github.com/EventedMind/iron-router

Due to `dev` not having a tag (`0.6.0`) yet, and me not knowing if I can reference the package at branch, over a tag, I decided to remove the dependency, so you have to install `iron-router` manually.

## Customization

It's mostly all CSS (LESS), and you can pretty much just override the CSS with whatever you want.

For the most part, you'll want to change the `#iron-router-progress`'s `background-color` and `box-shadow`

If there's specific routes, that you don't want to have a progress bar for, you can do
```coffee
Router.map ->
	@route 'home',
		path            : '/'
		disableProgress : true
```
