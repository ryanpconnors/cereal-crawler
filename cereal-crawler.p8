pico-8 cartridge // http://www.pico-8.com
version 31
__lua__
-- main
-- cereal monster
-- rougelike dungeon crawler 
-- thrillho (2021)

function _init()
	t=0
	start_game()
	_upd=update_game
	_drw=draw_game 
end

function _update60()
 t=(t+1)%30 --t per second
	_upd()
end

function _draw()
 _drw()
 draw_textboxes()
end

function start_game()
	player_init(007,014,⬆️)
	window={}
	textbox(32,32,64,50,{"hello", "world!"})
end
-->8
-- updates

function update_game()
	if btnp()>0 then
		move_player()
	end
	if hp == 0 then
		_upd=update_game_over
	end
end

function update_game_over()
	return true
end
-->8
-- draws
function draw_game()
	-- clear the screen (black)
 cls(0)
 draw_map()
 draw_player()
end

function draw_game_over()
	cls(1)
end

function draw_map()
	-- draw the map at (0,0)
	map(000,000)
end
-->8
-- player

function player_init(x,y,dir)
	p={}
	p.x,p.y=nil,nil 				--position
	p.hit_x,p.hit_y=0,8 --hitbox pos
	p.hit_w,p.hit_h=7,7 --hitbox size
	p.ani={													--animations
			[⬅️]={006,007},
	 	[➡️]={006,007},
			[⬆️]={038,039},
	 	[⬇️]={022,023}
	}
	p.spr=nil  			--current sprite
	p.mov=nil					--movement animation func 
	p.frm=nil					--animation frame
	p.dir=dir 				--direction
	p.spd=8  					--speed
	p.t=0         --ani timer
	p.ox,p.oy=0,0 --ani offset
	p.dx,p.dy=0,0 --position delta 
 p.x,p.y=x*8,y*8
end

function draw_player()
	spr(get_frame(p.ani[p.dir]),p.x+p.ox,p.y+p.oy,1,1,p.dir==⬅️,false)
end

function animate_walk()
 p.t=min(p.t+0.125,1)
 p.mov()
 if p.t==1 then
 	_upd=update_game
 end
end

function move_player()
	local d_x={-1,1,0,0}
	local d_y={0,0,-1,1}
	for i=⬅️,⬇️ do
		if btnp(i) then
			local dx,dy=d_x[i+1],d_y[i+1]
			local dest_x,dest_y=flr((p.x/8)+dx),flr((p.y/8)+dy)
			local tile=mget(dest_x,dest_y)
			p.dir=i
			if fget(tile,0) then -- wall
				p.dx,p.dy=dx*8,dy*8
				p.ox,p.oy=0,0
				p.t=0
				_upd=animate_walk
				p.mov=mov_bump
				sfx(01)
			else -- move to next tile
				p.x+=dx*p.spd
				p.y+=dy*p.spd
				p.dx,p.dy=dx*-8,dy*-8
				p.ox,p.oy=p.dx,p.dy
				p.t=0
				_upd=animate_walk
				p.mov=mov_walk
				sfx(00)
			end
		end
	end
end

function mov_walk()
	p.ox=p.dx*(1-p.t)
 p.oy=p.dy*(1-p.t)
end

function mov_bump()
	local t = 0.5-abs(0.5 - p.t)
 p.ox,p.oy = p.dx*t, p.dy*t
end
-->8
-- helpers

