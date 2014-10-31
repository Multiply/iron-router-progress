Package.describe({
	name    : 'mrt:iron-router-progress',
	version : '0.9.3',
	summary : 'Progressbar for iron:router',
	git     : 'https://github.com/Multiply/iron-router-progress.git'
});

Package.onUse(function (api) {
	api.versionsFrom('METEOR@1.0');

	api.use('coffeescript');
	api.addFiles('notice.coffee');
});
