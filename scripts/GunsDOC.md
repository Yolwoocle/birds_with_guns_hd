# How to create a gun

| type                   | name                             | description |
| ---------------------- | -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `name`                 | string                           | the name of the weapon |
| `type`                 | string              | the type of bullet it fires, can be "laser" or "bullet". |
| `spr`                  | image | the sprite of the weapon |
| `bulletspr`            | image | the sprite of the bullet fired by the weapon |
| `damage`               | float                            | the amount of damage it inflicts on impact |
| `category`             | string                           | used ONLY for **lasers**, can be "instant" it fires immediately or "persistent" a laser fires continuously from your weapon. |
| `bounce`               | integer                          | the number of times the bullet or laser can bounce before being destroyed |
| `bullet_spd`           | float                            | used ONLY for **balls** the speed at which the bullet travels |
| `offset_spd`           | float                            | the difference between the fastest and slowest bullet your weapon can fire |
| `cooldown`             | float                            | how long to wait between shots |
| `max_ammo`             | integer                          | the maximum amount of ammunition your gun can hold |
| `scattering`           | float                            | the random offset on the bullet or laser angel to add imprecision |
| `spawn_x`              | integer                          | the x-offset of where the bullet appears in relation to the player's center |
| `spawn_y`              | integer                          | the y-offset of where the ball appears relative to the center of the player |
| `rafale`               | integer                          | the number of times the gun fires |
| `rafaledt`             | float                            | the time between the moment the burst is fired |
| `bullet_life`          | float                            | the time before the bullet is destroyed |
| `laser_length`         | integer                          | used ONLY for **lasers** the length of the laser |
| `nbshot`               | integer                          | the number of bullets or lasers it creates in a single shot |
| `spread`               | float                            | the range of the angels on which the bullet will be fired 360 -> 2ft |
| `spdslow`              | float                            | used ONLY for **balls** the number by which the speed of the bullet will` |

The following variables are similar to above except they represent the maximum value when a "chargable" gun is max charged. 

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