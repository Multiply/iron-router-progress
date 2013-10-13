Package.describe({
	summary: 'Progressbar for iron-router'
});

Package.on_use(function (api) {
	api.use([
		'coffeescript',
		'less',
		'jquery',
		'underscore',
		'iron-router'
	], 'client');

	api.add_files([
		'progress.coffee',
		'progress.less'
	], 'client');
});
