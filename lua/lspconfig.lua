local configs = require 'lspconfig/configs'
local lspinfo = require 'lspconfig/lspinfo'

local M = {
  util = require 'lspconfig/util';
}

M._root = {}

function M.available_servers()
  return vim.tbl_keys(configs)
end

-- Called from plugin/lspconfig.vim because it requires knowing that the last
-- script in scriptnames to be executed is lspconfig.
function M._root._setup()
  M._root.commands = {
    LspInfo = {
      function()
        lspinfo()
      end;
      "-nargs=0";
      description = '`:LspInfo` Displays attached, active, and configured language servers';
    };
    LspStart = {
      function(server_name)
        require('lspconfig')[server_name].autostart()
      end;
      "-nargs=1 -complete=custom,v:lua.lsp_complete_configured_servers";
      description = '`:LspStart` Manually launches a language server.';
    };
    LspStop = {
      function(client_id)
        if not client_id then
          vim.lsp.stop_client(vim.lsp.get_active_clients())
        else
          local client = vim.lsp.get_client_by_id(tonumber(client_id))
          if client then
            client.stop()
          end
        end
      end;
      "-nargs=? -complete=customlist,v:lua.lsp_get_active_client_ids";
      description = '`:LspStop` Manually stops the given language client.';
    };
    LspRestart = {
      function(client_id)
        if client_id then
          local client = vim.lsp.get_client_by_id(tonumber(client_id))
          if client then
            local client_name = client.name
            client.stop()
            vim.defer_fn(function()
              require('lspconfig')[client_name].autostart()
            end, 500)
          end
        end
      end;
      "-nargs=? -complete=customlist,v:lua.lsp_get_active_client_ids";
      description = '`:LspRestart` Manually restart the given language client.';
    };
  };

  M.util.create_module_commands("_root", M._root.commands)
end

local mt = {}
function mt:__index(k)
  if configs[k] == nil then
    pcall(require, 'lspconfig/'..k)
  end
  return configs[k]
end

return setmetatable(M, mt)
-- vim:et ts=2 sw=2
