{ config, lib, ... }:

with config.lib.stylix.colors.withHashtag;

let
  text = base05;
  urgent = base08;
  focused = base0D;
  unfocused = base01;

  fonts = {
    names = [ config.stylix.fonts.sansSerif.name ];
    size = config.stylix.fonts.sizes.desktop + 0.0;
  };

in
{
  options.theme.sway.enable = lib.mkEnableOption "Sway";

  config = lib.mkMerge [
    (lib.mkIf config.theme.sway.enable {
      wayland.windowManager.sway.config = {
        inherit fonts;

        colors =
          let
            background = base0D;
            indicator = base0B;
          in
          {
            inherit background;
            urgent = {
              inherit background indicator text;
              border = urgent;
              childBorder = urgent;
            };
            focused = {
              inherit background text;
              indicator = base0E;
              border = focused;
              childBorder = focused;
            };
            focusedInactive = {
              inherit text;
              # Background is titlebar color (when tabbed)
              background = base03;
              indicator = unfocused;
              border = unfocused;
              childBorder = unfocused;
            };
            unfocused = {
              inherit text;
              # Background is titlebar color (when tabbed)
              background = unfocused;
              indicator = unfocused;
              border = unfocused;
              childBorder = unfocused;
            };
            placeholder = {
              inherit background indicator text;
              border = unfocused;
              childBorder = unfocused;
            };
          };

        output."*".bg = "${config.stylix.image} fill";

        seat."*" = {
          xcursor_theme = "${config.stylix.cursor.name} ${toString config.stylix.cursor.size}";
        };
      };
    })

    {
      # Merge this with your bar configuration using //config.lib.stylix.sway.bar
      lib.theme.sway.bar = {
        inherit fonts;

        colors =
          let
            background = base00;
            text = base00;
          in
          {
            inherit background;
            statusline = base04;
            separator = base01;
            focusedWorkspace = {
              inherit text;
              border = focused;
              background = focused;
            };
            activeWorkspace = {
              inherit text;
              border = base03;
              background = base03;
            };
            inactiveWorkspace = {
              text = base05;
              border = base01;
              background = base01;
            };
            urgentWorkspace = {
              inherit text;
              border = urgent;
              background = urgent;
            };
            bindingMode = {
              inherit text;
              border = urgent;
              background = urgent;
            };
          };
      };
    }
  ];
}
