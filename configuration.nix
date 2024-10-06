# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
	imports = [ # Include the results of the hardware scan.
			./hardware-configuration.nix
			 <home-manager/nixos>
		];

	hardware.bluetooth.enable = true;
	hardware.bluetooth.powerOnBoot = true;

	services.devmon.enable = true;
	services.gvfs.enable = true;
	services.udisks2.enable = true;


	services.blueman.enable = true;

	nix.optimise.automatic = true;
	nix.optimise.dates = [ "03:45" ]; # Optional; allows customizing optimisation schedule




	#https://francis.begyn.be/blog/nixos-restic-backups
	services.restic.server= {

		enable = true;
		extraFlags = [ "--no-auth" ];

	};




	services.restic.backups = {
		onedrive = {
			repository = "rclone:onedrive:/backups";
			initialize = true;
			passwordFile = "/home/hak/.config/secrets/password";
			rcloneConfigFile="/home/hak/.config/rclone/rclone.conf";

			paths = ["/home/hak/" "/var/lib" ];
			exclude = ["/home/hak/backups/.local /home/hak/backups/.cache"];
			timerConfig = {
				OnCalendar = "00:05";
				Persistent = true;
				RandomizedDelaySec = "5h";
			};
		};
	};

	# Uncomment resolvd and add the following to the end of the vpn config

	# <auth-user-pass>
	# user
	# password
	# </auth-user-pass>
	# services.openvpn.servers.protonvpn = {
	# 	config = "config /home/hak/.config/openvpn/jp-free-141028.protonvpn.udp.ovpn";
	# 	authUserPass.username = builtins.readFile /home/hak/.config/secrets/protonvpn.username;
	# 	authUserPass.password = builtins.readFile /home/hak/.config/secrets/protonvpn.password;
	# 	updateResolvConf = true;
	# };

	nix.gc = {
		automatic = true;
		randomizedDelaySec = "14m";
		options = "--delete-older-than 10d";
	};

	boot.loader.systemd-boot.configurationLimit = 10;


	boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];


	hardware.graphics = {
		enable = true;
		extraPackages = with pkgs; [
			ocl-icd
			intel-ocl
			intel-media-driver
			intel-compute-runtime
		];
	};


	services.xserver.videoDrivers = ["nvidia"];

	# hardware.nvidia.open = true;
	hardware.nvidia = {
		modesetting.enable = true;
		# nvidiaPersistanced = true;

		powerManagement.enable = true;
		powerManagement.finegrained = false;
		open = false;
		nvidiaSettings = true;

		package = config.boot.kernelPackages.nvidiaPackages.stable;

		prime = {
			offload = {
				enable = true;
				enableOffloadCmd = true;
			};
			intelBusId = "PCI:0:2:0";
			nvidiaBusId = "PCI:1:0:0";
		};
	};

	services.tlp = {
		enable = true;
		settings = {

			CPU_SCALING_GOVERNOR_ON_AC = "performance";
			CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

			CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
			CPU_ENERGY_PERF_POLICY_ON_BAT = "power";


			CPU_MIN_PERF_ON_AC = 0;
			CPU_MAX_PERF_ON_AC = 100;
			CPU_MIN_PERF_ON_BAT = 0;
			CPU_MAX_PERF_ON_BAT = 20;


			# START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
			STOP_CHARGE_THRESH_BAT0 = "0"; # 80 and above it stops charging


		};
	};

	powerManagement.powertop.enable = true;






	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking = {
		networkmanager.enable = true;
		# useNetworkd = true;
		hostName = "nixos-hak"; # Define your hostname.
		# wireless.enable = true;  # Enables wireless support via wpa_supplicant.
		nameservers = [ "1.1.1.1" "194.242.2.3" ]; #Cloudfare and mullvad
		networkmanager.dns = "systemd-resolved";
	};
	services.resolved.enable=true;

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";



	# Set your time zone.
	time.timeZone = "Asia/Karachi";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";

	i18n.extraLocaleSettings = {
		LC_ADDRESS = "en_IN";
		LC_IDENTIFICATION = "en_IN";
		LC_MEASUREMENT = "en_IN";
		LC_MONETARY = "en_IN";
		LC_NAME = "en_IN";
		LC_NUMERIC = "en_IN";
		LC_PAPER = "en_IN";
		LC_TELEPHONE = "en_IN";
		LC_TIME = "en_IN";
	};

	# Configure keymap in X11
	services.xserver = {
		xkb.layout = "us,pk";
		xkb.variant = ",urd-crulp";
		xkb.options = "ctrl:nocaps, grp:alt_space_toggle";

		enable = true;
		desktopManager = {
			xterm.enable = false;
		};
		windowManager.i3 = {
			enable = true;
			extraPackages = with pkgs; [
				i3status
				i3lock
				i3blocks
				rofi
			];
		};
	};

	services.displayManager.sddm = {
		enable = true;
		package = pkgs.kdePackages.sddm;
		wayland.enable = true;
		theme = "catppuccin-mocha";
	};

	programs.hyprland = {
		# Install the packages from nixpkgs
		enable = true;
		# Whether to enable XWayland
		xwayland.enable = true;
	};


	services.displayManager = {
		enable=true;
		# defaultSession = "none+i3";
		defaultSession = "hyprland";
	};


	# Sound stuff
	# sound.enable = true;
	# hardware.pulseaudio.enable = true;
	# nixpkgs.config.pulseaudio = true;




	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.hak = {
		isNormalUser = true;
		description = "hak";
		extraGroups = [ "docker" "networkmanager" "wheel" "dialout" "storage"];
		packages = with pkgs; [];
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	nixpkgs.config.packageOverrides = pkgs: {
		nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
			inherit pkgs;
		};
	};


	nix.settings.experimental-features = ["nix-command" "flakes"];


	environment.systemPackages = with pkgs; [
		vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
		wget
		fish 
		nitrogen
		i3 
		alacritty
		microsoft-edge
		docker
		go
		discord
		xorg.xhost
		steam
		xclip
		tmux
		flameshot

		git-credential-manager
		any-nix-shell
		gnumake
		ncurses
		markdownlint-cli
		texliveFull
		
		lua
		zathura
		tree-sitter
		nodejs_22
		libGL

		intel-ocl
		pocl
		opencl-headers
		ocl-icd


		clang
		clang-tools



		ciscoPacketTracer8
		nur.repos.nltch.spotify-adblock


		(catppuccin-sddm.override {
			flavor = "mocha";
			font  = "Noto Sans";
			fontSize = "9";
			background = /home/hak/.background-image;
			loginBackground = true;
		})


	];


  environment.sessionVariables = {
		EDITOR = "nvim";
  };


	programs.java = {
		enable = true;
		package = ( pkgs.jdk21.override {enableJavaFX = true;} );
	};


	programs.nix-ld.enable = true;


	fonts = {
		enableDefaultPackages = true;
		packages = with pkgs; [
			nafees
			ubuntu_font_family
			noto-fonts
			(nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
		];

		fontconfig = {
			defaultFonts = {
				serif = [ "FiraCode" "nafees" ];
				sansSerif = [ "Ubuntu" "nafees" ];
				monospace = [ "Ubuntu Mono" ];

			};
		};
	};

	services.libinput = {
		enable = true;
		# mouse.accelProfile = "flat";
		mouse.accelSpeed = "-0.9";
	};




	# programs.gpg.enable = true;
	#
	# services.gpg-agent = {
	# 	enable = true;
	# 	enableSshSupport = true;
	# 	pinetryFlavor = "gtk2";
	# };

	virtualisation.docker.rootless = {
		enable = true;
		setSocketVariable = true;
	};

	services.dockerRegistry = {
		enable = true;
		# storagePath = "/home/hak/hdd/docker";
	};
	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	programs.mtr.enable = true;
	programs.gnupg.agent = {
	  enable = true;
	  enableSSHSupport = true;
	};

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ 80 443 ];
		allowedUDPPortRanges = [
			{ from = 4000; to = 4007; }
			{ from = 8000; to = 8010; }
		];
	};

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.11"; # Did you read the comment?


}
                              
