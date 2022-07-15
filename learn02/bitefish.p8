pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
bite size game cells
from nerdyteachers.com
fish game, no sprites
]]--
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====


-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init() --iiiiiii
  -- colors
  _black = 0
  _dkblue = 1
  _purple = 2
  _dkgreen = 3
  _brown = 4
  _dkgrey = 5
  _grey = 6
  _white = 7
  _red = 8
  _orange = 9
  _yellow = 10
  _green = 11
  _blue = 12
  _indigo = 13
  _pink = 14
  _peach = 15

  -- player table
  player={
    x = 60, -- pos on x axis
    y = 60, -- pos on y axis
    w = 0,  -- width //inner circle clr
    h = 0,  -- height / outer circle clr
    size = 3, -- a number to compare player & enemy sizes and set fish sprite
    sx = 0, -- a number used for the sprite x pos
    sy = 0,
    dx = 0, -- delta x for change in x axis momentum
    dy = 0, -- -dy up -dx left
    speed = 0.08, -- increase in momentum when btn pressed
    flp = false, -- bool to control flip sprite left or right
  }
  player = set_sprite(player)
  -- game settings
  enemies = {} -- enemy table
  max_enemies = 15 -- max enemies
  max_enemy_size = 10 -- number of pixels for largest enemy radius
  max_enemy_speed = 0.5 -- 1 -- avg speed of enemies
  win_size = 10 -- how many to eat to win
  weeds = { -- tbl where to draw seaweed
    {x1=  4,y1=120,x2=  2,y2=101},
    {x1=  6,y1=123,x2=  8,y2=103},
    {x1=110,y1=125,x2=109,y2=102},
    {x1=121,y1=122,x2=120,y2=104},
    {x1=123,y1=122,x2=125,y2=102},
  }
end

function _update() --uuuuuuuu



  -- player controls
  if btn(⬅️) then player.dx -= player.speed player.flp=true end
  if btn(➡️) then player.dx += player.speed player.flp=false end
  if btnp(⬆️) then player.dy -= player.speed end
  if btnp(⬇️) then player.dy += player.speed end

  if btnp(4) then --printh("Btn 4 = cv")
    local n=1
    printh('')
    for enemy in all (enemies) do
      printh('enemy'..n..' x='..enemy.x..' y='..enemy.y..' r='..enemy.r..' dx='..enemy.dx..' dy='..enemy.dy)
      n+=1
    end
  elseif btnp(5) then printh("Btn 5 = nm")
  end

  -- player movement
  player.x += player.dx
  player.y += player.dy

  -- flip sides
  if player.x > 127 then player.x = 1 end
  if player.x < 0 then player.x = 126 end
  if player.y+player.h > 120 then player.y = 120-player.h player.dy = 0 end
  if player.y < 0 then player.y = 0 player.dy = 0 end

  -- enemy update
  create_enemies()
  for enemy in all (enemies) do
    -- move
    enemy.x += enemy.dx
    --enemy.y += enemy.dy

    -- ouside screen
    if enemy.x > 200
      or enemy.x < -70 then
      del(enemies, enemy)
    end

    -- collide w/player
    if collide_obj(player, enemy) then
      -- compare size
      if flr(player.size) > enemy.size then
        player.size += flr((enemy.size/2)+.5) / (player.size*2)

				--set sprite based on size
				player = set_sprite(player)

        sfx(0)
        del (enemies, enemy)
      else
        sfx(1)
        _init()
      end
    end
  end
  --[[
  ]]--
end

function _draw() --dddddd
  cls(12)
  -- sand
  rectfill(0,120,127,127,15)

  -- seaweed
  for weed in all(weeds) do
    line(weed.x1,weed.y1,weed.x2,weed.y2,3)
    line(weed.x1+1,weed.y1+1,weed.x2+1,weed.y2+1,11)
  end

  -- rocks
  circfill(  8,120,5,13)
  circfill(  5,123,3, 5)
  circfill(100,122,4,13)
  circfill(122,118,6, 6)
  circfill(116,120,3, 5)

  -- player
  sspr(player.sx,player.sy,player.w,player.h,player.x,player.y,player.w,player.h,player.flp)

  -- enemies
  for enemy in all(enemies) do
    pal(9,enemy.c)
    sspr(enemy.sx,enemy.sy,enemy.w,enemy.h,enemy.x,enemy.y,enemy.w,enemy.h,enemy.flp)
  end
	pal()

  -- player size
  rectfill(2,3,22,10,0)
  rectfill(2,4,2+(player.size-flr(player.size))*20,9,8)

  -- win
  if player.size > win_size then
    rectfill(0, 55, 127, 75, _dkgrey)
    print("congratulations!!!", 28, 56, _blue)
    print("you became", 43, 63, _blue)
    print("the biggest fish!", 20, 70, _blue)
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
--[[
]]--
function collide_obj(obj, other)
  if other.x+other.w > obj.x
    and other.y+other.h > obj.y
    and other.x < obj.x+obj.w
    and other.y < obj.y+obj.h
    then
      return true
  end
