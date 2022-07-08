pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
bite size game cells
from nerdyteachers.com
]]--
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

function circ_collide(x1,y1,r1, x2,y2,r2)
  distsq = (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
  rsumsq = (r1+r2)*(r1+r2)

  if distsq == rsumsq then
    -- circles touch
    return false
  elseif distsq>rsumsq then
    -- no touch
    return false
  end
  -- overlap
  return true
end

function create_enemies()
  if #enemies < max_enemies then
    -- local vars
    local x=0 -- pos
    local y=0
    local dx=0
    local dy=0 -- momemntum
    local r=flr(rnd((max_enemy_size+player.r-1)/2))+1 --size

    -- rand start pos
    place = flr(rnd(4))
    if place == 0 then
      --left
      x=flr(rnd(8)-16)
      y = flr(rnd(128))
      dx = rnd(enemy_speed)
      dy = rnd(enemy_speed*2) - enemy_speed
    elseif place==1 then
      --right
      x=flr(rnd(8) +128)
      y = flr(rnd(128))
      dx = -rnd(enemy_speed) - enemy_speed
      dy = rnd(enemy_speed*2) - enemy_speed
    elseif place==2 then
      --top
      x=flr(rnd(128))
      y = flr(rnd(8)-16)
      dx = rnd(enemy_speed*2) - enemy_speed
      dy = rnd(enemy_speed)
    else --if place==3 then
      --bottom
      x=flr(rnd(128))
      y = flr(rnd(8) + 128)
      dx = rnd(enemy_speed*2) - enemy_speed
      dy = rnd(enemy_speed) - enemy_speed
    end

    -- sz determines color
    if r==1 then
      c=_yellow c2=_orange
    elseif r==2 then
      c=_grey c2=_white
    elseif r==3 then
      c=_orange c2=_brown
    elseif r==4 then
      c=_pink c2=_brown
    elseif r==5 then
      c=_purple c2=_dkblue
    elseif r==6 then
      c=_red c2=_purple
    elseif r==7 then
      c=_white c2=_grey
    elseif r==8 then
      c=_blue c2=_dkblue
    elseif r==9 then
      c=_dkblue c2=_blue
    elseif r==10 then
      c=_dkgreen c2=_green
    else
      c=_red c2=_blue
    end

    -- make enemy table
    local enemy = {
      x = x,
      y = y,
      dx = dx,
      dy=dy,
      r=r,
      c=c,
      c2=c2,
    }
    add (enemies,enemy)
  end
end

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
    c = _green, -- inner circle color
    c2 = _dkgreen, -- outer circle color
    r = 3, -- radius
    dx = 0, -- delta x for x axis momentum 
    dy = 0,
    speed = 0.08, --0.08, -- number for how much the player's cell should speed up by
    eat = 0, -- how many enemies were eaten for scoring
  }
  -- game settings
  enemies = {} -- enemy table
  max_enemies = 15 -- max enemies
  max_enemies = 10 -- xxxx max enemies
  max_enemy_size = 10 -- number of pixels for largest enemy radius
  enemy_speed = 0.6 -- avg speed of enemies
  win_amount = 500 -- how many to eat to win
end

function _update() --uuuuuuuu

  -- player controls
  if btnp(⬅️) then player.dx -= player.speed end
  if btnp(➡️) then player.dx += player.speed end
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
  if player.y > 127 then player.y = 1 end
  if player.y < 0 then player.y = 126 end

  -- enemy update
  create_enemies()
  for enemy in all (enemies) do
    -- move
    enemy.x += enemy.dx
    enemy.y += enemy.dy

    -- ouside screen
    if enemy.x > 137
      or enemy.x < -10
      or enemy.y < -10
      or enemy.y > 137 then
      del(enemies, enemy)
    end

    -- collide w/player
    if circ_collide(
      player.x, player.y, player.r,
      enemy.x, enemy.y, enemy.r
      ) then
      -- compare size
      if (flr(player.r) > enemy.r) then
        player.eat += 1
        player.r += .2
        sfx(0)
        del (enemies, enemy)
      else
        sfx(1)
        _init()
      end
    end
  end

end

function _draw() --dddddd
  cls()

  -- player
  circfill(player.x, player.y, player.r, player.c)
  circ(player.x, player.y, player.r+1, player.c2)

  -- enemies
  for enemy in all(enemies) do
    circfill(enemy.x, enemy.y, enemy.r, enemy.c)
    circ(enemy.x, enemy.y, enemy.r+1, enemy.c2)
  end

  -- score
  rectfill(0, 3, 20, 10, _black)
  print(".="..player.eat, 0, 5, _white)

  -- win
  if player.eat > win_amount then
    rectill(0, 55, 127, 75, _dkgrey)
    print("congratulations!!!", 28, 56, _blue)
    print("you became", 43, 63, _blue)
    print("a multicelled organsim", 20, 70, _blue)
  end
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
-- collection of support functions
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function log(_lvl, _msg, _ind) local ind=_ind or '' if _lvl < 5 then printh(ind.._msg) end end
function irand(n) return ceil(rnd(n)) end -- rand in [1..n]
function irand0(n) if (n==0) then return 0 else return ceil(rnd(n))-1 end end -- rand in [0..n)
function tblstr(_t) out="" for j=1,#_t-1 do out=out.._t[j].."," end return out.._t[#_t] end
function shuffle(t) for i=#t,1,-1 do local j=flr(rnd(i))+1 t[i],t[j] = t[j],t[i] end end
function contains(_tbl,_el) for _ in all(_tbl) do if _==_el then return true end end return false end

__sfx__
000300001755013550115501055011550165501a5501b550205502255000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000000026550265502755027550265501e5501a550125501255013550135501355013550125500f5500d5500d5500c55009550045500255001550005500000000000000000000000000000000000000000