-- get current frame from animations array
-- where t is the gloabl frame counter
function get_frame(animations)
	slowdown=12
	return animations[flr(t/slowdown)%#animations+1]
end
-->8
-- ui

function textbox(_x,_y,_x2,_y2,_txt)
	local w={
		x=_x,
		y=_y,
		x2=_x2,
		y2=_y2,
		txt=_txt
	}
	add(window,w)
	return w
end

function draw_textboxes()
	for w in all(window) do
		local x,y,x2,y2=w.x,w.y,w.x2,w.y2
		rectfill(x,y,x2,y2,7) -- box
		rectfill(x+1,y+1,x2-1,y2-1,0) --border
		x+=4
		y+=4
		clip(x,y,x2-8,y2-8)
		for i=1,#w.txt do
			local txt=w.txt[i]
			print(txt,x,y,7) --font is 6-px high
			y+=6
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000444440000000000000000000222200000000000000000000000000000eeeeeeee0000000000000
0000000007700770077007700000000000000000000000000444f3f0004444400000000002eeee2000000000000000000000000080e222ee222e088000000000
00700700788778877887700700000000000000000000000004f4ffff0444f3f0000000002eeeeee20000000000000000000000088eeeeeeeeeeee28000000000
00077000788888877888000700000000000000000000000004fffff004f4ffff000000002edeede20000000000000000000000008eee22eee22ee80000000000
0007700078888887788800070000000000000000000000000cccccc004fffff0000000002e0ee0e20000000000000000000000008ee2dd2e2dd2e80000000000
0070070007888870078800700000000000000000000000000cffcccf0cccccc0000000002eeeeee20000000000000000000000000ee2702e2702e00000000000
00000000007887000078070000000000000000000000000000cccc003cccffc3000000002eeeeee20000000000000000000000000eee22eee22ee00000000000
00000000000770000007700000000000000000000000000000033300330000330000000020e02e0200000000000000000000000008eeeeeeeeee800000000000
07665766657666566657666056666665099999944499999000444400004444000000000000000000000000000000000000000000088ee0000ee8800000000000
605555555555555555555507656666509444444aaa44444904f3f340043f3f400000000000000000000000000000000000000000008eeeeeeee8000000000000
65076665666576666576605666555500944444a000a444490ffffff00ffffff000000000000000000000000000000000000000022222eeeeeee2222000000000
75605555555555555555065666555500949994a000a49949fcffffc00cffffcf000000000000000000000000000000000000222dddd22eeeee22ddd222000000
556507666576665666605656665555009444444a0a444449fcccccf00fcccccf000000000000000000000000000000000002dddddddd2222222ddddddd200000
65556055555555555506565566555500944444a00a4444490ccccff00ffcccc000000000000000000000000000000000002dd00000000000000000000dd20000
656565076666576660565557650000509499994aa49999490cc0033003300cc00000000000000000000000000000000000200002000000000000000000020000
75655560555555550655565650000005944444449444444903300000000003300000000000000000000000000000000000200002000000000000000000020000
65656565566666665657555500000000995555555555559900444400004444005666666600000000000000000000000000200002000000000000000000020000
556555656555555056565756000000009400000000000049044444400444444065aaaa5000000000000000000000000000200002000000000000000000020000
65656565655555505556565600000000940000000000004904444440044444406a9944a000000000000000000000000000202222000000000000000000200000
657565756555555056565656000000009400000000000049fc4444cffc4444cf6a9444a000000000000000000000000000220002000000000000000000200000
655565556555555056555655000000009400000000000049fcccccc00ccccccf65aaaa5000000000000000000000000000222222000000000000000000200000
7565756565555550565756570000000094005555555550490cccccc00cccccc06999444000000000000000000000000000000000000000000000022222200000
556555656555555055565556000000009405ddddddddd54903300cc00cc003306994444000000000000000000000000000000000000000000000000000000000
65756565000000055656565600000000945666666666664900000330033000000099440500000000000000000000000000000000000000000000000000000000
65656560555555550655565600000000000000000000000000000000000000009999999956666666000000000000000000000000000000000000000000000000
65556506656667566057565600000000000000000000000000000000000000009444444965555550000000000000000000000000000000000000000000000000
75657055555555555506555500000000000000000000000000000000000000009444444965555550000000000000000000000000000000000000000000000000
55650667566756666650565600000000000000000000000000000000000000009449a4499559a559000000000000000000000000000000000000000000000000
6570555555555555555506550000000000000000000000000000000000000000aaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000
65066566665667566756605700000000000000000000000000000000000000004494494444944944000000000000000000000000000000000000000000000000
70555555555555555555550600000000000000000000000000000000000000004494494444944944000000000000000000000000000000000000000000000000
0665675666756666656756600000000000000000000000000000000000000000aaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000
__gff__
0000000000000000000100000000000001010101010100000000000000000000010001000000000001000000000000000101010000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111114151111111111111200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2028282121212121212121212128282200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2028212121212121212121212121282200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121212121212121212121212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121212121212121212121212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121132121211321212121212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121132121211321211313212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021132121132138211321211313212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121132121211321212121212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121131313131321212121212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021212121212121212121212121212200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2028212121212121212121212121282200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2028282121212121212121212128282200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031313131313124253131313131313200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000011730187600b7300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000403001073008750017502560024600000000000025200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
