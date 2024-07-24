fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'DC Customz'
description 'DC Customz Props Attachment Tool'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/index.js'
}

shared_scripts {
	"@ox_lib/init.lua",
    'cfg.lua'
}

client_scripts {
	'client.lua'
}

escrow_ignore {
	'cfg.lua'
}

dependency 'ox_lib'
