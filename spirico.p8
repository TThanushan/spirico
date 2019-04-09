pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- spirico
-- by wombart
-- initially made for the minijam 25 :

local p_info = {x = 64, y = 64, tag = 'player', current_health = 0, move_speed = 1, sprites = {idle ={1, 2}, running = {17, 18, 18, 19, 20, 20}}, sounds = {running = 0}}
local player
local part = {}
local g = 0.3
local debugmode = true

local shkx, shky = 0, 0
local main_camera
local gameobjects = {}
local game_state = 'game'
local whiteframe = false
function _init()
    start()
end

function start()
    init_all_gameobject()
end

function _update60()
    if game_state == 'start' then

    elseif game_state == 'game' then
        update_game()
    elseif game_state == 'gameover' then

    end
end

function _draw()
    if game_state == 'start' then

    elseif game_state == 'game' then
        draw_game()
    elseif game_state == 'gameover' then
        
    end

    if (debugmode) then
        -- if (btn(5)) shake_v(1)
        -- print('time:'..flr(time()/2),main_camera.x-64, main_camera.y-64, 8, 2)
        -- print('e:'..spawner.alivee,main_camera.x-30, 30 +main_camera.y, 8, 2)

        -- print('mem_use:'..stat(0),main_camera.x+ 0, 30+main_camera.y, 8, 2)
        print('obj:'..#gameobjects, main_camera.x-20, main_camera.y+69, 10)
        print('cpu:'..stat(1),main_camera.x-20, main_camera.y+75, 12)
        print('fps:'..stat(7),main_camera.x-20, 81+main_camera.y, 11, 3)
        print('particles:'..#part,main_camera.x-20, 87+main_camera.y, 8, 2)
        -- print('particles:'..#part,main_camera.x+ 0, 93+main_camera.y, 8, 2)
        -- spe_print('sys_cpu:'..stat(2),main_camera.x+ 0, 50+main_camera.y, 8, 2)

        -- spe_print(main_camera.x, main_camera.x, main_camera.y, 8, 2)
        -- spe_print(main_camera.y, main_camera.x, main_camera.y, 8, 2)

    end

end
 
function update_game()
    update_all_gameobject()
    do_camera_shake()
    update_part()
    whiteframe_update()
end

function draw_game()

    cls()
    draw_part()
    draw_map()
    draw_all_gameobject()

    -- print(main_camera.get_tag())
end

function update_all_gameobject()
    for obj in all(gameobjects) do
        obj:update()
    end
end

function draw_all_gameobject()
    for obj in all(gameobjects) do
        obj:draw()
    end
end

function init_all_gameobject()
    make_player()
    main_camera = make_gameobject(32, 32, 'camera', {newposition = {x=0, y=0}})

    -- remove
    make_enemy(10, 0, 1, 2, 10, {running = {64, 65, 66, 65}})
end



function do_camera_shake()
    if abs(shkx)<0.1 then
        shkx=0
    else
        shkx*=-0.7-rnd(0.2)
    end

    if abs(shky)<0.1 then
        shky=0
    else
        shky*=-0.7-rnd(0.2)
    end
end
function draw_map()

  -- sky
  -- local x0, y0, x1, y1, col = -33, 0, 96, 10, 4
  -- rectfill(main_camera.x+shkx+x0, shky+y0, main_camera.x+shkx+x1, shky+y1, col)
  
  -- ground path
  x0, y0, x1, y1, col = -35, 72, 276, 90, 5
  rectfill(main_camera.x+shkx+x0, shky+y0, main_camera.x+shkx+x1, shky+y1, col)
end

function make_player()
    local _player = make_gameobject(p_info.x, p_info.y, p_info.tag, {
        current_health = p_info.current_health,
        c_sprite=1,
        dx=0,
        dy=1, 
        weapong_info = {reload_time = 0, bullet_sprite = 49, name = 'pistol', attack_speed = 0.5,
            move_speed = 10, damage = 1},
        state = 'idle',
        sfx_playing = false,
        look_to_left = true,
        grounded = true,
        timer = {walk_sfx_timer = 0},
        sounds = p_info.sounds,
        sprites = p_info.sprites,
        move_speed = p_info.move_speed,
        move = function(self)
            if btn(0) then
                self.x -= self.move_speed
                self.state = 'running'
                self.look_to_left = true 
                self:walk_particle()
            end
            if btn(1) then
                self.x += self.move_speed
                self.state = 'running'
                self.look_to_left = false
                self:walk_particle()
            end
            if btn(2) and self.grounded then
                self:jump()

            end
            if not btn(0) and not btn(1) then
                self.state = 'idle'
            end
            if btn(4) then
                self:shoot(self.x+60, self.y)
            end
        end,
        shoot = function(self, _x, _y)
            if self.weapong_info.reload_time < time() then
                self.weapong_info.reload_time = time()+self.weapong_info.attack_speed
                local direction = 1
                if self.look_to_left then direction = -1 end
                local bullet = make_bullet(self.x, self.y, {x=_x*direction, y=_y}, 1, 0, self.weapong_info.move_speed, self.weapong_info.bullet_sprite,
                    'bullet')
            
            end

        end,
        update_sprite = function(self)
            local table = self.sprites.idle
            local speed = 2

            if self.state == 'running' then 
                table = self.sprites.running
                speed = self.move_speed*6
            end

            local n = flr(time()*speed%#table)+1
            self.c_sprite = table[n]
        end,
        draw_sprite = function(self)
            spr(self.c_sprite, self.x+shkx, self.y+shky, 1, 1, self.look_to_left)
        end,
        player_sounds = function (self)
            if self.state == 'running' and self.grounded and self.timer.walk_sfx_timer < time() then
                sfx(3)
                self.timer.walk_sfx_timer = time() + 0.5
            end
        end,
        take_damage = function (self, damage)
            self.current_health -= damage
            sfx(4)
            whiteframe = true
        end,
        jump=function(self)
            self.grounded = false

            self.y -= 5
            self.dy = -4
            shake_v(1)
            sfx(0) 
            run_dust(self.x, self.y+13, 1)
            run_dust(self.x, self.y+13, -1)

        end,
        walk_particle = function(self)
            if rnd()>0.5 and self.grounded then dust_part(self.x+4, self.y+10, 3,{6, 5}) end

        end,
        do_physics=function(self)
            -- do gravity
            if self.y <= 64 then
                self.dy += g
            else 
                self.y = 64 
                self.dy = 0 
                if not self.grounded then
                    sfx(2)
                    self.grounded = true 
                end
            end
            self.y += self.dy

            -- do horizontal velocity
            self.x += self.dx
            if self.dx < 0.3 and self.dx > -0.3 then
                self.dx = 0
            elseif self.dx < 0 then
                self.dx += 0.8
            else 
                self.dx -= 0.8
            end

            if self.x > 120 then
                self.x = 120
            elseif self.x < 0 then
                self.x = 0 end
        end,
        update = function (self)
            self:player_sounds()
            self:move()
            self:update_sprite()
            self:do_physics()
        end,
        draw = function(self)
            self:draw_sprite()
        end

    })
    player = _player
end



function distance(current, target)
    return sqrt((target.x - current.x)^2 + (target.y - current.y)^2)
end

function closest_obj(target, tag)
  local dist=0
  local shortest_dist=32000
  local closest=nil

  for obj in all(gameobjects) do
      if(obj:get_tag() == tag) then
        dist = distance(target, obj)
        if(dist < shortest_dist) then
          closest = obj
          shortest_dist = dist
        end
      end

  end
  return closest
end


function make_enemy (x, y, damage, health, move_speed, sprites)
    local enemy = make_gameobject(x, y, 'enemy', {
        damage = damage,
        health = health,
        move_speed = move_speed,
        c_sprite = 0,
        sprites = sprites,
        attack_info = {range = 2, attack_speed = 1},
        target = player,

        enemy_collision_check = function (self)
            if distance(self, self.target) < self.attack_info.range then
                self:attack()
            end
        end,

        attack = function (self)
            self.target:take_damage(self.damage)
        end,
        move = function (self)
            move_toward(self, self.target, self.move_speed)
        end,
        take_damage = function (self, damage)
            self.current_health -= damage

        end,
        update_sprite = function(self)
            local table = self.sprites.idle
            local speed = 2

            table = self.sprites.running
            speed = self.move_speed*6

            local n = flr(time()*speed%#table)+1
            self.c_sprite = table[n]
        end,
        draw_sprite = function(self)
            spr(self.c_sprite, self.x+shkx, self.y+shky, 1, 1, self.look_to_left)
        end,
        update = function (self)
            self:update_sprite()
            self:move()
        end,
        draw = function (self)
            self:draw_sprite()
        end

    })

    add()
    return enemy
end

function whiteframe_update()
    if whiteframe == true then
        rectfill(-100,-100, 200, 200, 8)
        whiteframe = false
    end
end

-- ##bullet
function make_bullet(x, y, direction, damage, backoff, move_speed, sprite, tag)
  local bullet = make_gameobject (x, y, tag, {
    damage=damage,
    move_speed=move_speed,
    sprite=sprite,
    range = 1,
    backoff = backoff,
    direction=direction,
    out_of_screen = function (self)
        if (self.x < 8 or self.x > 118) or (self.y < 0 or self.y > 118) then
            self:destroy()
        end
    end,
    explode=function(self)
      hit_part(self.x, self.y,{7, 6, 5})
      sfx(1)
      -- if self.target:get_tag() !='player' then sfx(0) end
    end,
    destroy = function (self)
        self:explode()
        self:disable()
    end,
    enemy_collision_check = function (self)
        local enemy = closest_obj(self, 'enemy')

        if enemy != nil and distance(self, enemy) < self.range then
            enemy:take_damage(self.damage)
            -- enemy backoff
            move_toward(self.target, self, -self.backoff)

            self:destroy()
        end
    end,
    update=function(self)
        self:out_of_screen()
        self:enemy_collision_check()
        move_toward(self, self.direction, self.move_speed)

            -- backoff the target    
        -- move_toward(self.target, self, -self.backoff)
    end,
    draw=function(self)

      spr(self.sprite, self.x+shkx, self.y+shky)
      pal()
    end,
    reset=function(self)
      self:enable()

    end
  })
  
end

function closest_obj(target, tag)
  local dist=0
  local shortest_dist=32000
  local closest=nil

  for obj in all(gameobjects) do
      if(obj:get_tag() == tag) then
        dist = distance(target, obj)
        if(dist < shortest_dist) then
          closest = obj
          shortest_dist = dist
        end
      end

  end
  return closest
end



function move_toward(current, target, move_speed)
    if(move_speed == 0) then move_speed = 1 end

    local dist= distance(current, target)
    local direction_x = (target.x - current.x) / 60 * move_speed
    local direction_y = (target.y - current.y) / 60 * move_speed

    if(dist > 0) then
        current.x += direction_x / dist
        current.y += direction_y / dist
    end
    return current.x, y
end

function shake_camera(power)
    local shka=rnd(1)
    shkx+=power*cos(shka)
    shky+=power*sin(shka)
end

function shake_h(power)
    local shka=rnd(1)
    shkx+=power*cos(shka)
end

function shake_v(power)
    local shka=rnd(1)
    shky+=power*sin(shka)
end

function make_gameobject(x, y, tag, properties)

    local obj = {x = x, y = y, tag = tag, active = true, 
        get_tag = function(self)
            return self.tag
        end,
        disable = function(self)
            del(gameobjects, self)
        end,
        draw = function(self)

        end,
        update = function(self)

        end
    }
    if properties != nil then
        for k, v in pairs(properties) do
            obj[k] = v
        end
    end

    add(gameobjects, obj)
    return obj
end

-- ##part
function add_part(x, y ,tpe, size, mage, dx, dy, colarr)

 local p = {
  x=x,
  y=y,
  tpe=tpe,
  dx=dx,
  dy=dy,
  move_speed=0,
  size=size,
  age=0,
  mage=mage,
  col=col,
  colarr=colarr,
  layer=0

 }

 add(part, p)
 return p
end

function draw_part()
    local part = part
    for p in all(part) do
        if p.tpe==0 then
            pset(p.x+shkx, p.y+shky, p.col)
        elseif p.tpe==1 then
            circfill(p.x+shkx,p.y+shky,p.size, p.col)
            p.size -= 0.1
        end
    end
end

function update_part()
    local part = part
    for p in all(part) do
        p.age+=1
        if p.mage != 0 and p.age >= p.mage or (p.size <= 0 and p.mage!=0) then
            del(part, p)
        end

        -- if p.colarr == nil then return end
        if #p.colarr == 1 then
            p.col = p.colarr[1]
        else
            local ci = p.age/p.mage
            ci = 1+flr(ci*#p.colarr)
            p.col = p.colarr[ci]
        end
        p.x+=p.dx
        p.y+=p.dy
    end
end

function dust_part(x, y, size, colarr)  
    add_part(rnd(5)-rnd(5)+x, rnd(5)-rnd(5)+y, 1, rnd(size)+size-1, rnd(5)+35, (rnd(10)-rnd(10))/30, (rnd(10)-rnd(10))/30, colarr)
end

function hit_part(x, y, colarr) 
    add_part(rnd(5)-rnd(5)+x, rnd(5)-rnd(5)+y, 1, rnd(1)+4-1, rnd(5)+35, (rnd(10)-rnd(10))/30, (rnd(10)-rnd(10))/30, colarr)
end

function run_dust(x, y, _dir)
 for i=0, rnd(6)+4 do
  local p add_part(rnd(5)-rnd(5)+x, rnd(5)-rnd(5)+y, 1, rnd(4)+2 -1, rnd(5)+35, (-rnd(40)/60)*_dir, (-rnd(20))/60, {7,6,5})
 end
end
__gfx__
00000000000000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009900000599900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700059990005544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005544000055bb777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700055bb777055b3667700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070055b366775636000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000566600000363000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000030300000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099000000000000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009900000599900000990000059990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000059990005544000005999000554400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005544000055bb77705544000055bb77700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055bb777055b3667755bb777055b366770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055b366775666300055b36677566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000566600000030000056660000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000030300000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000099000000990000009900000099000000990000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009900000599900005999000059990000599900005999000000000000000000000000000000000000000000000000000000000000000000000000000
00000000059990005544000055440000554400005544000055440000000000000000000000000000000000000000000000000000000000000000000000000000
000000005544000055bb000055bb000055bb777055bb000055bb0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055bb777055b3700055b3700055b3667755b3700055b37000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055b366775666670056666700566600005666670056666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000566600000033067000330670003300000033067000330670000000000000000000000000000000000000000000000000000000000000000000000000
00000000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007777000777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007777000777777007c7c77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777777007c7c7700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07c7c770077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000067200b7200f72014720187001a70020700247002c7002d70000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00010000006003163029620226101c010120100600000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000000000000010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000021200010004100001000810000100001000b110001000b10000100001000010006100001000010000100001000010033100001000410001100061000010000100001000010000100001000b1000f100
0001000000000000000000000000000002e6102701020010160100101001010010100101001010010100101000000000000000000000000000000000000000000000000000000000000000000000000000000000
