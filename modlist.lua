Hooks:Add("LocalizationManagerPostInit", "ModlistResizer_loc", function(...)
	LocalizationManager:add_localized_strings({
		menu_ModlistResizer = "Mods List Resizer",
		modlist_resizer = "Mods List size",
	})
		
	if Idstring("russian"):key() == SystemInfo:language():key() then
		LocalizationManager:add_localized_strings({
			modlist_resizer = "Размер списка модификаций",
		})
	end
end)

_G.ModlistResizer = _G.ModlistResizer or {}
ModlistResizer._setting_path = SavePath .. "ModlistResizer.json"
ModlistResizer.settings = ModlistResizer.settings or {}
function ModlistResizer:Save()
	local file = io.open(self._setting_path, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function ModlistResizer:Load()
	local file = io.open(self._setting_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			self.settings[k] = v
		end
		file:close()
	else
		self.settings = {}
		self:Save()
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_ModlistResizer", function(...)
	ModlistResizer:Load()
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_ModlistResizer", function(menu_manager, nodes)
	function MenuCallbackHandler:set_modlist_size_callback(item)
		ModlistResizer.settings.size = tonumber(item:value())
		ModlistResizer:Save()
	end
	
	local menu_id = "modlist_resizer_options"
	MenuHelper:NewMenu(menu_id)
	
	MenuHelper:AddSlider({
		id = "modlist_resizer",
		title = "modlist_resizer",
		callback = "set_modlist_size_callback",
		value = ModlistResizer.settings.size or 1,
		max = 2,
		min = 0.35,
		step = 0.1,
		show_value = true,
		menu_id = menu_id
	})

	nodes[menu_id] = MenuHelper:BuildMenu(menu_id)

	MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "menu_ModlistResizer")
end)

local data = InspectPlayerInitiator.modify_node
function InspectPlayerInitiator:modify_node(node, inspect_peer)
	local menu = data(self, node, inspect_peer)

	if ModlistResizer.settings.size and ModlistResizer.settings.size ~= 1 then
		for id, btn in pairs(node._items) do
			if not btn.no_select and not btn._parameters.back and btn._parameters.text_id ~= "menu_visit_fbi_files" then
				btn._parameters.font_size = tweak_data.menu.pd2_medium_font_size * ModlistResizer.settings.size
				if btn._parameters.font_size and btn._parameters.font_size > tweak_data.menu.pd2_medium_font_size then
					btn._parameters.font = "fonts/font_large_mf"
				end
			end
		end
	end
	
	return menu
end