end

function create_enemies()
  if #enemies < max_enemies then
    -- local vars
    local x = 0 -- x,y enenemy fish pos
    local y = 0
    local dx = 0 -- enemy fish speed and dir
    local size = flr(rnd((max_enemy_size+player.size)/2))+1 -- enmy fish size 1-10
    local flp = false -- flip left or right
    local c = flr(rnd(7))+1 -- enemy fish color

    -- rand start pos
    place = flr(rnd(2))
    if place==0 then
      -- left
      x = flr(rnd(16)-64)
      y = flr(rnd(115))
      dx = rnd(max_enemy_speed)+.25
      flp = false
    else
      -- right
      x = flr(rnd(48)+128)
      y = flr(rnd(115))
      dx = -rnd(max_enemy_speed)-.25
      flp = true
    end

    -- make enemy table
    local enemy = {
      sx = 0,
      sy = 0,
      x = x,
      y = y,
      w = 0,
      h = 0,
      c = c,
      dx = dx,
      size = size,
      flp = flp,
    }

    -- set sprite based on size
    enemy = set_sprite(enemy)

    -- add it to enemies table
    add(enemies, enemy)
  end
end


-- set sprite
function set_sprite(obj)
  if flr(obj.size) <=1 then
    obj.sx = 0 obj.sy = 0 obj.w = 4 obj.h = 3
  elseif flr(obj.size) == 2 then
    obj.sx = 5 obj.sy = 0 obj.w = 4 obj.h = 4
  elseif flr(obj.size) == 3 then
    obj.sx = 9 obj.sy = 0 obj.w = 6 obj.h = 5
  elseif flr(obj.size) == 4 then
    obj.sx = 15 obj.sy = 0 obj.w = 9 obj.h = 7
  elseif flr(obj.size) == 5 then
    obj.sx = 24 obj.sy = 0 obj.w = 14 obj.h = 9
  elseif flr(obj.size) == 6 then
    obj.sx = 38 obj.sy = 0 obj.w = 14 obj.h = 10
  elseif flr(obj.size) == 7 then
    obj.sx = 52 obj.sy = 0 obj.w = 16 obj.h = 12
  elseif flr(obj.size) == 8 then
    obj.sx = 68 obj.sy = 0 obj.w = 15 obj.h = 15
  elseif flr(obj.size) == 9 then
    obj.sx = 83 obj.sy = 0 obj.w = 19 obj.h = 16
  elseif flr(obj.size) == 10 then
    obj.sx = 102 obj.sy = 0 obj.w = 26 obj.h = 17
  else
    obj.sx = 102 obj.sy = 0 obj.w = 26 obj.h = 17
  end
  return obj
end


-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
-- collection of support functions
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function log(_lvl, _msg, _ind) local ind=_ind or '' if _lvl < 5 then printh(ind.._msg) end end
function irand(n) return ceil(rnd(n)) end -- rand in [1..n]
function irand0(n) if (n==0) then return 0 else return ceil(rnd(n))-1 end end -- rand in [0..n)
function tblstr(_t) out="" for j=1,#_t-1 do out=out.._t[j].."," end return out.._t[#_t] end
function shuffle(t) for i=#t,1,-1 do local j=flr(rnd(i))+1 t[i],t[j] = t[j],t[i] end end
function contains(_tbl,_el) for _ in all(_tbl) do if _==_el then return true end end return false end

