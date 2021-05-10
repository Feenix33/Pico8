pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- Learn 10 = stepr
-- Have a timer run through a simulation
--
-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
-- screen size = 128x128

-- globals
-- blocks
-- m=margin w=width h=height n=count c=color
gblk={m=6, w=24, h=66,n=4, c=5}
est={empty=1,fill=2}
--estate={mv=1,add=2,del=3,car=4,sz=4}

gdex = 1
pour_amount = 2
delay=0

gn=1
tanks={}

function add_tank()
    add(tanks, {
        id=#tanks+1,
        cap=20, --capacity for filling
        st=est.empty,
        dump=function(self)
            printh(self.id.." = "..self.x1.." "..self.x2.." "..self.y1.." "..self.y2)
            --printh("+--- xxyy="..self.x1..","..self.y1)
            --printh("+--- xy2="..self.x2..","..self.y2)
            --[[
            fx1=self.x1+1
            fx2=self.x2-1
            fy2=self.y2-1
            depth = (self.y2-self.y1-2)*self.cap/100
            fy1=fy2-depth
            printh(  "  + "..fx1.." "..fx2.." "..fy1.." "..fy2.." "..depth.." "..self.cap)
            ]]--
        end,
        set_dim=function(self, _w, _h, _m)
            nrow = flr(128/(_w+_m))
            self.x1 = _m + ((self.id-1) % nrow) * (_w+_m)
            self.y1 = _m + (_m+_h)*flr((self.id-1) / nrow)
            self.x2 = self.x1+_w
            self.y2 = self.y1+_h
        end,
        draw=function(self)
            depth = self.cap*(self.y2-self.y1) / 100
            fy1=self.y2-depth
            if (fy1 < self.y1) then fy1=self.y1 end
            rectfill(self.x1, fy1, self.x2, self.y2,10)--gblk.c)
            rect(self.x1, self.y1, self.x2,self.y2,gblk.c)
        end,
        pour=function(self)
            self.cap = min(self.cap+pour_amount, 100)
        end,
        oldpour=function(self)
            if self.cap < 100 then
                self.cap += pour_amount
            end
            if self.cap >= 100 then
                self.st=est.fill
                return true
            end
            return false
        end,
        is_full=function(self)
            return self.cap >= 100
        end,
        fill=function(self)
            self.st=est.fill
        end,
        drain=function(self,amt)
            amt = amt or 10
            self.cap = max(self.cap-amt, 0)
        end
    })
end


--
-- base functions
-- 

function _init()
    -- print a runtime note
    printh (stat(93)..":"..stat(94).." ---------------------------------------- ")
    for n=1,gblk.n do
        add_tank()
    end
    for t in all(tanks) do
        t:set_dim(gblk.w, gblk.h, gblk.m)
    end
    gdex=1
end

function _update()
    delay += 1
    if (delay % 10)==0 then
        tanks[gdex]:pour()
        if tanks[gdex]:is_full() then
            gdex = (gdex % #tanks) + 1
        end
    end
    if (delay % 20)==0 then
        n =flr(rnd(gblk.n)) + 1
        amt=flr(rnd(10))+1
        tanks[n]:drain(amt)
    end

    if btnp(4) then
        --[[
        if tanks[gdex]:pour() then
            gdex = (gdex % #tanks) + 1
            printh("gdex="..gdex)
        end
        ]]--

    elseif btnp(5) then
        printh("Btn 5")
        for t in all(tanks) do
            t:dump()
        end
    end
end

function _draw()
    cls()
    rect(0, 0, 127, 127, 6)
    for t in all(tanks) do
        t:draw()
    end
end

