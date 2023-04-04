fx_version 'cerulean'
game 'gta5'

author 'InZidiuZ & Drift_91'
description 'Legacy Fuel Edit'
version '2.0'

-- What to run
client_scripts {
	'config.lua',
	'functions/functions_client.lua',
	'source/fuel_client.lua'
}

server_scripts {
	'config.lua',
	'source/fuel_server.lua'
}

exports {
	'GetFuel',
	'SetFuel'
}

provide 'LegacyFuel'
lua54 'yes'
