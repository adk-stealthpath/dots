return {
    dir = "~/stealthpath/conduit.nvim",
    name = "conduit",
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("conduit").setup({
            datasources = {
                postgres = {
                    pod_selector = { name = "postgresql-1", namespace = "postgresql" },
                    secret       = {
                        name      = "postgres-broker-pass",
                        namespace = "postgresql",
                        user_key  = "username",
                        pass_key  = "password",
                    },
                    exec         = "psql postgresql://{{username}}:{{password}}@localhost:5432/network",
                    filetype     = "sql",
                },
                memgraph = {
                    pod_selector = { name = "memgraph-0", namespace = "memgraph" },
                    secret       = function(context)
                        if context == "local" then
                            return { name = "user-credentials", namespace = "memgraph", user_key = "user", pass_key =
                            "pass" }
                        end
                        return { name = "user-credentials", namespace = "memgraph", user_key = "username", pass_key =
                        "password" }
                    end,
                    exec         = "echo '{{query}}' | mgconsole -username {{username}} -password {{password}} -verbose_execution_info",
                    filetype     = "cypher",
                    shell_exec   = true,
                    formatter    = "cypher",
                },
                redis = {
                    pod_selector = { name = "redis-standalone-0", namespace = "redis" },
                    secret = {
                        name = "redis-credentials",
                        namespace = "redis",
                        pass_key = "pass",
                    },
                    exec = "redis-cli -a {{password}}",
                    filetype = "txt",
                }
            },
        })
    end,
}
