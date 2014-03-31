# iron-router-progress

Implements a simple progress bar, when loading different routes.
Example running at: https://iron-router-progress.meteor.com/

## Installation

Use [Atmosphere](https://atmospherejs.com/) to install the latest version of iron-router-progress.
```sh
$ mrt add iron-router-progress
```

## Customization

It's mostly all CSS (LESS), and you can pretty much just override the CSS with whatever you want.

For the most part, you'll want to change the `#iron-router-progress`'s `background-color` and `box-shadow` like this:
```css
#iron-router-progress {
	background-color : <COLOR>;
	box-shadow       : 0 0 5px <COLOR>;
}
```

### Automatic ticks
By default, the progress bar will tick every 0.75-1.5 seconds, after you start loading a route.

If you want to disable this behaviour you can do it either globally by:
```coffee
IronRouterProgress.configure
	tick : false
```
Or by route definition:
```coffee
Router.map ->
	@route 'home',
		path     : '/'
		progress :
			tick : false
```

### Spinner
By default, a spinner is running, on the far right of the page, when loading.

You'll most likely want to just change the border-color like this:
```css
#iron-router-progress.spinner:before {
	border-color : <COLOR>;
}
```

If you don't like the spinner, simply disable it with:
```coffee
IronRouterProgress.configure
	spinner : false
```
Or by route definition:
```coffee
Router.map ->
	@route 'home',
		path     : '/'
		progress :
			spinner : false
```

### Enable the progress bar, only for certain routes
If you don't want to use the progress bar for all routes, you can disable it globally, and enable it on the route level:
```coffee
IronRouterProgress.configure
	enabled : false

Router.map ->
	@route 'home',
		path     : '/'
		progress :
			enabled : true
```

Or if you just want it disabled for certain routes:
```coffee
Router.map ->
	@route 'home',
		path     : '/'
		progress :
			enabled : false
```
