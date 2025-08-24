local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local notify = require("notify")

local conf = "/opt/k8s-kubeconfig/.kube/k0s/merged.yaml"

local contexts = function()
    cmd = 'kubectl --kubeconfig '..conf..' config view -o go-template=\'{{range $key, $value := .clusters}}{{printf "%s\\n" $value.name}}{{end}}\' | grep -v "schwartz"'
    local handle = io.popen(cmd)
    local res = {}
    if handle ~= nil then
        for l in handle:lines() do 
            table.insert(res, l)
        end
        handle:close()
    end
    return res
end

local get_secret = function(context)
    local handle = io.popen(string.format('kubectl --kubeconfig '..conf..' --context %s get secret -n postgres postgres-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d -', context))
    local res = ""
    if handle ~= nil then
        res = handle:read("*a")
        handle:close()
    end
    return res
end

local kill_pf = function()
    local handle = io.popen("lsof -i tcp:5432 | grep kubectl | awk '{print $2}' | uniq")
    if handle ~= nil then
        for l in handle:lines() do io.popen(string.format("kill %s", l)) end
        handle:close()
    end
end

local check_node = function(context)
    local cmd = string.format("kubectl --kubeconfig "..conf.." --context %s get po -n postgres postgres-postgresql-0 -o json | jq -r '.status.phase'", context)
    print(cmd)
    local handle = io.popen(cmd)
    local res = ""
    if handle ~= nil then
        res = handle:read("*a")
        handle:close()
    end
    if not string.find(res, "Running") then
        return "error: database not running"
    end
    return ""
end


local postyes = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "PostgreSQL Picker",
        finder = finders.new_table {
            results = contexts()
        },
        -- sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                kill_pf()

                local context = action_state.get_selected_entry()

                local resp = check_node(context[1])
                print(resp)
                if resp ~= "" then
                    notify("Could not connect to node", "error")
                    return
                end

                local job = vim.fn.jobstart(
                    string.format("kubectl ---kubeconfig "..conf.." -context %s port-forward -n postgres postgres-postgresql-0 5432", context[1])
                )
                local pass = get_secret(context[1])
                vim.g.dbs = {{name = "network", url = string.format("postgresql://postgres:%s@localhost:5432/network", pass)}}

                vim.cmd("tabnew")
                vim.cmd("DBUI")
            end)
            return true
        end,
    }):find()
end

notify.setup({})

local run = function()
    postyes(require("telescope.themes").get_dropdown{})
end 

vim.keymap.set("n", "<leader>sql", run)
