# `make_gun` function documentation

### Metadata
| name                   | type    | default value | description |
| ---------------------- | ------- | - | - |
| `name`                 | string  | `"gun"` | the name of the weapon |
| `type`                 | string  | `"bullet"` | the type of bullet it fires, can be "laser" or "bullet". |
| `spr`                  | image   | `spr_revolver` | the sprite of the weapon |
| `bulletspr`            | image   | `spr_bullet` | the sprite of the bullet fired by the weapon |

### General properties
| name                   | type    | default value | description |
| ---------------------- | ------- | - | - |
| `max_ammo`             | integer | `100` | maximum amount of ammo the gun can hold |
| `cooldown`             | float   | `0.2` | how long to wait between shots |
| `damage`               | float   | `1` | amount of damage it inflicts on impact |
| `bounce`               | integer | `0` | number of times the fired bullet or laser can bounce before being destroyed |
| `bullet_life`          | float   | `2` | time before the bullet is destroyed |
| `nbshot`               | integer | `1` | number of bullets or lasers created when fired |
| `spread`               | float   | `pi/5` | range of the angles on which the bullet will be fired 360 deg -> 2pi |
| `scattering`           | float   | `0.1` | range of the random value added to the angle when fired |
| `bounce`               | integer | `0` | number of times the bullets or lasers bounce before being destroyed.
| `scale`                | float   | `1` | the size of the laser or bullet |
| `oscale` 	             | float   | `0` | range of the random variation of `scale` |
| `speed_max` | float | None | cap speed |

### Speed properties (only for bullets)
| name                   | type    | default value | description |
| ---------------------- | ------- | - | - |
| `bullet_spd`           | float   | `600` | speed at which bullets travels |
| `offset_spd`           | float   | `0` | range of the random variation of `bullet_spd` |
| `spdslow`              | float   | `1` | how much a bullet slows down over time |

### Other properties
| name                   | type    | default value | description |
| ---------------------- | ------- | - | - |
| `spawn_x`              | integer | width of `spr` | x-offset of where the bullet spawns, relative to the gun position. |
| `spawn_y`              | integer | `0` | y-offset of where the bullet spawns, relative to the gun position. |
| `burst`               | integer | `1` | number of shots when the gun is fired |
| `burstdt`             | float   | `0.5` | time interval between shots during a burst |

### Functions
| name | type | default value | description |
| - |-|-|-|
| `make_shot`        | function| `default_shoot` | function that returns a bullet object that will be inserted into the bullet table |
| `update_option`        | function| None | optional custom update function for the ball or laser, called at each update. |
| `on_death`             | function| `kill` | optional custom update function for the ball or laser, called on death. |

### Laser properties:
| name                   | type    | default value | description |
| ---------------------- | ------- | - | - |
| `category`             | string  | `"instant"` | used ONLY for **lasers**: `"instant"`: fires immediately; `"persistent"`: a laser fires continuously from your weapon. TODO: rename to `laser_catergory` |
| `laser_length`         | integer | `100` | length of the laser |

### Screenshake & Camera effects
| name                   | type    | default value | description |
| ---------------------- | ------- | - | - |
| `screenkick`           | number | `6` | value of the _directional_ kick when fired |
| `screenkick_shake`     | number | `1` | value of screenshake added *to the kick* when fired |
| `screenshake`          | number | `6` | value of screenshake; unline screenkick, is not directional |
| `camera_offset`        | number | `0.3` | how far the camera is offset when moving the mouse around. 1 means that the camera will follow exactly the cursor. |

### Particles
```
		ptc_type = a.ptc_type or "none", 
		ptc_size = a.ptc_size or 10,
```

### Charge
The following variables are similar to above, except they represent the maximum value when a "chargable" gun is max charged. 

| name | type | default value | description |
|-|-|-|-|
| `charge` | bool | false | whether weapon charging is enabled |
| `charge_time` | float | 1 | the time required to fully charge the weapon |
| `charge_curve` | int | 2 | TODO |

| name | 
|-|
| `charge_nbrafale`      |
| `charge_bullet_spd`    |
| `charge_laser_length`  |
| `charge_nbshot`        |
| `charge_spread`        |
| `charge_scattering`    |
| `charge_scale`         |
| `charge_oscale`        |
| `charge_ospd`          |
| `charge_life`          |
| `charge_rafaledt`      |
| `charge_spdslow`       |
| `charge_damage`        |
