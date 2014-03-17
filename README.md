# iron-router-progress

Implements a simple progress bar, when loading different routes.
Example running at: https://iron-router-progress.meteor.com/

## Installation

Using [Meteorite](https://github.com/oortcloud/meteorite) to install the latest version from [Atmosphere](https://atmosphere.meteor.com/):
```sh
$ mrt install iron-router-progress
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

### Disable progress for specific routes
If there's specific routes, that you don't want to have a progress bar for at all, you can do:
```coffee
Router.map ->
	@route 'home',
		path     : '/'
		progress :
			spinner : false
```
You can't disable progress globally, and enable it per route currently, but I'd be happy to implement it, if you guys need it.
