pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- spirico
-- by wombart
-- initially made for the minijam:

local p_info = {x = 64, y = 64, tag = 'player', max_health = 3, move_speed = 2, 
sprites = {idle ={1, 2}, running = {17, 18, 18, 19, 20, 20}}, sounds = {running = 0}}
local player
local part = {}
local g = 0.3
local debugmode = false
local ground_y = 64
local shkx, shky = 0, 0
local main_camera
local gameobjects = {}
local game_state = 'game'
local whiteframe = false
local spawner
local platform_button1


local colors = {black = 0, dark_blue = 1, dark_purple = 2, dark_green = 3,
    brown = 4, dark_gray = 5, light_gray = 6, white = 7, red = 8, orange = 9,
    yellow = 10, green = 11, blue = 12, indigo = 13, pink = 14, peach = 15, no_color}

local ground_bridge = {x0 = -35, y0 = 65, x1 = 276, y1 = 95, width = 15, 
    height = 10, light_color = colors.white, dark_color = colors.light_gray}

local platform1 = {x0=10, y0=45, x1=40, y1=53, hitbox_x0=4, hitbox_x1=40, 
    hitboxy=40, light_color = colors.white, dark_color = colors.light_gray}
local platform2 = {x0=90, y0=45, x1=110, y1=53, hitbox_x0=86, hitbox_x1=110, 
    hitboxy=40, light_color = colors.white, dark_color = colors.light_gray}

local spawner_infos = {x=0, y=0, tag='spawner', 
    properties={x={-30, 135, -30, 135},
    y={-30, -30, 64, 64}, wave_number=1, inprogress_timer=0, inprogress_time=1, 
    between_spawn_timer=0, between_spawn_time=5, enemy_count=0, 
    enemy_number_to_spawn=5, alivee=0, enemy_limit = 20}}

