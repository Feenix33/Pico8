pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- rails10.p8
-- another attempt at following a road and state machines
-- roads types add 16 or 100
--  +- -+- -+  > v   05 09 06 01 02
--  |- -+- -|  < ^   12 15 10 03 04
--  +_ _+_ _+  - |   08 11 07 13 14
--
--  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
--  >  V  <  ^  +- -+ _+ +_ T -|  _|_|- --  |  +
--  right left up down back error turnxx

-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
--
-- todo
-- x initialize car independent on start 
-- o pathfinding instead of random movement
-- o move more than 1 space per movement
-- x stop and refuel in dead end
-- o random roads - make a separate project

--
-- Globals
cars = {}
mvxy={r={1,0},l={-1,0},u={0,-1},d={0,1}}
-- gspds={2, 5, 1} -- update speeds
-- gspd=1 -- current update speed (index)
-- gdlay=0 -- delay counter for the speed control
debug=false -- print the debug messages
-- gfree=false -- free run true or pause false
gcarbase=57 --41 -- first sprint for car
gwait=2 -- master wait delay

-- decision tree; dim1=current direction dim2 tile index; value=output direction
dtree={
    r={'l','2','r','4','r','d','u','8','trd','tud','tru','r','r','14','tudr'},
    l={'1','2','r','4','d','6','7','u','tld','l','tlu','tud','l','14','tudl'},
    u={'1','2','3','d','r','l','7','8','tlr','tul','u','tur','13','u','tulr'},
    d={'1','u','3','4','d','6','l','r','d','tdl','trl','tdr','13','d','tdlr'},
}
-- initial direction
--  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
--  >  V  <  ^  +- -+ _+ +_ T -|  _|_|- --  |  +
--       1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
ginitd={'r','d','r','u','r','r','d','u','d','u','r','l','r','u','d'}

