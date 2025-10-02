author 'Destrah'

fx_version 'cerulean'
games { 'gta5' }

client_script "client.lua"
server_script "server.lua"

shared_scripts {
	'@ox_lib/init.lua',
    'jsFunctions.js',
    'config.lua'
}

ui_page "web/index.html"

files {
    'web/index.html',
    'web/script/script.js',
    'web/styling/style.css',
}

lua54 'yes'