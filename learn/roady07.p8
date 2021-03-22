pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- 
-- roady
-- build the map with input keys and refresh in real-time
-- add a menu?
-- play with data structures
-- 07 - basic mapping laying down roads and using table function call
-- 08 - car with engine
--
-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
--
-- road sprite reference
-- 27 28 29 30 31   cnr T  crn openL openR
-- 43 44 45 46 47   TR  X  TL    |    --- 
-- 59 60 61 62 63   crn TU crn openU openD
--
-- car sprite reference
-- 10 11 12 13 up r d l
-- dir         1  2 3 4
--

-- globals
--estate={mv=1,add=2,del=3,sz=3}
estate={mv=1,add=2,del=3,car=4,sz=4}
roads = {}
cars = {}
cmds = {}
cmds[29] = 'tfffffff'
cmds[47] = 'ffffffff'
cmds[46] = 'ffffffff'
cmds[61] = 'tfffffff'
cmds[59] = 'tfffffff'
cmds[27] = 'tfffffff'
mvxy={r={1,0},l={-1,0},u={0,-1},d={0,1}}
turnr={r='d',d='l',l='u',u='r'}


-- the cars class
function add_new_car(_x,_y)
    add(cars, {
        x=_x*8,
        y=_y*8,
        d='r', -- direction
        s=11,
        spr_car={u=10,r=11,d=12,l=13},
        cmd = cmds[mget(_x, _y)],
        ontile = mget(_x,_y),
        cn = 1,
        printh("mget("..(_x)..","..(_y)..")="..mget(_x, _y)),
        draw=function(self)
            spr(self.spr_car[self.d],self.x,self.y)
        end,
        update=function(self)
            printh ("cmd="..self.cmd.."  ["..self.cn.."]="..sub(self.cmd,self.cn,self.cn))
            step = sub(self.cmd, self.cn, self.cn)
            -- if using life indicator
            -- the something like
            -- del(cars,self)
            --printh("moving "..self.d.." = "..mvx[self.d].." "..mvy[self.d])
            if step == 'f' then
                self.x += mvxy[self.d][1]
                self.y += mvxy[self.d][2]
            elseif step == 't' then
                self.d = turnr[self.d]
                self.x += mvxy[self.d][1]
                self.y += mvxy[self.d][2]
            else
                printh("unhandled command "..step)
            end
            -- get ready for next step
            self.cn += 1
            if self.cn > #self.cmd then
                self.cn = 1
                printh("Getting "..(self.x/8)..","..(self.y/8).." = "..mget(self.x/8, self.y/8))
                self.cmd = cmds[mget(self.x/8, self.y/8)]
                ontile = mget(self.x/8, self.y/8)
                --printh("  Move to next tile="..mget(self.x/8, self.y/8).." cmd="..self.cmd)
                printh("  Move to next tile="..self.ontile.." cmd="..self.cmd)
                printh("  Coords=("..self.x..","..self.y..") -> ("..(self.x/8)..","..(self.y/8)..")")
            end
        end,
        turn_right=function(self)
            self.d=(self.d%4)+1
            printh("turn_right "..self.d)
        end,
    })
end

-- the cursor input class
curs = {
    x=16,
    y=24,
    est=estate.mv,
    clr=1,
}

curclr= { 5, 11, 8, 10} -- translate state to cursor color (fake function)

function act_mv(x, y)
    return
end
function act_add(x, y)
    --mset(x/8, y/8, 44)
    mx=(x/8)+1
    my=(y/8)+1
    printh ("attempting add "..x..", "..y.."=="..(x/8)..", "..(y/8))
    --if x <= 0 then printh("error x neg") end
    --if y <= 0 then printh("error y neg") end
    --if x >= 128 then printh("error x pos") end
    --if y >= 128 then printh("error y pos") end
    roads[my][mx] = 1
end
function act_del(x, y)
    --mset(x/8, y/8, 0)
    --roads[y/8][x/8] = 0
    mx=(x/8)+1
    my=(y/8)+1
    roads[my][mx] = 0
end
function act_turn_car(x,y)
    for c in all(cars) do
        c:turn_right()
    end
end
action_fcns = {act_mv, act_add, act_del, act_turn_car}


--             1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
neigh_tile = {62,31,59,63,46,27,43,30,61,47,60,29,45,28,44,26} 
function check(x,y)
    if x <= 0 or y <= 0 then return 0 end
    if x > 16 or y > 16 then return 0 end
    return roads[y][x]
end

function refresh()
    local neigh=0

    for y =1,16 do
        for x =1,16 do
            if roads[y][x] == 1 then
                neigh = 0
                --count the neighbors
                if check(x,y-1)==1 then neigh+= 1 end
                if check(x+1,y)==1 then neigh+= 2 end
                if check(x,y+1)==1 then neigh+= 4 end
                if check(x-1,y)==1 then neigh+= 8 end
                --set the tile based on neighbors
                if neigh==0 then neigh = 16 end
                mset(x-1,y-1,neigh_tile[neigh])
            else
                mset(x-1,y-1,0)
            end
        end
    end
end


function _init()
    printh("--------------------------------------------------")

    curs.est= (curs.est+1)%estate.sz+1
    for y =1,16 do
        roads[y] = {}
        for x =1,16 do
            roads[y][x] = 0
        end
    end
    for y=1,5 do
        for x=1,5 do
            if y==1 or y==5 or x==1 or x==5 then
                roads[y][x] = 1
            end
        end
    end
    refresh()
    add_new_car(1,0)
