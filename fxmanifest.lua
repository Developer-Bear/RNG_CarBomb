fx_version 'adamant'

game 'gta5'

description 'useable item that detonates after being attached to a vehicle'

version '1.1.0'

client_scripts {
    '@es_extended/locale.lua',
    'carbomb-client.lua',
    'locales/en.lua',
    'locales/it.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'carbomb-server.lua',
    'locales/en.lua',
    'locales/it.lua'
}

shared_script 'carbomb-config.lua'