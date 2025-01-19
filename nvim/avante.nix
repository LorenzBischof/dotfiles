{ lib, ... }:
{
  plugins.avante = {
    enable = lib.mkDefault true;
    settings = {
      claude = {
        api_key_name = "cmd:cat /run/agenix/anthropic-api-key";
      };
    };
  };
}
