-- Prosody IM
-- Copyright (C) 2026-2026 Nicholas Bors-Sterian
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- Copyright (C) 2010 Jeff Mitchell
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local core_route_stanza = prosody.core_route_stanza;
local host = module:get_host();
local motd_jid = module:get_option("motd_jid") or host;

local motd_dir = module:get_option_string(
    "motd_random_file_dir",
    module:get_directory().."/motd"
);

local motd_messagesets = {};

local lfs = require "lfs";

local function load_motd(path)
	local motd_file, err = io.open(path);
	if not motd_file then
		module:log("warn", "Unable to load MOTD file '%s': %s", path, tostring(err));
		return;
	end

	local motd = motd_file:read("*a");
	motd_file:close();
	table.insert(motd_messagesets, motd);
end

for file in lfs.dir(motd_dir) do
	if file ~= "." and file ~= ".." then
		load_motd(motd_dir .. "/" .. file)
	end
end

local st = require "util.stanza";


module:hook("resource-bind", function (event)
    local session = event.session;

    local motd_stanza;

    if #motd_messagesets == 0 then
        module:log("warn", "No MOTD messages found in '" .. motd_dir .. "'");
        return;
    end

    motd_stanza = st.message({
        to = session.username..'@'..session.host,
        from = motd_jid
    }, motd_messagesets[math.random(1, #motd_messagesets)]);

    core_route_stanza(hosts[host], motd_stanza);
    module:log("debug", "MOTD sent to user %s@%s", session.username, session.host);
end);
