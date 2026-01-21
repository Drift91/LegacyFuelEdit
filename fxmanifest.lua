fx_version 'cerulean'
game 'gta5'

author 'InZidiuZ & Drift_91'
description "Drift_91's personal fork of Legacy Fuel."
version '2.1'

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
use_experimental_fxv2_oal 'yes'