end

function _update()
    redo = false
    if btnp(0) then --left
        curs.x=(curs.x+120)%128
        redo = true
    end
    if btnp(1) then curs.x=(curs.x+8)%128
        redo = true
    end
    if btnp(2) then curs.y=(curs.y+120)%128
        redo = true
    end
    if btnp(3) then curs.y=(curs.y+8)%128 
        redo = true
    end
    if btnp(4) then
        curs.est= (curs.est%estate.sz)+1
        printh("e-state="..curs.est)
    end
    if redo then
        action_fcns[curs.est](curs.x, curs.y)
        refresh()
    end
    if btnp(5) then
        for c in all(cars) do
            c:update()
        end
    end
end

function _draw()
    cls()
    map(0, 0, 0, 0, 128, 128)
    rect(curs.x, curs.y, curs.x+7, curs.y+7, curclr[curs.est])
    -- draw a grid
    for x=0,127,8 do
        line(x, 0, x, 7, 3) 
    end
    for c in all(cars) do
        c:draw()
    end
end
__gfx__
00000000999999994444444444444444444444440044440044440000000000000000000000000000000000000000000000000000000000000000000000000000
00000000919999194919919449199194491991940019910019910000000000000000000000000000000000000000000000000000000000000000000000000000
00000000991111994999999449999994999999990099990099990000000000000000000000000000004994000049940000499400004994000000000000000000
00000000299999924991199449911994099119900091190091190000000000000000000000000000009cc9000099c90000999900009c99000000000000000000
00000000222222228888888822222222eeeeeeee0088880088880000000000000000000000000000009999000099c900009cc900009c99000000000000000000
00000000222222228888888822222222eeeeeeee0088880088880000000000000000000000000000004994000049940000499400004994000000000000000000
0000000091111119911111199eeeeee9911111190091190091190000000000000000000000000000000000000000000000000000000000000000000000000000
000000001111111111111111eeeeeeee011111100011110011110000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666600000000000000000000000000000000666666666666666666666666666666666666666666666666
65555556656565666655555665555566665555666555555600000000000000000000000000000000666666666666666666666666666666666666666666666666
65555556665656566565555665555656656556566566665600000000000000000000000000000000665555666655555555555555555555665555556666555555
65555556656565666556555665556556655665566565565600000000000000000000000000000000665555666655555555555555555555665555556666555555
65555556665656566555655665565556655665566565565600000000000000000000000000000000665555666655555555555555555555665555556666555555
65555556656565666555565665655556656556566566665600000000000000000000000000000000665555666655555555555555555555665555556666555555
65555556665656566555556666555556665555666555555600000000000000000000000000000000666666666655556666555566665555666666666666666666
66666666666666666666666666666666666666666666666600000000000000000000000000000000666666666655556666555566665555666666666666666666
bbbbbbbbbbbbbbbb6666666664444446644444466444444600000000bbbbbbb44bbbbbbbbbbbbbbbbbbbbbbb6655556666555566665555666655556666666666
bb3bbbbbbb3bbb3b4444444464444446444444444444444400000000bbbbbb4444bbbbbbbbbbbbb55bbbbbbb6655556666555566665555666655556666666666
bbbbb3bbbbbbbbbb4444444464444446444444444444444400000000bbbbb445544bbbbbbbbbbb5555bbbbbb6655555555555555555555666655556655555555
bbbbbbbbbbbbb3bb4444444464444446444444444444444400000000bbbb44555544bbbbbbbbb554455bbbbb6655555555555555555555666655556655555555
bb3bbbbbbbbbbbbb4444444464444446444444444444444400000000bbb4455555544bbbbbbb55444455bbbb6655555555555555555555666655556655555555
bbbbbb3bbb3bbbbb4444444464444446444444444444444400000000bb445555555544bbbbb5544cc4455bbb6655555555555555555555666655556655555555
bbbbbbbbbbbbbb3b4444444464444446444444444444444400000000b44555555555544bbb55444cc44455bb6655556666555566665555666655556666666666
b3bbbbbbbbbbbbbb66666666644444466444444666666666000000004455555555555544b55444444444455b6655556666555566665555666655556666666666
bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000455555555555555455444444444444556655556666555566665555666655556666666666
bb3333bbbbb33bbb0000000000000000000000000000000000000000b55555555444455bb44555444444444b6655556666555566665555666655556666666666
b333333bbb3333bb0000000000000000000000000000000000000000b5cccc555444455bb445554444ccc44b6655555555555555555555666655556666555566
b333333bbb3333bb0000000000000000000000000000000000000000b5cccc555444455bb45555544ccccc4b6655555555555555555555666655556666555566
bb3333bbb333333b0000000000000000000000000000000000000000b5cccc555944455bb45555544ccccc4b6655555555555555555555666655556666555566
bbb44bbbb333333b0000000000000000000000000000000000000000b5cccc555944455bb455559444ccc44b6655555555555555555555666655556666555566
bbb44bbbbbb44bbb0000000000000000000000000000000000000000b55555555444455bb45555544444444b6666666666666666666666666666666666555566
bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000b55555555444455bb45555544444444b6666666666666666666666666666666666555566
