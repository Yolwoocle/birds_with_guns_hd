# `make_gun` function documentation

### Metadata
| name                   | type    | description |
| ---------------------- | ------- | - |
| `name`                 | string  | the name of the weapon |
| `type`                 | string  | the type of bullet it fires, can be "laser" or "bullet". |
| `spr`                  | image   | the sprite of the weapon |
| `bulletspr`            | image   | the sprite of the bullet fired by the weapon |

### General properties
| name                   | type    | description |
| ---------------------- | ------- | - |
| `max_ammo`             | integer | maximum amount of ammo the gun can hold |
| `cooldown`             | float   | how long to wait between shots |
| `damage`               | float   | amount of damage it inflicts on impact |
| `bounce`               | integer | number of times the fired bullet or laser can bounce before being destroyed |
| `bullet_life`          | float   | time before the bullet is destroyed |
| `nbshot`               | integer | number of bullets or lasers created when fired |
| `spread`               | float   | range of the angles on which the bullet will be fired 360 deg -> 2pi |
| `scattering`           | float   | range of the random value added to the angle when fired |
| `bounce`               | integer | number of times the laser will bounce before being destroyed. _NOTE: this property can also be used for bullets._ |
| `scale`                | float   | the size of the laser or bullet |
| `oscale` 	             | float   |  range of the random variation of `scale` |

### Speed properties (only for bullets)
| name                   | type    | description |
| ---------------------- | ------- | - |
| `bullet_spd`           | float   | speed at which bullets travels |
| `offset_spd`           | float   | range of the random variation of `bullet_spd` |
| `spdslow`              | float   | how much a bullet slows down over time |

### Other properties
| name                   | type    | description |
| ---------------------- | ------- | - |
| `spawn_x`              | integer | x-offset of where the bullet spawns, relative to the gun position. |
| `spawn_y`              | integer | y-offset of where the bullet spawns, relative to the gun position. |
| `rafale`               | integer | number of shots when the gun is fired     TODO:rename to `burst` or something |
| `rafaledt`             | float   | time interval between shots during a burst |
| `update_option`        | function| optional custom update function for the ball or laser, called at each update. |
| `on_death`             | float   | optional custom update function for the ball or laser, called on death. |

### Laser properties:
| name                   | type    | description |
| ---------------------- | ------- | - |
| `category`             | string  | used ONLY for **lasers**: `"instant"`: fires immediately; `"persistent"`: a laser fires continuously from your weapon. TODO: rename to `laser_catergory` |
| `laser_length`         | integer | length of the laser |

### Screenshake & Camera effects
| name                   | type    | description |
| ---------------------- | ------- | - |
| `screenkick`           | number | value of the _directional_ kick when fired |
| `screenkick_shake`     | number | value of screenshake added *to the kick* when fired |
| `screenshake`          | number | value of screenshake; unline screenkick, is not directional |
| `camera_offset`        | number | how far the camera is offset when moving the mouse around |


### Charge
The following variables are similar to above, except they represent the maximum value when a "chargable" gun is max charged. 

| name | type | description |
|-|-|-|
| `charge_time`          | float                            | the time required to fully charge the weapon |

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