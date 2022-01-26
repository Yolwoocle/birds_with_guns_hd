# How to creat a gun :     
                          
name        : the name of the weapon                                                                                                        string
type        : the type of bullet it fires, can be "laser" or "bullet".                                                                      "laser" or "bullet"
spr         : the sprite of the weapon                                                                                                      variabel corresponding to sprite
bulletspr   : the sprite of the bullet fired by the weapon                                                                                  variabel corresponding to sprite
damage      : the amount of damage it inflicts on impact                                                                                    float
category    : used ONLY for **lasers**, can be "instant" it fires immediately or "persistent" a laser fires continuously from your weapon.  "instant" or "persistent"
bounce      : the number of times the bullet or laser can bounce before being destroyed                                                     integer
bullet_spd  : used ONLY for **balls** the speed at which the bullet travels                                                                 float
offset_spd  : the difference between the fastest and slowest bullet your weapon can fire                                                    float
cooldown    : how long to wait between shots                                                                                                float
max_ammo    : the maximum amount of ammunition your gun can hold                                                                            integer
scattering  : the random offset on the bullet or laser angel to add imprecision                                                             float
spawn_x	    : the x-offset of where the bullet appears in relation to the player's center                                                   integer
spawn_y	    : the y-offset of where the ball appears relative to the center of the player                                                   integer
rafale	    : the number of times the gun fires                                                                                             integer
rafaledt    : the time between the moment the burst is fired                                                                                float
bullet_life	: the time before the bullet is destroyed                                                                                       float
laser_length: used ONLY for **lasers** the length of the laser                                                                              integer
nbshot 	    : the number of bullets or lasers it creates in a single shot                                                                   integer
spread 	    : the range of the angels on which the bullet will be fired 360 -> 2ft                                                          float
spdslow	    : used ONLY for **balls** the number by which the speed of the bullet will be multiplied per second                             float
scale 		: the size of the bullet or laser                                                                                               float  
oscale 		: the difference in size between the largest and smallest bullet                                                                float
vitesse_max : the maximum speed at which a ball can go                                                                                      float
on_death 	: the function that is called when the bullet dies                                                                              function
screenkick  : for leo
screenshake : for leo
screenkick_shake : for leo

charge				: whether the weapon must be loaded before firing                                                                   boolean
charge_curve		: the type of function that the loading advance performs                                                            float
charge_time 		: the time required to fully charge the weapon                                                                      float
charge_nbrafale 	: same as above but is added according to the time you spent loading the gun                                        -------
charge_bullet_spd 	: same as above but is added according to the time you spent loading the gun                                        -------
charge_laser_length : same as above but is added according to the time you spent loading the gun                                        -------
charge_nbshot 		: same as above but is added according to the time you spent loading the gun                                        -------
charge_spread 		: same as above but is added according to the time you spent loading the gun                                        -------
charge_scattering	: same as above but is added according to the time you spent loading the gun                                        -------
charge_scale 		: same as above but is added according to the time you spent loading the gun                                        -------
charge_oscale		: same as above but is added according to the time you spent loading the gun                                        -------
charge_ospd 		: same as above but is added according to the time you spent loading the gun                                        -------
charge_life 		: same as above but is added according to the time you spent loading the gun                                        -------
charge_rafaledt		: same as above but is added according to the time you spent loading the gun                                        -------
charge_spdslow 		: same as above but is added according to the time you spent loading the gun                                        -------
charge_damage		: same as above but is added according to the time you spent loading the gun                                        -------