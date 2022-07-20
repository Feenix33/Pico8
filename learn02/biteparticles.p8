pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
--[[
from nerdyteachers.com
particles demo
]]--
-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====


-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====
function _init() --iiiiiii
  -- particles
  effects = {}

  -- effects settings
  trail_width = 1.5
  trail_colors = {12,13,1}
  trail_amount = 2

  fire_width = 3
  fire_colors = {8, 9, 10, 5}
  fire_amount = 3

  explode_size = 3
  explode_colors = {8,9,6,5}
  explode_amount = 5

  --sfx
  trail_sfx=0
  explode_sfx=1
  fire_sfx=2

  --player
  player = {x=53,y=53,r=2,c=7}

end

function add_fx(x,y,die,dx,dy,grav,grow,shrink,r,c_table)
  local fx={
    x=x, -- pos
    y=y, -- pos
    t=0, -- time for particle's lifetime
    die=die, -- how long to live
    dx=dx, -- change x
    dy=dy,
    grav=grav, -- bool apply gravity
    grow=grow, -- bool increase part sz
    shrink=shrink, -- bool decrease part sz
    r=r, -- rad for part
    c=0, -- current clr
    c_table=c_table -- color table
  }
  add(effects,fx)
end

function update_fx()
  for fx in all(effects) do
    -- lifetime
    fx.t +=1
    if fx.t>fx.die then del(effects,fx) end

    -- color 
    if fx.t/fx.die < 1/#fx.c_table then
      fx.c=fx.c_table[1]
    elseif fx.t/fx.die < 2/#fx.c_table then
      fx.c=fx.c_table[2]
    elseif fx.t/fx.die < 3/#fx.c_table then
      fx.c=fx.c_table[3]
    else
      fx.c=fx.c_table[4]
    end

    -- physics
    if fx.grav then fx.dy+=0.5 end
    if fx.grow then fx.r +=0.1 end
    if fx.shrink then fx.r -=0.1 end

    -- move
    fx.x += fx.dx
    fx.y += fx.dy
  end
end


function draw_fx()
  for fx in all(effects) do
    -- draw pixel for sz 1, draw circle otherwise
    if fx.r<=1 then
      pset(fx.x,fx.y,fx.c)
    else
      circfill(fx.x,fx.y,fx.r,fx.c)
    end
  end
end


-- motion trail effect
function trail(x,y,w,c_table,num)
  for i=0, num do
    -- settings
  --[[
  ]]--
    add_fx(
      x+rnd(w)-w/2, -- x
      y+rnd(w)-w/2, -- y
      40+rnd(30), -- die
      0, -- dx
      0, -- dy
      false, -- gravity
      false, -- grow
      false, -- shrink
      1, -- radius
      c_table -- clr tbl
    )
  end
end

-- explosion effect
function explode(x,y,r,c_tbl,num)
  for i=0, num do
    add_fx(
      x,
      y,
      30+rnd(20), -- die
      rnd(2)-1, -- dx
      rnd(2)-1, -- dy
      false, -- gravity
      false, -- grow
      true, -- shrink
      r, -- radius
      c_tbl -- color table
    )
  end
end

-- fire effect
function fire(x,y,w,c_tbl,num)
  for i=0, num do
    add_fx(
      x+rnd(w)-w/2, -- x
      y+rnd(w)-w/2,
      30+rnd(10), --die
      0, -- dx
      -0.5, -- dy
      false, -- gravity
      false, -- grow
      true, -- shrink
      2,  -- radius
      c_tbl -- color table
    )
  end
end

function _update60() --uuuuuuuu
  update_fx() 
  -- player controls
  if btn(0) then player.x -= 1 end
  if btn(1) then player.x += 1 end
  if btn(2) then player.y -= 1 end
  if btn(3) then player.y += 1 end

  if btnp(4) then 
    fire(player.x,player.y,fire_width,fire_colors,fire_amount) 
    sfx(fire_sfx)
  end
  if btnp(5) then
    explode(player.x,player.y,explode_size,explode_colors,explode_amount) 
    sfx(explode_sfx)
  end

  if btn(0) or btn(1) or btn(2) or btn(3) then
    trail(player.x, player.y, trail_width, trail_colors, trail_amount)
    sfx(trail_sfx)
  end
  --[[
  ]]--
end

function _draw() --dddddd
  cls()
  -- draw particles
  draw_fx()

  -- draw plyr
  circfill(player.x,player.y,player.r,player.c)
end

-- ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

__sfx__
01070000077111201108711130110872307713030120572300014027250071300725057030a7030a70006700077000a700057000370004700067000a700057000370000700007000070000700007000070000700
000300000361007220182300c64013630136300e630146300a6201562007020186200402002610030100161000010006100061000010006100061001610006100000000000000000000000000000000000000000
0002000009610076100c610046300d630076300d6200d620016200c6200b620066200a62009620096200162007610066100661005610016100161000610006100160000000000000000000000000000000000000