local enemies_shape = {
    {damage = 1, health = 2, move_speed = 20, 
        sprites = {running = {64, 65, 66, 67}}, flying = false},
    {damage = 1, health = 3, move_speed = 10, 
        sprites = {running = {80, 81, 82, 83}}, flying = false},
    {damage = 1, health = 2, move_speed = 15, 
        sprites = {running = {96, 97, 98, 99}}, flying = true}
}



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
        -- if btnp(5) then spawner.wave_number += 1 end
        if btnp(5) then platform_button1.level += 1 end
        -- if (btn(5)) shake_v(1)
        -- print('time:'..flr(get_time()/2),main_camera.x-64, main_camera.y-64, 8, 2)
        -- print('e:'..spawner.alivee,main_camera.x-30, 30 +main_camera.y, 8, 2)

        -- print('mem_use:'..stat(0),main_camera.x+ 0, 30+main_camera.y, 8, 2)
        print('obj:'..#gameobjects, main_camera.x-20, main_camera.y+69, 10)
        print('cpu:'..stat(1),main_camera.x-20, main_camera.y+75, 12)
        print('fps:'..stat(7),main_camera.x-20, 81+main_camera.y, 11, 3)
        print('player x :'..flr(player.x)..' y '..flr(player.y), main_camera.x+10, 81+main_camera.y, 11, 3)
        print('particles:'..#part,main_camera.x-20, 87+main_camera.y, 8, 2)

        -- print("ecount "..spawner.enemy_count,  50, 30,8, 2)
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

    spawn_random_enemies()
end

function draw_game()

    cls((spawner.wave_number%15)+1)
    -- cls(((get_time()/2%15))+1)

    draw_map()
    draw_part()
    draw_all_gameobject()
    draw_interface()
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

    player:draw()
end


function get_time()
    return time()/2
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

  -- outline 
    rect(shkx+ground_bridge.x0-1, shky+ground_bridge.y0-1,
        shkx+ground_bridge.x1+1, shky+ground_bridge.y1+ground_bridge.height+1, 
        colors.black)

    -- light part
    rectfill(shkx+ground_bridge.x0,shky+ground_bridge.y0,shkx+ground_bridge.x1,
        shky+ground_bridge.y0+ground_bridge.width, ground_bridge.light_color)

    -- dark part
    rectfill(shkx+ground_bridge.x0, shky+ground_bridge.y0+ground_bridge.width,
        shkx+ground_bridge.x1,shky+ground_bridge.y1+ground_bridge.height, ground_bridge.dark_color)


    -- platform 1
    rect(shkx+platform1.x0-1, shky+platform1.y0-1, shkx+platform1.x1+1,
        shky+platform1.y1+1, colors.black)

    -- light part
    rectfill(shkx+platform1.x0, shky+platform1.y0, shkx+platform1.x1,
        shky+platform1.y1, platform1.light_color)

    -- dark part
    rectfill(shkx+platform1.x0, shky+platform1.y0+5, shkx+platform1.x1,
        shky+platform1.y1, platform1.dark_color)

    -- platform 2
    rect(shkx+platform2.x0-1, shky+platform2.y0-1, shkx+platform2.x1+1,
        shky+platform2.y1+1, colors.black)

    -- light part
    rectfill(shkx+platform2.x0, shky+platform2.y0, shkx+platform2.x1,
        shky+platform2.y1, platform2.light_color)

    -- dark part
    rectfill(shkx+platform2.x0, shky+platform2.y0+5, shkx+platform2.x1,
        shky+platform2.y1, platform2.dark_color)

end

function draw_next_wave_rect_timer()
    if get_time() -spawner.between_spawn_timer < 0 then
        
        local height, width = 1, 10
        local x, y = 55, 13
        local pourcentage_fill = ((get_time()-spawner.between_spawn_timer)+spawner.between_spawn_time)/spawner.between_spawn_time

        draw_filled_rect(x, y, width, height, pourcentage_fill, colors.green, colors.black)
        -- function draw_filled_rect(x0,y0,x1,y1, pc, back_col, font_col, bordercol)

    end
end

function draw_interface()
    draw_next_wave_rect_timer()
    spe_print("wave "..spawner.wave_number,  50, 4, colors.red, colors.dark_purple)

end

-- ##spawner
function spawn_random_enemies()
    -- is the between timer over
    if spawner.between_spawn_timer < get_time() then
        
        -- choose a random spawn position
        

        local shape = enemies_shape[flr(rnd(count(enemies_shape))+1)]

        local rand_index_pos = flr(rnd(count(spawner.x)))+1
        
        -- haven't reached the number of enemies to spawn this wave
        if spawner.enemy_count < spawner.enemy_number_to_spawn then

            if spawner.inprogress_timer < get_time() then

                    local enemy = make_enemy(spawner.x[rand_index_pos], spawner.y[rand_index_pos], shape.damage,
                     shape.health, shape.move_speed, shape.sprites, shape.flying)
                    -- temporary solution

                    if not enemy.flying then
                        enemy.y = 64
                    end
                    spawner.inprogress_timer = spawner.inprogress_time + get_time()
                    
                    spawner.alivee += 1
                    spawner.enemy_count += 1;
            end
        elseif spawner.alivee <= 0 then
            spawner.between_spawn_timer = spawner.between_spawn_time + get_time()
            spawner.enemy_count = 0 
            spawner.wave_number += 1
        end
        

    end
end

function is_player_on_a_platform()
    return (player.x >= platform1.hitbox_x0 and player.x <= platform1.hitbox_x1 and (player.y > platform1.hitboxy-3 and player.y < platform1.hitboxy+3)) or
    (player.x > platform2.hitbox_x0 and player.x < platform2.hitbox_x1 and (player.y > platform2.hitboxy-3 and player.y < platform2.hitboxy+3))
end

-- ##player
function make_player()
    player = make_gameobject(p_info.x, p_info.y, p_info.tag, {
        current_health = p_info.max_health,
        max_health = p_info.max_health,
        c_sprite=1,
        dx=0,
        dy=1, 
        level = 1,
        weapong_info = {reload_time = 0, bullet_sprite = 49, name = 'pistol', attack_speed = 0.5,
            move_speed = 400, damage = 1, backoff = 1, collision_backoff = 10},
        state = 'idle',
        sfx_playing = false,
        look_to_left = true,
        grounded = true,
        timer = {walk_sfx_timer = 0},
        sounds = p_info.sounds,
        sprites = p_info.sprites,
        experience=0,
        money=0,
        move_speed = p_info.move_speed,
        move = function(self)
            if btn(0) then
                self.x -= self.move_speed
                self.state = 'running'
                if not btn(4) then
                    self.look_to_left = true 
                end
                self:walk_particle()
            end
            if btn(1) then
                self.x += self.move_speed
                self.state = 'running'
                if not btn(4) then
                    self.look_to_left = false
                end
                self:walk_particle()
            end
            -- need to be falling to jump 
            if btn(2) and self.grounded and self.dy >= 0 then
                self:jump()

            end
            if not btn(0) and not btn(1) then
                self.state = 'idle'
            end
            if btn(4) then
                self:shoot(self.x+200, self.y)
            end
        end,
        shoot = function(self, _x, _y)
            if self.weapong_info.reload_time < get_time() then
                sfx(9)
                self.weapong_info.reload_time = get_time()+self.weapong_info.attack_speed
                local direction = 1
                if self.look_to_left then direction = -1 end
                self.x += self.weapong_info.backoff * -direction
                
                local bullet = make_bullet(
                    self.x,
                    self.y,
                    {x=_x*direction, y=_y},
                    self.weapong_info.damage,
                    self.weapong_info.collision_backoff,
                    self.weapong_info.move_speed,
                    self.weapong_info.bullet_sprite,
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

            local n = flr(get_time()*speed%#table)+1
            self.c_sprite = table[n]
        end,
        draw_money = function(self)
            spe_print('$'..self.money, self.x, self.y-15, colors.green, colors.dark_green)
        end,
        draw_sprite = function(self)
            outline_spr(self.c_sprite, self.x+shkx, self.y+shky, self.look_to_left)
            spr(self.c_sprite, self.x+shkx, self.y+shky, 1, 1, self.look_to_left)
        end,
        player_sounds = function (self)
            if self.state == 'running' and self.grounded and self.timer.walk_sfx_timer < get_time() then
                sfx(3)
                self.timer.walk_sfx_timer = get_time() + 0.25
            end
        end,
        take_damage = function (self, damage)
            self.current_health -= damage
            if self.current_health < 0 then
                self.current_health = 0
            end
            sfx(5)
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
            if self.y > ground_y then
                self.y = ground_y
                self.grounded = true 
                self.dy = 0 

            end
            -- do gravity
            if self.y <= ground_y and not is_player_on_a_platform() then
                self.dy += g
            else
                if not self.grounded then
                    sfx(2)
                end
                    if self.dy > 0 and is_player_on_a_platform() then
                        self.grounded = true 
                        self.dy = 0 
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
        draw_health_rect = function (self)
            local percentage = self.current_health/self.max_health
            draw_filled_rect(self.x, self.y-4, 7, 1, percentage, colors.green, colors.black)
        end,
        update = function (self)
            self:player_sounds()
            self:move()
            self:update_sprite()
            self:do_physics()
        end,
        draw = function(self)
            self:draw_sprite()
            self:draw_health_rect()
            self:draw_money()
        end

    })
end

function is_player_in_this_area(x0, y0, x1, y1)
    local px, py = player.x, player.y
    return px >= x0 and px <= x1 and py >= y0 and py <= y1
end

function is_any_button_pressed()
    return btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5) 
end

function init_all_gameobject()
    make_player()
    main_camera = make_gameobject(32, 32, 'camera', {newposition = {x=0, y=0}})

    spawner = make_gameobject(spawner_infos.x, spawner_infos.y, spawner_infos.tag, {
        x = spawner_infos.properties.x, 
        y = spawner_infos.properties.y, 
        enemy_count = spawner_infos.properties.enemy_count,
        enemy_number_to_spawn = spawner_infos.properties.enemy_number_to_spawn,
        wave_number = spawner_infos.properties.wave_number, 
        inprogress_timer = spawner_infos.properties.inprogress_timer,
        inprogress_time = spawner_infos.properties.inprogress_time,
        between_spawn_timer = spawner_infos.properties.between_spawn_timer,
        between_spawn_time = spawner_infos.properties.between_spawn_time,
        alivee = spawner_infos.properties.alivee,

    })

-- ##current

    
    platform_button1 = make_platform_button(10, ground_bridge.y0, 
        "platform_button_attack", 25, ground_bridge.width, colors.orange, 
        colors.brown, 7, {5, 10, 15}, function() 
        player.weapong_info.damage += 0.25 
        player.weapong_info.attack_speed /= 1.15 end)
    -- make_platform_button(x, y, tag, width, height, col, costs, upgrade)

    
    platform_button1 = make_platform_button(50, ground_bridge.y0, 
        "platform_button_defense", 25, ground_bridge.width, colors.blue, 
        colors.dark_blue, 8, {5, 10, 15}, function() 
        player.max_health += 1
        player.current_health = player.max_health 
        end)

end

-- ##platform_button
function make_platform_button(x, y, tag, width, height, light_color, dark_color, 
    sprite, costs, upgrade)
    
    local platform_button = make_gameobject(x, y, tag, {
        width = width,
        height = height,
        costs = costs,
        upgrade = upgrade,
        level = 1,
        light_color = light_color,
        dark_color = dark_color,
        cursor_color = dark_color,
        sprite = sprite,
        pressed_timer=0,
        seconds_to_buy=3,
        second_surface_height = 10,
        draw_button_rect = function(self)
            rectfill(self.x, self.y, self.x+self.width, self.y+self.height, self.light_color)

            rectfill(self.x, self.y+height, self.x+self.width, self.y+self.height+10, self.dark_color)

            rect(self.x, self.y-1, self.x+self.width, self.y+self.height+self.second_surface_height, colors.black)

        end,
        draw_button_sprite = function(self)
            
            spr(self.sprite, self.x+self.width/3, self.y+self.height+1)
            -- spr(n,x,y,w,h,flip_x,flip_y)
        end,
        is_player_money_greater_than_cost = function(self)
            return player.money >= self:get_cost()
        end,
        update_button_pressed = function (self)
            if not self:is_player_money_greater_than_cost() then
                return
            end
            if is_player_in_this_area(self.x, self.y-5, self.x+self.width, 
                self.y + self.height) and not is_any_button_pressed() then

                if self.pressed_timer <= self.seconds_to_buy then
                    
                    sfx(7)
                    self.pressed_timer += 1/60
                end
                if self.pressed_timer >= self.seconds_to_buy then

                    self:button_pressed()
                    self.pressed_timer = 0
                end
            else

               self.pressed_timer = 0
            end
        end,
        draw_time_to_buy_rect = function(self)
            local percentage = self.pressed_timer/self.seconds_to_buy

            draw_filled_rect(self.x+1, self.y+self.height, self.width-1, self.second_surface_height, percentage, 
                colors.white)
        end,
        draw_level = function(self)
            spe_print(self.level,  self.x+12, self.y+self.height+14, self.light_color, self.dark_color )
        end,
        get_cost = function(self)
            local cost
            if count(self.costs) > self.level then
                cost = self.costs[self.level]
            else
                cost = self.costs[count(self.costs)]
            end 
            return cost
        end,
        draw_cost = function(self)
            
            local cost = self:get_cost()

            local font_color, back_color = colors.green, colors.dark_green
            if player.money < cost then
                font_color, back_color = colors.red, colors.dark_purple
            end

            spe_print('$'..cost, self.x+self.width+2, self.y+self.height+14, font_color, back_color)
        end,
        button_pressed = function(self)
            player.money -= self:get_cost()
            self.level += 1
            sfx(8)
            sfx(6)
            show_message('+attack', player.x-10, player.y, colors.red, 
                colors.dark_purple, 1, 2, 'level up text', true, true)
            
            self.upgrade()
        end,    
        update = function(self)
            self:update_button_pressed()
        end,
        draw = function(self)
            self:draw_button_rect()
            self:draw_time_to_buy_rect()
            self:draw_button_sprite()
            self:draw_level()
            self:draw_cost()
        end
    })

    return platform_button
end

-- ##show_message
function show_message(text, x, y, font_color, back_color, speed, display_time_setter, tag, moving, blinking)
    
    local msg = make_gameobject(x, y, tag, {
        text= text, 
        font_color = font_color,
        back_color = back_color,
        blinking = blinking,
        speed = speed,
        moving_speed=3,
        display_time = time()+display_time_setter,
        set_properties = function(self, text, second_parameter_x, second_parameter_y, font_color, back_color, speed, display_time)
            self.text=text
            self.x=second_parameter_x
            self.y=second_parameter_y
            self.font_color=font_color
            self.back_color=back_color
            self.speed=speed
            self.display_time=time()+display_time
        end,
        update=function(self)
            if moving then 
                self.y -= self.moving_speed 
                if(self.moving_speed>=0.1) then 
                    self.moving_speed*=0.8 
                end
            end

            if(time()>= self.display_time) then 
                self:disable()
            end
        end,
        blink_color=function(self)
            if(time()*self.speed%4 >= 2) then
                return true 
            else 
                return false 
            end
        end,
        draw=function(self)
            if self.blinking then 
                if(self:blink_color()) then
                    spe_print(self.text, self.x, self.y, colors.white, colors.light_gray, true)
                else
                    spe_print(self.text, self.x, self.y, font_color, back_color, true)
                end
            else
                spe_print(self.text, self.x, self.y, font_color, back_color)
            end
        end
    })

    -- if msg != nil then
    msg:set_properties(text, x, y, font_color, back_color, speed, display_time_setter)
    return msg
    -- end

 end

function distance(current, target)
    local x0, x1, y0, y1 = current.x, target.x, current.y, target.y  
    -- scale inputs down by 6 bits
    local dx=(x0-x1)/64
    local dy=(y0-y1)/64

    -- get distance squared
    local dsq=dx*dx+dy*dy

    -- in case of overflow/wrap
    if(dsq<0) return 32767.99999

    -- scale output back up by 6 bits
    return sqrt(dsq)*64
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


-- ##enemy
function make_enemy (x, y, damage, health, move_speed, sprites, flying)
    local enemy = make_gameobject(x, y, 'enemy', {
        damage = damage,
        flying = flying or false,
        max_health = health,
        current_health = health,
        move_speed = move_speed,
        c_sprite = 0,
        sprites = sprites,
        attack_info = {range = 3, attack_speed = 2, reload_time=0},
        target = player,

        enemy_collision_check = function (self)
            if distance(self, self.target) < self.attack_info.range then
                self:attack()
            end
        end,

        attack = function (self)
            if self.attack_info.reload_time < get_time() then
                self.attack_info.reload_time = get_time()+self.attack_info.attack_speed
                self.target:take_damage(self.damage)
            end
        end,
        move = function (self)
            if(distance(self, self.target) >= self.attack_info.range) then
                if not self.flying then
                
                    move_toward(self,{x=self.target.x, y=self.y}, self.move_speed)
                else
                    move_toward(self, self.target, self.move_speed)
                
                end
            end
        end,
        take_damage = function (self, damage)
            self.current_health -= damage

        end,
        give_money = function(self)
            local money = flr(self.max_health/3) + 1
            player.money += money
            show_message('+$'..money, self.x, self.y, colors.green, 
                colors.dark_green, 15,  2, 'gained_money_text', true, false)
        end,
        destroy = function (self)
            self:give_money()
            dust_part(self.x+4, self.y+10, 3,{6, 5})
            spawner.alivee -= 1
            self:disable()
        end,
        check_if_alive = function(self)
            if self.current_health <= 0 then
                self:destroy()
            end
        end,
        update_sprite = function(self)
            local table = self.sprites.idle
            local speed = 2

            table = self.sprites.running
            speed = self.move_speed*5
            print(speed..self.tag)
            
            local n = flr(get_time()/10*speed%#table)+1
            self.c_sprite = table[n]
        end,
        draw_sprite = function(self)
            
            if self.x > self.target.x then
                self.look_to_left = true
            else
                 self.look_to_left = false
            end
            outline_spr(self.c_sprite, self.x+shkx, self.y+shky, self.look_to_left)

            spr(self.c_sprite, self.x+shkx, self.y+shky, 1, 1, self.look_to_left)
        end,
        update = function (self)
            self:check_if_alive()
            self:update_sprite()
            self:enemy_collision_check()
            self:move()
        end,
        draw = function (self)
            self:draw_sprite()
        end

    })

    add()
    return enemy
end

-- ##spe_print
function spe_print(text, x, y, col_in, col_out, bordercol)
    local outlinecol = 0
    if bordercol != nil then outlinecol = bordercol end
    if bordercol != 16 then
    -- draw outline color.
    print(text, x-1+shkx, y+shky, outlinecol) 
    print(text, x+1+shkx, y+shky, outlinecol)
    print(text, x+1+shkx, y-1+shky, outlinecol)
    print(text, x-1+shkx, y-1+shky, outlinecol)
    print(text, x+shkx, y-1+shky, outlinecol)
    print(text, x+1+shkx, y+1+shky, outlinecol)
    print(text, x-1+shkx, y+1+shky, outlinecol)
    print(text, x+1+shkx, y+2+shky, outlinecol)
    print(text, x-1+shkx, y+2+shky, outlinecol)
    print(text, x+shkx, y+2+shky, outlinecol)
    end
    -- draw col_out.
    print(text, shkx+x, shky+y+1, col_out)
    -- draw text.
    print(text, shkx+x, shky+y, col_in)
end

function whiteframe_update()
    if whiteframe == true then
        rectfill(-100,-100, 200, 200, 8)
        whiteframe = false
    end
end

function draw_filled_rect(x, y, width, height, pc, font_col, back_col, bordercol)
            -- draw_filled_rect(x, y, x+width, y+height, pourcentage_fill, colors.green, colors.black)
    height -= 1
    local length = (x+width) - x
    if bordercol then
        rectfill(x-1,y-1,x+width+1,y+height+1,bordercol)
    end
    if back_col then
        rectfill(x,y,x+width,y+height,back_col)
    end
    if pc > 0.001 then
    rectfill(x,y, x + length*pc,y+height,font_col)
end
end

-- ##bullet
function make_bullet(x, y, direction, damage, backoff, move_speed, sprite, tag)
  local bullet = make_gameobject (x, y, tag, {
    damage=damage,
    move_speed=move_speed,
    sprite=sprite,
    range = 5,
    backoff = backoff,
    direction=direction,
    out_of_screen = function (self)
        if (self.x < -2 or self.x > 128) or (self.y < 0 or self.y > 120) then
            sfx(4)
            self:destroy()
        end
    end,
    explode=function(self)
      hit_part(self.x, self.y,{7, 6, 5})
      -- if self.target:get_tag() !='player' then sfx(0) end
    end,
    destroy = function (self)
        self:explode()
        self:disable()
    end,
    enemy_collision_check = function (self)
        local enemy = closest_obj(self, 'enemy')
        if enemy != nil and distance(self, enemy) < self.range then
            sfx(1)            
            enemy:take_damage(self.damage)
            -- enemy backoff
            move_toward(enemy, {x=self.x, y=enemy.y}, -self.backoff)

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
        outline_spr(self.sprite, self.x+shkx, self.y+shky)
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

function outline_spr(n, x, y, _flip_x, _flip_y, outline_color)
  local out_col = outline_color or 0
  local flip_x, flip_y = false, false
  if _flip_x then flip_x = _flip_x end
  if _flip_y then flip_y = _flip_y end

  local pal, spr = pal, spr
  for i=0, 15 do pal(i, out_col) end

  spr(n, x+1, y, 1, 1, flip_x, flip_y)
  spr(n, x-1, y, 1, 1, flip_x, flip_y)
  spr(n, x, y+1, 1, 1, flip_x, flip_y)
  spr(n, x, y-1, 1, 1, flip_x, flip_y)
  pal()
end


__gfx__
00000000000000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009900000599900000000000000000000000000000000000067000000444999000000000000000000000000000000000000000000000000000000000
00700700059990005544000000000000000000000000000000000000066700000466779000000000000000000000000000000000000000000000000000000000
000770005544000055bb777000000000000000000000000000000000006670000466779000000000000000000000000000000000000000000000000000000000
0007700055bb777055b3667700000000000000000000000000000000000667900466779000000000000000000000000000000000000000000000000000000000
0070070055b366775636000000000000000000000000000000000000000069000046790000000000000000000000000000000000000000000000000000000000
00000000566600000363000000000000000000000000000000000000000090900004900000000000000000000000000000000000000000000000000000000000
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
00003800000003800000380000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003800000003300000380000038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00330000000330000003000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03033000000333300033000030330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000000030000003300000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00303300000033000003300000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000300000330300003300003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000300000300003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99979797999999990000000099999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999797970000000099979797000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999990999999999999999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999909997979709999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099000000000009999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99000000009909900999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009909999099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08777880007777000077770008877780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08777880077888700788877008877780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077888700788877007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000067200b7200f72014720187001a70020700247002c7002d70000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00010000336102e6102961027610226101f6101d6101b61016610136100f6100a6100a61005610036100361009600086000060000600006000060000600006000060000600006000060000600006000060000600
000100000000000000010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000021200010004100001000810000100001000b110001000b10000100001000010006100001000010000100001000010033100001000410001100061000010000100001000010000100001000b1000f100
000100000000000000000000000012610106100901006010030100101001010010100101001010010100101000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000039210332102c210282102721029210242101f2101b2101821016210112100f2100f2100f2100a2100a210072100721005210032100020000200002000020000200002000020000200002000020000200
01040000053130731308313093130a3130b3130c3130d3130e313103131231313313143131531317313193131b3131c3131f31321313233132431327313283132b3132d3132f3133231332313353133731339313
000100000141001400014000140001400014000140010600101001020010300106001010010200103001060010100102001030010600101001020010300106001010010200103001060010100102001030010600
000400003d61339613376133461332613306132e6132b6132a6132861326613256132361322613206131f6131d6131c6131a6131861317613156131461312613116130f6130d6130b61309613076130561302613
010200001b3230f033276131c61018610006100761007610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000036153321532f1532d1532a15327153241532315322153211531e1531e1531c1531b1531a1531a15318153171531615314153101530f1530d1530c1530e1530c1530b1530915307153071530515304153
010300003963339623396133961301013010130101308003070030600304003040030300303003020030200302003020030200301003000030000300003000030000300003000030000300003000030000300003
