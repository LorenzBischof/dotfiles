{
  self,
  pkgs,
  lib,
  ...
}:
{
  plugins = {
    lsp = {
      enable = true;
      inlayHints = true;
      keymaps = {
        silent = true;

        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "ca" = "code_action";
          "ff" = "format";
          "K" = "hover";
          "<F2>" = "rename";
        };
      };
      servers = {
        gopls.enable = true;
        nixd = {
          enable = true;
          settings = {
            formatting.command = [ (lib.getExe pkgs.nixfmt-rfc-style) ];
            options =
              let
                flake = ''(builtins.getFlake "${self}")'';
              in
              {
                nixos.expr = "${flake}.nixosConfigurations.laptop.options";
                nixvim.expr = "${flake}.packages.${pkgs.system}.nvim.options";
                home-manager.expr = "${flake}.homeConfigurations.bischoflo.options";
              };
          };
        };
        lua_ls.enable = true;
        terraformls.enable = true;
        regols.enable = true;
        html.enable = true;
        cssls.enable = true;
        jsonls.enable = true;
      };
    };
    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          lsp_format = "fallback";
        };
      };
    };
  };
}
