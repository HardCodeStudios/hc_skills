fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
author '<HardCode/> Studios @AxeelWZ'
lua54 'yes'

server_scripts {
    'server/*.lua'
}

shared_script {
    'shared/*.lua'
}

client_script {
    '@vorp_core/client/dataview.lua',
    'client/*.lua'
}

ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.css',
    'html/*.js',
    'html/fonts/milonga.ttf',
    'html/img/*.png',
    'html/sound/*.mp3'
}

escrow_ignore {}

-- dependency 'ds_libs'