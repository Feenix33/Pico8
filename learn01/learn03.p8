pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- learn how to do arrays of objects
-- simple collision detection

ncount = 1

function new_moth(x, y)
   local moth = {}
   moth.n = ncount
   ncount += 1
   moth.dead = false
   moth.x = x%128
   moth.y = y%128
   moth.v = flr(rnd(3)) + 1
   moth.c = flr(rnd(15)) + 1
   moth.draw = function(this)
       if this.dead then return end
       if pget(this.x, this.y) != 0 then
           printh(this.n, "learn03")
           this.dead = true
           return true
       end
       pset(this.x, this.y, this.c)
       return false
       end
   moth.update = function(this)
       if this.dead then return end
       this.x = (this.x + flr(rnd(3)) - 1) % 128
       this.y = (this.y + flr(rnd(3)) - 1) % 128
       end
   return moth
end


moth_array = {}
moth_count = 100

function _init()
   cls()
   for n=1,moth_count do
       x = flr(rnd(120)) + 4
       y = flr(rnd(120)) + 4
       add(moth_array, new_moth(x,y))
   end
   -- printh("init", "learn03")
end

function _update() 
    for obj in all(moth_array) do
       obj.update(obj)
    end
end

function _draw()
    cls()
    for obj in all(moth_array) do
       if obj.draw(obj) then
           del(moth_array, obj)
       end
    end
    print(#moth_array, 0, 0, 3)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
