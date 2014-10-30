Package.describe({
	version : '0.9.3',
	summary : 'Progressbar for iron:router',
	git     : 'https://github.com/Multiply/iron-router-progress.git'
});

Package.onUse(function (api) {
	api.use([
		'coffeescript@1.0.0',
		'less@1.0.0',
		'jquery@1.0.0',
		'underscore@1.0.0',
		'iron:router@1.0.0'
	], 'client');

	api.imply('iron:router');

	api.addFiles([
		'progress.coffee',
		'progress.less'
	], 'client');
	
	api.export('IronRouterProgress', 'client');
});
