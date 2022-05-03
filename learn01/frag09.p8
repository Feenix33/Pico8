pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- Learn 08 A Defrag Simulation based on Cart 49823
-- base
-- 0=black  1=dk blue  2=purple   3=dk green
-- 4=brown  5=dk grey  6=lgrey    7=white
-- 8=red    9=orange   10=yellow  11=lgreen
-- 12=lblue 13=mgrey   14=pink    15=peach
--

-- global graphic control
gblk={margin=4, ystart=10, width=3, height=5, space=2, newline=120, size=20}
bloxs = {}
bt={mt=0,a=8} -- box types
modev={tgt=1,mt=2,swap=3}
mode = modev.tgt

-- global location tracking
doneat = 1
tgtat = 0
mtat = 0

function find_tgt()
    -- find a target to move
    tgtat = doneat + 1
    while bloxs[tgtat] == bt.mt do
        tgtat += 1
        if tgtat > #bloxs then
            printh("At end")
            tgtat = -1
            return
        end
    end
end

function find_empty()
    mtat = doneat
    printh("mtat="..mtat)
    while bloxs[mtat] != bt.mt do
        mtat+=1
    end
    printh("mtat="..mtat)
end

function init_bloxs()
    for j = 1,gblk.size do
        t = flr(rnd(8)) + 1
        if rnd(100) < 25 then t=bt.a else t=bt.mt end
        add (bloxs, t)
    end
end

function swap_bloxs()
    if tgtat == -1 then return end
    local temp
    bloxs[mtat] = bloxs[tgtat]
    bloxs[tgtat] = bt.mt
    doneat = mtat
end

function draw_bloxs()
    x = gblk.margin
    y = gblk.ystart
    for blox in all(bloxs) do
        rectfill(x, y, x+gblk.width, y+gblk.height, blox)
        if blox == 0 then
            rect(x, y, x+gblk.width, y+gblk.height, 7)
        end

        x += gblk.width 
        x += gblk.space
        if x >= gblk.newline then
            x = gblk.margin
            y += (gblk.height+gblk.space)
        end
    end
    -- draw a box around magic tiles
    if tgtat > 0 then
        n = tgtat
        x = gblk.margin + ((((n-1) % bloxperrow)) * (gblk.width+gblk.space))
        y = gblk.ystart + (flr((n-1) / bloxperrow) * (gblk.height+gblk.space))
        rect(x, y, x+gblk.width, y+gblk.height, 9)
    end
    if mtat != 0 then
        n = mtat
        x = gblk.margin + ((((n-1) % bloxperrow)) * (gblk.width+gblk.space))
        y = gblk.ystart + (flr((n-1) / bloxperrow) * (gblk.height+gblk.space))
        line(x, y, x+gblk.width, y+gblk.height, 9)
    end
end

--
-- base functions
-- 

function _init()
    -- print a runtime note
    printh (stat(93)..":"..stat(94).." ---------------------------------------- ")
    init_bloxs()
    bloxperrow = flr((128 - (gblk.margin*2)) / (gblk.width+gblk.space))
    doneat = 1
mode = modev.tgt
end

function _update()
    if btnp(4) then
        if mode == modev.tgt then
            printh("find tgt")
            find_tgt()
            mode = modev.mt
        elseif mode == modev.mt then
            printh("find empty")
            find_empty()
            mode = modev.swap
        elseif mode == modev.swap then
            printh("swap")
            swap_bloxs()
            mode = modev.tgt
        end

    elseif btnp(5) then
        printh("Btn 5")
    end
end

function _draw()
    cls()
    rect(0, 0, 127, 127, 6)
    draw_bloxs()
end

