{ config, pkgs, lib, ... }:

{
  #  services.gammastep = {
  #    enable = true;
  #    latitude = 46.9;
  #    longitude = 7.4;
  #  };
  #  services.swayidle = {
  #    enable = true;
  #    events = [
  #      {
  #        event = "before-sleep";
  #        command = "${pkgs.swaylock}/bin/swaylock -f";
  #      }
  #    ];
  #    timeouts = [
  #      {
  #        timeout = 300;
  #        command = "${pkgs.brillo}/bin/brillo -O && ${pkgs.brillo}/bin/brillo -equ 200000 -S 1";
  #        resumeCommand = "${pkgs.brillo}/bin/brillo -I -equ 200000";
  #      }
  #      {
  #        timeout = 310;
  #        command = "${pkgs.swaylock}/bin/swaylock -f";
  #      }
  #      {
  #        timeout = 320;
  #        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
  #        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
  #      }
  #    ];
  #  };

  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      startup = [
        #{ command = "autotiling-rs"; always = true; }
      ];
      window = {
        border = 5;
        titlebar = false;
      };
      bars = [
        {
          statusCommand = "i3status-rs ~/.config/i3status-rust/config-default.toml";
          position = "top";
          fonts = {
            names = [ "DejaVu Sans Mono" ];
            size = 12.0;
          };
        }
      ];
      #up = "k";
      #down = "j";
      #right = "l";
      #left = "h";
      keybindings =
        let
          mod = config.xsession.windowManager.i3.config.modifier;
        in
        lib.mkOptionDefault {
          "${mod}+t" = "exec alacritty";
          "${mod}+d" = "kill";
          #"${mod}+a" = "exec ${pkgs.fuzzel}/bin/fuzzel";
          #"${mod}+n" = "exec ${pkgs.swaylock}/bin/swaylock";
          "${mod}+p" = "split h";
          "${mod}+w" = "split v";
          "${mod}+z" = "fullscreen";
          "${mod}+s" = "layout toggle tabbed split";
          "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $WOBSOCK";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $WOBSOCK";
          "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && (wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 0 > $WOBSOCK) || wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $WOBSOCK";

          "XF86MonBrightnessUp" = "exec brillo -equ 200000 -A 10 && brillo -G | cut -d'.' -f1 > $WOBSOCK";
          "XF86MonBrightnessDown" = "exec brillo -equ 200000 -U 10 && brillo -G | cut -d'.' -f1 > $WOBSOCK";
        };
    };
  };
}
