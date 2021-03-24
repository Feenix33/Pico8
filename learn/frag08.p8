pico-8 cartridge // http://www.pico-8.com
version 29
-- Learn 08 A Defrag Simulation based on Cart 49823
__lua__
-- base
-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
--
--

-- state
mode={wait=1, seek=2, block=3, empty=4, swap=5, next=6, done=7}

-- sector globals constants
sectw = 3
secth = 6
sects = {}

-- defrag globals
dfat = 1 --where we are in the clean up
dfmax = 1 --end of the sectors
dfblock = 1 -- index of a block
--dftargets = {0, 8, 9, 10}
dftargets = {0, 0, 8, 10}
dftgtdex = 2
dftgt = 8 --what color blocks we are cleaning
dfempty = 0

function find_start()
    dfat = 1
    while sects[dfat] != dftgt do
        dfat += 1
    end
    printh ("dfat = "..dfat)
end

function opseek()
    if sects[dfat] == dfempty then
        -- find a block
        opstate = mode.block
    else
        -- find empty
        opstate = mode.empty
    end
end

function opblock() -- operation find a block
    dfblock = dfat
    while dfblock <= dfmax do
        if sects[dfblock] == dftgt then
            opstate = mode.swap
            return
        else
            dfblock += 1
        end
    end
    opstate = mode.next
end

function opempty_orig() -- find an empty
    dfblock = dfat
    while dfblock <= dfmax do
        if sects[dfblock] == dfempty then
            opstate = mode.swap
            return
        else
            dfblock += 1
        end
    end
end

function opempty() -- find a no match
    dfblock = dfat
    while dfblock <= dfmax do
        if sects[dfblock] != dftgt then
            opstate = mode.swap
            return
        else
            dfblock += 1
        end
    end
end

function opswap()
    local tempvalue
    tempvalue = sects[dfat]
    sects[dfat] = sects[dfblock]
    sects[dfblock] = tempvalue
    opstate = mode.seek
    dfat += 1
end

function opnext()
    dftgtdex += 1
    if dftgtdex > #dftargets then
        opstate = mode.done
    else
        dftgt = dftargets[dftgtdex]
    end
end

function init_sects(n)
    dfmax = n
    for j = 1,n do
        t = flr(rnd(#dftargets)) + 1
        add (sects, dftargets[t])
    end
end

function _init()
    printh (stat(93)..":"..stat(94).." ---------------------------------------- ")
    ---      01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20
    --sects = { 0, 8, 0, 0, 8, 0, 8, 8, 0, 0, 8, 0, 0, 0, 0, 0, 8, 0, 0, 0}
    init_sects(40)
    dfat = 1
    opstate = mode.seek
    dfmax = #sects
    find_start()
    dftgtdex = 1
    while dftargets[dftgtdex] == dfempty do dftgtdex += 1 end
    dftgt = dftargets[dftgtdex]
end

function _update()
    if btnp(4) then
        if opstate == mode.seek then
            --printh("seeking")
            opseek()
        elseif opstate == mode.block then
            --printh("find block")
            opblock()
        elseif opstate == mode.empty then
            --printh("find empty")
            opempty()
        elseif opstate == mode.swap then
            --printh("swapping")
            opswap()
        elseif opstate == mode.next then
            printh("next")
            opnext()
        elseif opstate == mode.done then
            printh("done")
        end
    elseif btnp(5) then
        printh("target  ="..dftgt)
    end
end

function _draw()
    cls()
    rect(0, 0, 127, 127, 6)
    draw_sects()
end

function draw_sects()
    x = 4
    y = 20
    for sect in all(sects) do
        rectfill(x, y, x+sectw, y+secth, sect)
        if sect == 0 then
            rect(x, y, x+sectw, y+secth, 7)
        end
        x += (sectw+2)
        if x >= 124 then
            x = 4
            y += (secth+2)
        end
    end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
