function make_setting(val, name, description)
    return {val=val, name=name, description=description}
end

mouse_enabled = true
mouse_visible = true

screenshot_scale = 2
gif_scale = 2
joystick_deadzone = 0.1
joystick_deadzone2 = .25

settings = {
    --Input
    mouse_enabled = make_setting(true, "Enable Mouse",""),
    mouse_visible = make_setting(false, "Show Mouse",""),
    joystick_deadzone = make_setting(0.1, "Joystick Sensitivity",""), --TODO:this

    screenshot_scale = make_setting(2, "Screenshot Scale",""),
    gif_scale = make_setting(2, "Gif Scale",""),

    sound_on = make_setting(true, "Sound", ""),
    music_on = make_setting(false, "Music", ""),
}

function set_setting(name, val)
    settings[name] = val
    return settings[name]
end

function get_setting(name)
    return settings[name].val
end