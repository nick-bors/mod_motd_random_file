-- Prosody IM
-- Copyright (C) 2026-2026 Nicholas Bors-Sterian
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- Copyright (C) 2010 Jeff Mitchell
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local st = require "util.stanza";
local lfs = require "lfs";

local motd_jid = "";
local motd_dir = "";
local motd_messages = {};

local function dir_exists()
	if (lfs.attributes(motd_dir, "mode") == "directory") then
		return true;
	end
	return false;
end

local function load_motd(path)
	local motd_file, err = io.open(path);
	if not motd_file then
		module:log("warn", "Unable to load MOTD file '%s': %s", path, tostring(err));
		return;
	end

	local motd = motd_file:read("*a");
	motd_file:close();
	table.insert(motd_messages, motd);
end

local function load_motds()
	if not dir_exists() then
		module:log("error", "Unable to load MOTD directory '" .. motd_dir .. "'")
		return;
	end

	for file in lfs.dir(motd_dir) do
		if file ~= "." and file ~= ".." then
			load_motd(motd_dir .. "/" .. file)
		end
	end
end

local function reload_config()
	motd_messages = {}
	motd_dir = module:get_option_string(
	    "motd_random_file_dir",
	    module:get_directory().."/motd"
	);
	motd_jid = module:get_option("motd_jid") or module:get_host();
	load_motds()
end

reload_config()

module:hook("resource-bind", function (event)
    local session = event.session;

    local motd_stanza;

    if #motd_messages == 0 then
        module:log("warn", "No MOTD messages found in '" .. motd_dir .. "'");
        return;
    end

    motd_stanza = st.message({
        to = session.username..'@'..session.host,
        from = motd_jid
    }, motd_messages[math.random(1, #motd_messages)]);

    module:send(motd_stanza);
    module:log("debug", "MOTD sent to user %s@%s", session.username, session.host);
end);

module:hook_global("config-reloaded", reload_config);
