pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- my first platformer
--

-- globals

-- player
plyr = {
    x=40,
    y=10*8,
    vx=2,
    vy=0,
    vup=0,---4,
    g= 0.2,
    termvy= 14, -- terminal velocity
    falling=false,
}

function canmvl(p)
    mx=(p.x-p.vx)/8
    if mget(mx,p.y/8) > 0 then return false end
    if mget(mx,(p.y+7)/8) > 0 then return false end
    return true
end
function canmvr(p)
    mx=(p.x+7+p.vx)/8
    if mget(mx,p.y/8) > 0 then return false end
    if mget(mx,(p.y+7)/8) > 0 then return false end
    return true
end


function _init()
end

function _update()
    if btn(0) then --left
        if canmvl(plyr) then
            plyr.x-=plyr.vx
        end
    end
    if btn(1) then  --right
        if canmvr(plyr) then
            plyr.x+=plyr.vx
        end
    end
    if btn(2) then  --up
        if not plyr.falling then
            plyr.vy= -4 --plyr.vup
            --plyr.y+= -4
            plyr.falling = true
        end
    end

    --if btn(3) then  --down
    --    plyr.falling = true
    --end
    plyr.falling = true
    if plyr.falling then
        plyr.y+=plyr.vy
        plyr.vy=min(plyr.vy+plyr.g, plyr.termvy)
        plyr.vy=min(plyr.vy+plyr.g, plyr.termvy)
        if plyr.vy < 0 then -- going up
            if mget((plyr.x  )/8,(plyr.y)/8) > 0 or
               mget((plyr.x+7)/8,(plyr.y)/8) > 0 then
                plyr.y = (flr(plyr.y/8)+1)*8  -- reset to top of block
                plyr.vy=0
            end
        else
            if mget((plyr.x)/8,(plyr.y+8)/8) > 0 or
               mget((plyr.x+7)/8,(plyr.y+8)/8) > 0 then
                plyr.falling = false
                plyr.y = flr(plyr.y/8)*8 -- reset to top of block
                plyr.vy=0
            end
        end
    end
end

function _draw()
    cls()
    map(0, 0, 0, 0, 128, 128)
    spr(1, plyr.x, plyr.y)
end
__gfx__
00000000999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000919999190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000991111990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000299999920000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000911111190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556656565666655555665555566665555666555555600000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556665656566565555665555656656556566566665600000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556656565666556555665556556655665566565565600000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556665656566555655665565556655665566565565600000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556656565666555565665655556656556566566665600000000000000000000000000000000000000000000000000000000000000000000000000000000
65555556665656566555556666555556665555666555555600000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1400000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414000000000000000000000000141400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000013131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000001313001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000131300001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1414140000000000000013130000001400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000150000000000001313000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000150015000013131300000012121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111411111114111111141111111400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
