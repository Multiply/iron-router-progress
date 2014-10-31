notice = """
	%cYou're using a deprecated version of %cIronRouterProgress%c.
	%cPlease run the following commands in your project:%c
	  meteor remove mrt:iron-router-progress
	  meteor add multiply:iron-router-progress
	%cYou can read more about the changes at https://github.com/Multiply/iron-router-progress
"""

Meteor.startup ->
	if Meteor.isClient
		console.log notice,
			"font-size:2em;font-weight:400;color:red",
			"font-size:2em;font-weight:400;color:red;font-weight:600",
			"font-size:2em;font-weight:400;color:red",
			"font-size:1.5em;font-weight:600",
			"font-size:1.5em;font-family:'Lucida Console',Monaco,monospace",
			"font-size:1.5em;font-weight:600"

	else
		console.log notice.replace /%c/g, ''
