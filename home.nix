{ config, pkgs, ... }:

let
  vars = import ./variables.nix;
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";

  nixpkgs.config.allowUnfree = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [

    #Coding + Devtools
    gh
    python314
    (lib.lowPrio python312)

    #Container tools
    docker
    minikube
    kubectl
    kubectx
    k9s

    #Networking
    nmap
    mtr
    postman
    mongodb-compass

    #Terminal personalization
    kitty
    eza
    fastfetch
    nix-tree
    nixpkgs-fmt

    #Fonts
    nerd-fonts.meslo-lg
    nerd-fonts.jetbrains-mono

    #Perso
    discord
    steam
    obsidian
    libreoffice
    
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  #home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  #};

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/tessa/etc/profile.d/hm-session-vars.sh
  #
  #home.sessionVariables = {
    # EDITOR = "emacs";
  #};

  # ┌───────────────────────────────────────────────────────────────┐
  # │  ZSH                                                          │
  # └───────────────────────────────────────────────────────────────┘
  programs.zsh = {
    enable            = true;
    autosuggestion.enable    = true;   # Suggestions basées sur l'historique
    syntaxHighlighting.enable = true;  # Coloration syntaxique en live

    # Historique
    history = {
      size       = 100;
      save       = 100;
      extended   = true;   # Sauvegarde le timestamp
      ignoreDups = true;
      share      = true;   # Partage l'historique entre les sessions
    };

    # Options zsh
    setOptions = [
      "HIST_VERIFY"        # Affiche la commande avant de l'exécuter depuis l'historique
      "SHARE_HISTORY"
      "APPEND_HISTORY"
      "INC_APPEND_HISTORY"
      "AUTO_CD"            # cd implicite en tapant un nom de dossier
      "GLOB_DOTS"          # Inclut les fichiers cachés dans les globs
    ];

    # Aliases
    shellAliases = {
      # ── Navigation
      ".."  = "cd ..";
      "..." = "cd ../..";
      "~"   = "cd ~";

      # ── eza (ls moderne)
      ls     = "eza --color=always --group-directories-first";
      la     = "eza --color=always --group-directories-first -la";
      lt     = "eza --color=always --group-directories-first --tree";

      # ── Git
      gs = "git status";
      gc = "git checkout";

      # ── Nix
      config    = "code ${vars.config_location}";
      rebuild   = "sudo nixos-rebuild switch --flake ${vars.config_location}#${vars.hostname}";
      update    = "sudo nix flake update --flake ${vars.config_location}";
      cleanup   = "nix-collect-garbage -d";

      # ── Divers
      ip    = "curl -s ifconfig.me";  # IP publique
      myip  = "ipconfig getifaddr en0"; # IP locale
      flush = "dscacheutil -flushcache && sudo killall -HUP mDNSResponder"; # Vide le cache DNS
      reload= "source $HOME/.zshrc && cd $HOME && clear";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src  = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Initialisations supplémentaires dans .zshrc
    initContent = builtins.readFile ./zshrc_extra.sh;
};
# ┌───────────────────────────────────────────────────────────────┐
# │  GIT                                                          │
# └───────────────────────────────────────────────────────────────┘
  programs.git = {
    enable = true;

    settings = {
      user = {
        name  = vars.gitUser;
        email = vars.gitEmail;
      };
      init.defaultBranch   = "main";
      pull.rebase          = true;
      push.autoSetupRemote = true;
      core = {
        autocrlf   = "input";
        whitespace = "trailing-space,space-before-tab";
      };
      credential.helper = "osxkeychain";
      color.ui          = "auto";
      log.date          = "iso";
    };

    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "*.orig"
      ".direnv"
      ".envrc"
      "*.log"
    ];
  };

programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Dracula";
    };
  };
  /*
  # ┌───────────────────────────────────────────────────────────────┐
  # │  KITTY                                                        │
  # └───────────────────────────────────────────────────────────────┘
  programs.kitty = {
    enable = true;
    font = {
      name = "MesloLGS Nerd Font";
      size = 12;
    };
    settings = {
      background            = "#191D27";
      background_opacity    = "0.95";
      foreground            = "#E0E0E0";
      bold_foreground       = "#EDEDED";
      selection_background  = "#273D4C";

      tab_bar_style              = "powerline";
      tab_powerline_style        = "round";
      tab_bar_background         = "#0F1218";
      active_tab_background      = "#273D4C";
      active_tab_foreground      = "#E0E0E0";
      inactive_tab_background    = "#191D27";
      inactive_tab_foreground    = "#666C7A";
    };
  };
  */
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
