--[[
-- Simple MySQL proxy script to handle re-routing inbound connections to
 - Pantheon. Use environment variables for control:

   - PROXY_DB_UN: The MySQL username to use when connecting to this proxy.
   - PROXY_DB_PW: The MySQL password to use when connecting to this proxy.
   - PANTHEON_DB_UN: The username to use when connecting to Pantheon's DB.
   - PANTHEON_DB_PW: The password to use when connecting to Pantheon's DB.
--]]

local password = assert(require("mysql.password"))
local proto = assert(require("mysql.proto"))

---
-- map usernames to another login
--
local map_auth = {
    [os.getenv("PROXY_DB_UN")] = {
        password = os.getenv("PROXY_DB_PW"),
        new_user = os.getenv("PANTHEON_DB_UN"),
        new_password = os.getenv("PANTHEON_DB_PW"),
        new_db = "pantheon"
    }
}

---
-- rewrite credentials to those provided above
--
function read_auth()
    local c = proxy.connection.client
    local s = proxy.connection.server
    local CLIENT_PROTOCOL_41       = 512    -- New 4.1 protocol
    local CLIENT_SECURE_CONNECTION = 32768  -- New 4.1 authentication
    local MYSQL_AUTH_CAPABILITIES  = ( CLIENT_PROTOCOL_41 + CLIENT_SECURE_CONNECTION )

    -- if we know this user, replace its credentials
    local mapped = map_auth[c.username]

    if mapped and
            password.check(
                s.scramble_buffer,
                c.scrambled_password,
                password.hash(password.hash(mapped.password))
            ) then

        proxy.queries:append(1,
            proto.to_response_packet({
                username = mapped.new_user,
                response = password.scramble(s.scramble_buffer, password.hash(mapped.new_password)),
                charset  = 8, -- default charset
                database = mapped.new_db,
                max_packet_size = 1 * 1024 * 1024,
                server_capabilities = MYSQL_AUTH_CAPABILITIES
            })
        )

        return proxy.PROXY_SEND_QUERY
    end
end
