#!/usr/bin/lua

local user_name = ""

------------------------------------------
-- Checking if install option is chosen --
------------------------------------------

if arg[1] == nil or #arg > 1 then
    print("Install option hasn't been chosen.\nExiting...")
    os.exit()
end

if user_name == "" then
    print("User name was not set.\nExiting...")
    os.exit()
end

----------------------
-- Helper functions --
----------------------

local function has_access()
    local handle = io.popen("id -u")
    if handle == nil then
        print("Exiting...")
        os.exit()
    end
    local user_id = handle:read("*a")
    handle:close()

    if user_id ~= "0\n" then
        return false
        -- print("Please run the script with superuser access.\nExiting...")
        -- os.exit()
    end
    return true
end

local function has_yay()
    local handle = io.popen("which yay")
    if handle == nil then
        print("Exiting...")
        os.exit()
    end
    local answer = handle:read("*a")
    handle:close()

    if answer ~= "/usr/bin/yay\n" and answer ~= "/bin/yay\n" then
        return false
        -- print("Please install yay.\nExiting...")
        -- os.exit()
    end
    return true
end

-----------------------------------
-- Running chosen install option --
-----------------------------------

local install_option = arg[1]

if install_option == "scripts" then
    has_access()

    os.execute(string.format(
        [[
su %s -c "git clone https://github.com/bmg-c/linux-scripts"
cd ./linux-scripts
chmod +x ./*
cp ./* /usr/local/bin/]],
        user_name
    ))
elseif install_option == "dwm" then
    if not has_access() then
        print("Please run the script with superuser access.\nExiting...")
        os.exit()
    end
    if not has_yay() then
        print("Please install yay.\nExiting...")
        os.exit()
    end

    os.execute(string.format(
        [[
pacman -S yajl --needed --noconfirm
su %s -c "git clone https://github.com/bmg-c/dwm
cd ./dwm
chmod +x ./startup.sh
mkdir ~/scripts/
cp ./startup.sh ~/scripts/"
cd ./dwm
make clean install]],
        user_name
    ))

    os.execute(string.format(
        [[
su %s -c "git clone https://github.com/bmg-c/dmenu"
cd ./dmenu
make clean install]],
        user_name
    ))

    os.execute(string.format(
        [[
su %s -c "git clone https://github.com/bmg-c/st"
cd ./st
make clean install]],
        user_name
    ))

    os.execute(string.format(
        [[
sudo -u %s yay -S pod2man --needed --noconfirm
su %s -c "git clone https://github.com/bmg-c/lemonbar
cd ./lemonbar
chmod +x ./bar/*
mkdir ~/scripts/bar
cp ./bar/* ~/scripts/bar/"
cd ./lemonbar
make clean install]],
        user_name,
        user_name
    ))

    os.execute(string.format(
        [[
sudo -u %s yay -S --noconfirm --needed picom-ibhagwan-git]],
        user_name
    ))
elseif install_option == "default-packages" then
    if not has_access() then
        print("Please run the script with superuser access.\nExiting...")
        os.exit()
    end
    if not has_yay() then
        print("Please install yay.\nExiting...")
        os.exit()
    end

    os.execute(string.format(
        [[
sudo -u %s yay -S --noconfirm cpupower cpupower-gui nitch flameshot]],
        user_name
    ))

    print("\n\nInstall laptop specific packages? [N]")
    local input = io.read()
    if string.lower(input) == "y" then
        os.execute(string.format(
            [[
sudo -u %s yay -S --noconfirm brightnessctl]],
            user_name
        ))
    end
elseif install_option == "configs" then
    if not has_access() then
        print("Please run the script with superuser access.\nExiting...")
        os.exit()
    end

    os.execute(string.format(
        [[
su %s -c "git clone https://github.com/bmg-c/configs"]],
        user_name
    ))

    os.execute(string.format(
        [[
su %s -c "cp -r ./configs/.config/* ~/.config/
cp ./configs/.xinitrc ~/.xinitrc
cp ./configs/.Xresources ~/.Xresources"
cp ./configs/nobeep.conf /etc/modprobe.d/nobeep.conf
cp ./configs/pacman.conf /etc/pacman.conf
cp ./configs/X11/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
]],
        user_name
    ))
elseif install_option == "amd-specific" then
    -- pcie_aspm.policy=powersave amd_pstate=active cpufreq.default_governor=powersave cpufreq.energy_performance_preference=balance_performance
    if not has_access() then
        print("Please run the script with superuser access.\nExiting...")
        os.exit()
    end

    local boot_entry = io.open("/boot/loader/entries/arch.conf", "r")
    if boot_entry == nil then
        print("Boot entry file was not found.\nExiting...")
        os.exit()
    end
    local boot_str = boot_entry:read("a")
    boot_str = string.sub(boot_str, 1, -2)
        .. " pcie_aspm.policy=powersave amd_pstate=active cpufreq.default_governor=powersave cpufreq.energy_performance_preference=balance_performance"
    boot_entry:close()

    boot_entry = io.open("/boot/loader/entries/arch.conf", "w")
    if boot_entry == nil then
        print("Boot entry file was not found.\nExiting...")
        os.exit()
    end
    boot_entry:write(boot_str)
    boot_entry:close()
elseif install_option == "test" then
    if not has_access() then
        print("Please run the script with superuser access.\nExiting...")
        os.exit()
    end

    print("\n\nInstall laptop specific packages? [N]")
    local input = io.read()
    if string.lower(input) == "y" then
        print(input)
    end
end
