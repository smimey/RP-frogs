/*
    zdiscord - by Tony/zfbx - https://github.com/zfbx/zdiscord - License: CC BY-NC-SA 4.0
    Docs for this file available at https://zfbx.github.io/zdiscord/config or in docs/config.md
*/


/** ******************************
 * GENERAL CONFIGURATION SETTINGS
 ********************************/

const LanguageLocaleCode = "en";

// PUBLIC VALUES
const FiveMServerName = "RPFrogs Server";
const DiscordInviteLink = "https://discord.gg/rpfrog";
const FiveMServerIP = "62.171.159.104:40120";

// This spams the console, only enable for testing if needed
const DebugLogs = false;


/** ********************
 * DISCORD BOT SETTINGS
 ***********************/

const EnableDiscordBot = true;

// DISCORD BOT
const DiscordBotToken = "OTYyNTcxMDc4MDQyMDI2MDA0.YlJeLA.VSzCuW8UhtWCC-SIOIKctNP2qQs";
const DiscordGuildId = "868624444661309441";

// STAFF CHAT
const EnableStaffChatForwarding = false;
const DiscordStaffChannelId = "956069154555834409";
const AdditionalStaffChatRoleIds = [
    // "000000000000000",
];

// WHITELISTING / ALLOWLISTING
const EnableWhitelistChecking = true;
const DiscordWhitelistRoleIds = "956067351567159336, 956067314401443891";

// SLASH COMMANDS / DISCORD PERMISSIONS
const EnableDiscordSlashCommands = true;
const DiscordModRoleId = "956067315072507935";
const DiscordAdminRoleId = "956067318620905472";
const DiscordGodRoleId = "956067314401443891";

// DISCORD BOT STATUS
const EnableBotStatusMessages = true;
const BotStatusMessages = [
    "{servername}",
    "{playercount}/48 Players",
    "xQcOW",
];

// ACE PERMISSIONS
const EnableAutoAcePermissions = false;
const AutoAcePermissions = {
    // "example": "000000000000000000",
    // "example2": [ "000000000000000000", "000000000000000000"],
};

// Other
const SaveScreenshotsToServer = false;


/** ************************
 * WEBHOOK LOGGING SETTINGS
**************************/

const EnableLoggingWebhooks = false;
const LoggingWebhookName = "Loggies";
// put "&" in front of the id if you're to ping a role
const LoggingAlertPingId = "&000000000000000000";
// example: "bank": "https://discord.com/webhook/...",
const LoggingWebhooks = {
    "example": "https://canary.discord.com/api/webhooks/965294258431074374/GNn_Rdszv-RRqYt-4QhvYi4Ni3E8BOgeZLumrb8Ohm2ko3hAhRp-lEwKWNKCvvsjYiQn",
};


/** !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 * !! DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING !!
 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

module.exports = {
    EnableDiscordBot: getConBool("discord_enable_bot", EnableDiscordBot),
    EnableStaffChatForwarding: getConBool("discord_enable_staff_chat", EnableStaffChatForwarding),
    EnableLoggingWebhooks: getConBool("discord_enable_logging_webhooks", EnableLoggingWebhooks),
    DebugLogs: getConBool("discord_debug", DebugLogs),
    DiscordBotToken: GetConvar("discord_token", DiscordBotToken),
    DiscordGuildId: GetConvar("discord_guild_id", DiscordGuildId),
    LanguageLocaleCode: GetConvar("discord_lang", LanguageLocaleCode),
    FiveMServerName: GetConvar("discord_server_name", FiveMServerName),
    DiscordInviteLink: GetConvar("discord_invite", DiscordInviteLink),
    FiveMServerIP: GetConvar("discord_server_ip", FiveMServerIP),
    EnableWhitelistChecking: getConBool("discord_enable_whitelist", EnableWhitelistChecking),
    DiscordWhitelistRoleIds: getConList("discord_whitelist_roles", DiscordWhitelistRoleIds),
    EnableDiscordSlashCommands: getConBool("discord_enable_commands", EnableDiscordSlashCommands),
    DiscordModRoleId: GetConvar("discord_mod_role", DiscordModRoleId),
    DiscordAdminRoleId: GetConvar("discord_admin_role", DiscordAdminRoleId),
    DiscordGodRoleId: GetConvar("discord_god_role", DiscordGodRoleId),
    EnableBotStatusMessages: getConBool("discord_enable_status", EnableBotStatusMessages),
    BotStatusMessages: BotStatusMessages,
    EnableAutoAcePermissions: getConBool("discord_enable_ace_perms", EnableAutoAcePermissions),
    AutoAcePermissions: AutoAcePermissions,
    SaveScreenshotsToServer: getConBool("discord_save_screenshots", SaveScreenshotsToServer),
    DiscordStaffChannelId: GetConvar("discord_staff_channel_id", DiscordStaffChannelId),
    LoggingWebhooks: LoggingWebhooks,
    LoggingAlertPingId: GetConvar("discord_logging_ping_id", LoggingAlertPingId),
    LoggingWebhookName: GetConvar("discord_logging_name", LoggingWebhookName),
    StaffChatRoleIds: [
        GetConvar("discord_mod_role", DiscordModRoleId),
        GetConvar("discord_admin_role", DiscordAdminRoleId),
        GetConvar("discord_god_role", DiscordGodRoleId),
        ...AdditionalStaffChatRoleIds,
    ],
};

/** Returns convar or default value fixed to a true/false boolean
 * @param {boolean|string|number} con - Convar name
 * @param {boolean|string|number} def - Default fallback value
 * @returns {boolean} - parsed bool */
function getConBool(con, def) {
    if (typeof def == "boolean") def = def.toString();
    const ret = GetConvar(con, def);
    if (typeof ret == "boolean") return ret;
    if (typeof ret == "string") return ["true", "on", "yes", "y", "1"].includes(ret.toLocaleLowerCase().trim());
    if (typeof ret == "number") return ret > 0;
    return false;
}

/** returns array of items or default array provided
 * @param {string} con - string of comma separated values
 * @param {string|Array} def - string of comma separated values
 * @returns {object} - array of discord ids */
function getConList(con, def) {
    const ret = GetConvar(con, def);
    if (typeof ret == "string") return ret.replace(/[^0-9,]/g, "").replace(/(,$)/g, "").split(",");
    if (Array.isArray(ret)) return ret;
    if (!ret) return [];
}
