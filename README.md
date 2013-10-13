# iron-router-progress

Implements a simple progress bar, when loading different routes.
Remember to use the `dev` branch of https://github.com/EventedMind/iron-router

## Customization

It's mostly all CSS (LESS), and you can pretty much just override the CSS with whatever you want.

For the most part, you'll want to change the `#iron-router-progress`'s `background-color` and `box-shadow`

If you're changing the transition speeds (for the `.done` class), I'd recommend setting it in your `Router.configure` as well. (Note: This is the full duration of the animation)
```coffee
Router.configure
	progressSpeed : 1.5
```

If there's specific routes, that you don't want to have a progress bar for, you can do
```coffee
Router.map ->
	@route 'home',
		path            : '/'
		disableProgress : true
```
