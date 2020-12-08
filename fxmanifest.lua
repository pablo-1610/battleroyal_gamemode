resource_type 'gametype' { name = '🔥 • Pablo Battle Royal' }

ui_page "html/index.html"


files {
    "html/index.html",
    "html/*.css",
	"html/scripts/listener.js",
	"html/scripts/SoundPlayer.js",
    "html/scripts/functions.js",
    "html/diplayLogo.js",
    "html/toastr.min.js",
    "html/img/*.png",
}

server_scripts {
    "server/*.lua"
}

client_scripts {
    "html/*.lua",
    "client/*.lua",
    

    "client/rage/RMenu.lua",
    "client/rage/menu/RageUI.lua",
    "client/rage/menu/Menu.lua",
    "client/rage/menu/MenuController.lua",
    "client/rage/components/*.lua",
    "client/rage/menu/elements/*.lua",
    "client/rage/menu/items/*.lua",
    "client/rage/menu/panels/*.lua",
    "client/rage/menu/windows/*.lua"
}

fx_version 'adamant'
games { 'gta5' };