__gfx__
9f00999009a090090000f0009d900000d0000099900000e0000080000008800000009900000ddd000009000000099999900000e0000000000e8e888800000000
09990999909999909009999009d90000dd099009e90000ee000098000008880000009990000dddd0000a9000009a99a99900008e000000000000e88880000000
9f00098880099190f9999199009d9099999199009e90099999909980000888899990d99900099999900fa9000999a99a99900098e000000000000e8888000000
000088e0009aaaa00f9a99900099d9999991990099e9099971999998009999997199dd99909999999909fa9099999a99999900998e000000009999e888899000
0000000009a00000f99999990009999a99999000099e99a9119909998a99a999119909d999999971999a9fa999a999999999909998e000000999999999999900
000000000000000090ff0f000099d999a9999900099e999999990a998a999a99999909d9999999119999a9f999fa999971199089998e000099a9999999999990
000000000000000900000000009d90999999990099e9a99999000a998a9a99999999009d999a9999999f9a9999afa99911199f089998e009999a999997119999
00000000000000000000000009d9000ddd0dd0009e900aaaa99909998a99a9999900009d9999a9999999f9a999fafa991119ff00899999999999999991119999
0000000000000000000000009d90000d00000009e9000ee00aaa999800aaaaaaaa9909d99999999d0009f9a999fafa99999f00000e999a999999999999999999
000000000000000000000000000000000000009990000e000e00998000888000880009d99d9a9999d00f9a9999afa999999f0000089999a999a999a99999aaaa
00000000000000000000000000000000000000000000000000009800008800008000dd9990d9a999ddd9a9f999fa9999999fff0008999999999a999a99998000
00000000000000000000000000000000000000000000000000008000008000000000d999000ddddd000a9fa999a999a999990f000e99aaa99999a99999999800
0000000000000000000000000000000000000000000000000000000000000000000099900000ddd00009fa90a999999a999a0000899a00008999999999999988
0000000000000000000000000000000000000000000000000000000000000000000099000000dd00000fa9000a99a99999a0000099a0000888999999988899a0
0000000000000000000000000000000000000000000000000000000000000000000000000000d000000a900000a99a999a0000089a0000e8e00a99988889a000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000090000000aaaaaa0000089a000000000000888e8000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a00000000000e8e8000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc000000000000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc888888880000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc888888880000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc888888880000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc888888880000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc888888880000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc888888880000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc000000000000000000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccc88cccccc8cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccc888ccccc81cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccc11118888cccc811cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc1117111111cc8111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc1111111a11a8111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc111111a111a811accccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc11111111a1a811acccccccccccccc4ca4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc11111a11a8111cccccccccccc44444cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccc11aaaaaaaacc8111ccccccccccc4144ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccc88ccc888ccc811cccccccccccaaaa4cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccc8cccc88cccc81ccccccccccccccca4ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccc8ccccc8cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc111cccccecccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc1e1cccceeccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc1e1cc111111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc11e1c1117111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc11e11a11111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc11e11111111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc11e1a11111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc1e1ccaaaa111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc1e1ccceeccaaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccc111cccceccceccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ccccfcccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5cc5555cccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf5555155ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf5a555cccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf5555555ccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5cffcfccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc5ccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc9ac9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc99999cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccc9919cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc9aaaaccccccccccccccccccccccccccccccccccccc7ca7ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc9accccccccccccccccccccccccccccccccccccccc77777cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7177ccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaa7cccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccca7ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7ccccfccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cc7777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf7777177cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf7a777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf7777777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cffcfcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc1ca1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc11111cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc1111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccaaaa1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc3cccccccccccccccccccccccccccccccccca1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3ccccccccccccccc3cc
cc3bcccc3ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccccfccccc3bcccccccccccccc3bc
cc3bcccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1cc1111ccc3bccccccccc3cccc3bc
cc3bcccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf1111111cc3bccccccccc3bccc3bc
cccbcccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf1a111ccc3bccccccccc3bccc3bc
ccc3bccc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccf1111111cc3bccccccccc3bccc3bc
ccc3bccc3bccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1cffcfcccc3bccccccccc3bcc3cbc
ccc3bcc3cbcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1cccccccccc3bccccccccc3bcc3bcc
ccc3bcc3bcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccc3bcc3bcc
ccc3bcc3bcccccccc6ccccfcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccc3bcc3bcc
ccc3bcc3bccccccccc6cc6666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccccccc66666bcc
ccc3bcc3bcccccccccf6666166ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccccccc6666666cc
ccc3bcc3bccccccccccf6a666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccbccccccc666666666c
ccc3bcdddddcccccccf6666666cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccccc66666666666
ccccbdddddddcccccc6cffcfcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bcccc666666666666
ccccdddddddddcccc6cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc3bccc5556666666666
cccdddddddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdddcccccccc3bcc55555666666666
cccdddddddddddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdddddddcccccc3bc555555566666666
fffd555dddddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddffffff3bf555555566666666
fff55555ddddddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddfffff3bf555555566666666
ff5555555dddddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddfffff3bff5555566666666f
ff5555555ddddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddddfffff3bfff555f6666666ff
ff5555555dddfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddffffff3bffffffff66666fff
fff55555dddffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddddddffffff3bffffffffffffffff
ffff555ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffdddfffffffffbffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

__sfx__
010300000050216534005040e544025040d5540d0000f544005041c55400502005020050200502005020050200502005020050200402004020040200502005020050200502005020050200502005020050200502
00040000005071b5571b5571b55701507015070050712557125571255701507005070d5570d5570d5570450705507005070b5270b5370b5470a55707557065570555704557045570455703557035070350700507
011000000c5570c5470c53700000000000000000000000000c5570c5470c53700000000000000000000000000c5570c5470c53700000000000000000000000000c5570c5470c5370000000000000000000000000
011000001055710547105370000700007000070000700007105571054710537000070000700007000070000710557105471053700007000070000700007000071055710547105370000700007000070000700007
011000001355713547135370000000000000000000000000135571354713537000000000000000000000000013557135471353700000000000000000000000001355713547135370000000000000000000000000
011000000c5570c5470c53700000105500000013550000000c5570c5470c53700000105500000013550000000c5570c5470c53700000105500000013550000000c5570c5470c5370000010550000001355000000
__music__
00 02424344
00 03424344
00 04424344
00 05424344