function add_new_car(_x,_y)
    add(cars, {
        base_spr=57,
        dirspr={r=0,d=1,l=2,u=3},
        id=#cars+1,
        x=_x*8+2,
        y=_y*8+2,
        d='d', -- direction
        cnt=0,  -- turn countr
        wait=0, -- wait counter
        onspr=0, --mget(_x,_y),
        draw=function(self)
            --spr(gcarbase+dirspr[self.d], self.x-2, self.y-2)
            --spr(gcarbase+dirspr[self.d], self.x, self.y)
            spr(self.base_spr+self.dirspr[self.d], self.x, self.y)
            --rect(self.x, self.y, self.x+3, self.y+3, 15)
        end,
        dump=function(self)
            printh("id="..self.id.." xy= "
                ..self.x..","..self.y
                .." dir="..self.d
                .." on="..self.onspr
                .." cnt="..self.cnt
                )
        end,
        reinit=function(self)
            self.onspr=mget(self.x/8,self.y/8) % 100
            self.d = ginitd[self.onspr]
            --printh(self.onspr ..' '..self.d ..' '..ginitd[self.onspr])
        end,
        mvf=function(self)
            self.x+=mvxy[self.d][1]
            self.y+=mvxy[self.d][2]
            self.cnt=(self.cnt+1)%8
        end,
        mv=function(self)
            if self.wait > 0 then
                self.wait -= 1
                return
            end
            -- if here, then wait counter == 0
            if self.cnt == 0 then
                self.onspr=mget(cars[1].x/8,cars[1].y/8)
                new_dir = self.decide(self)
                if #new_dir == 1 then
                    self.d = new_dir
                else
                    --printh('new_dir = '..new_dir)
                    --self.d = sub(new_dir,2,2)
                    r = flr(rnd(#new_dir-1)) + 2
                    self.d = sub(new_dir,r,r)
                    if debug then printh('self.d= '..self.d..  ' new_dir= '..new_dir..  " alt="..sub(new_dir,r,r)) end
                end
                -- this is the delay setting
                if self.onspr >= 101 and self.onspr <= 104 then
                    self.wait = 20 -- hardcoded for test
                else
                    self.wait = gwait -- master wait delay
                end
            end
            self.mvf(self)
        end,
        decide=function(self)
            local d = self.d
            local t = self.onspr % 100
            local val = dtree[d][t]
            if debug then printh ("decide[d="..d.."][t="..t.."] = "..val) end
            return val
        end,
    })
end

function status()
    local outstr
    outstr = "x="..cars[1].x.."/"..flr(cars[1].x/8)
    outstr = outstr.." y="..cars[1].y.."/"..flr(cars[1].y/8)
    outstr = outstr.." d="..cars[1].d
    outstr = outstr.." cnt="..cars[1].cnt
    outstr = outstr.." on="..mget(cars[1].x/8,cars[1].y/8)

    rectfill(0,118, 128,128, 0)
    print(outstr, 0, 120, 7)
 
end

function draw_grid(clr)
    clr = clr or 15
    --[[
    for x=0,127,8 do
        line(x,0, x,127, clr)
    end
    for y=0,127,8 do
        line(0, y, 127, y, clr)
    end
    ]]--
    for x=0,127,8 do
        for y=0,127,8 do
            pset(x,y,clr)
        end
    end
end


function prt_table(tbl, div)
    div = div or " "
    for n=1,#tbl do
        printh ('R'..n..":  "..fmt_row(tbl[n], "|"))
    end
end
function fmt_row(row, div) -- format a row for printing
    str = ""
    div = div or " "
    for n=1,#row do
        str = str..w3(row[n])..div
    end
    return str
end

function w3(n) -- format the number to width three
    local spc
    if n<10 then
        spc = "  "
    elseif n < 100 then
        spc = " "
    else
        spc = ""
    end
    return spc..tostr(n)
end

--
-- base functions
-- 

function _init()
    -- print a runtime note
    local div,m
    m=stat(94)
    if m < 10 then div=":0" else div=":" end
    printh (stat(93)..div..stat(94).." ---------------------------------------- ")

    -- build the map at init time
    --  +- -+- -+  > v   05 09 06 01 02
    --  |- -+- -|  < ^   12 15 10 03 04
    --  +_ _+_ _+  - |   08 11 07 13 14
    local tiles = {{105, 113, 109, 113, 106,   0},
                   {114, 104, 114, 104, 112, 101},
                   {112, 111, 115, 111, 110,   0},
                   {112, 101, 114, 103, 115, 101},
                   {108, 109, 111, 113, 107,   0},
                   {  0, 114,   0,   0,   0,   0},
                   {  0, 114,   0,   0,   0,   0},
                   {  0, 114,   0,   0,   0,   0},
                   {105, 111, 113, 113, 113, 106},
                   {114,   0,   0,   0,   0, 114},
                   {114,   0,   0,   0,   0, 114},
                   {108, 113, 113, 113, 113, 107},
               }
    local y=-1
    local x=0
    local v
    for dy=1,#tiles do
        --printh('dy '..dy.."  ") --..tiles[dy])
        --printh('dx max = '..#tiles[1])
        for dx=1,#tiles[1] do
            v = tiles[dy][dx]
            --printh("mset("..(x+dx)..", "..(y+dy)..", "..v..")")
            if v > 0 then
                mset(x+dx, y+dy, tiles[dy][dx])
            end
        end
    end

    local found=false
    while not found do
        x = flr(rnd(16))
        y = flr(rnd(16))
        if mget(x, y) > 0 then
            add_new_car(x,y)
            found = true
        end
    end

    --add_new_car(1,1)
    for c in all(cars) do -- set the direction and other params
        c:reinit()
    end
    for c in all(cars) do
        c:dump()
    end
end

function _update()

    if btnp(0) then
        --printh("Btn 0 left")
        --gfree=false
        gwait = max(flr(gwait/2), 1) -- master wait delay

    elseif btnp(1) then
        --printh("Btn 1 right")
        --if (gfree) then gspd = (gspd % #gspds) + 1 end
        --gfree=true
        gwait = min(gwait*2, 8) -- master wait delay

    elseif btnp(2) then --printh("Btn 2")
        for c in all(cars) do
            --c:mvf()
            c:mv()
        end

    elseif btnp(3) then --printh("Btn 3 left")
        printh("Btn 3 down")

    elseif btnp(4) then
        printh("Btn 4")
        for c in all(cars) do
            c:decide()
        end

    elseif btnp(5) then
        --printh("Dump")
        for c in all(cars) do
            c:dump()
        end
    end

    --[[
    if gfree then
        gdlay -= 1
        if gdlay <= 0 then
            gdlay = gspds[gspd]
            for c in all(cars) do
                c:mv()
            end
        end
    end
    ]]--
    -- always move when not using the gfree construct
    for c in all(cars) do
        c:mv()
    end
end

function _draw()
    cls()
    --rect(0, 0, 127, 127, 6)
    map(0, 0, 0, 0, 128, 128)
    for c in all(cars) do
        c:draw()
    end
    --draw_grid()
    status()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000066660000000000000000000000000000000000006666000066660000000000006666000066660000666600000000000066660000666600
0000000000000000006666000000000000dddd000000000000000000006666000066660000000000006666000066660000666600000000000066660000666600
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
00000000666666d0006666000d666666006666000066666666666600666666000066666666666666666666006666666600666666666666660066660066666666
000000000000000000dddd0000000000006666000066660000666600000000000000000000666600006666000000000000666600000000000066660000666600
00000000000000000000000000000000006666000066660000666600000000000000000000666600006666000000000000666600000000000066660000666600
0000000000000000008778000000000000a77a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077770000000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008777cc7a00777700a7cc777800cccc0000aab00000aaaa00000baa00000bb00000e77a0000e77e0000a77e0000a77a00000000000000000000000000
0000000077777c770077770077c7777700c77c0000aaab0000aaaa0000baaa0000baab000077c70000777700007c7700007cc700000000000000000000000000
0000000077777c7700c77c0077c777770077770000aaab0000baab0000baaa0000aaaa000077c700007cc700007c770000777700000000000000000000000000
000000008777cc7a00cccc00a7cc77780077770000aab000000bb000000baa0000aaaa0000e77a0000a77a0000a77e0000e77e00000000000000000000000000
00000000000000000077770000000000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000a77a0000000000008778000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000e77a0000e77e0000a77e0000a77a0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000077c70000777700007c7700007cc70000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000077c700007cc700007c77000077770000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000e77a0000a77a0000a77e0000e77e0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000666600000000000000000000000000000000000066660000666600000000000066660000666600
000000000000000000000000000000000000000000000000006666000000000000dddd0000000000000000000066660000666600000000000066660000666600
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
0000000000000000000000000000000000000000666666d0006666000d6666660066660000666666666666006666660000666666666666666666660066666666
00000000000000000000000000000000000000000000000000dddd00000000000066660000666600006666000000000000000000006666000066660000000000
00000000000000000000000000000000000000000000000000000000000000000066660000666600006666000000000000000000006666000066660000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666660066660066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600000000000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
