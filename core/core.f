" bubble core" .notice
global idiom bu:
include bu/core/2016             cr .( loaded entitlements                )
include bu/core/fixext           cr .( loaded fixed point extensions      )
include bu/core/display          cr .( loaded basic display management    )
\ include bu/core/border           cr .( loaded border system               )
include bu/core/input            cr .( loaded allegro input support words )
include bu/core/gfx              cr .( loaded graphics tools              )
include bu/core/piston           cr .( loaded the main loop               )
include bu/core/blend            cr .( loaded blending words              )
[defined] linux [if]  [else]  include bu/lib/win-clipboard.f  [then]
