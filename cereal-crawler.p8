pico-8 cartridge // http://www.pico-8.com
version 31
__lua__
-- main
-- cereal monster
-- rougelike dungeon crawler 
-- thrillho .2021

_message={}
_t=nil
_tile_size=8

function _init()
	_t=0
	start_game()
end

function _update60()
 _t=(_t+1)%60 --t per second
	update_game()
end

function _draw()
	cls(0)
	draw_map()
	draw_hud()
 draw_player()
 draw_message()
end

function start_game()
	init_player(007,014,⬆️)
	_message = {
		box=get_textbox({"hello","world!"}),
  t=3*60	
	}
end

-->8
-- updates

function update_game()
	if hp == 0 then
		update_game_over()
	end
	if _message.t then
		if _message.t<=0 and btn(5) then
			_message.t=nil
		end
	else
		move_player()
	end
end

function update_game_over()
	return true
end

-->8
-- draws
function draw_game()
 cls(0)
 draw_map()
 draw_player()
end

function draw_game_over()
	cls(1)
end

function draw_map()
	map(000,000)
end

function draw_hud()
 print('-life-',0*8+2,1*8+2,8)
end

function draw_message()
 if _message.box and _message.t then
   if _message.t >0 then 
    _message.t-=1
   end
			draw_textbox(_message.box)
 end
 if _message.t==0 then
 	print_outline('❎',_message.box.x2-6,_message.box.y2-2.9+sin(time()),7,0)
 end
 if _message.box and _message.t==nil then
  local diff=(_message.box.y2-_message.box.y)/8
	 _message.box.txt={}
	 _message.box.y+=diff/4
	 _message.box.y2-=diff
	 if diff>2 then
	  draw_textbox(_message.box)
	 else
	  _message={}
  end
 end
end

-- prints a black outline around 
function print_outline(s,x,y,c1,c2)
 dirx={-1,1,0,0,1,1,-1,-1}
 diry={0,0,-1,1,-1,1,1,-1}
 for i=1,8 do
  print(s,x+dirx[i],y+diry[i],c2)
 end 
 print(s,x,y,c1)
end

-->8
-- player

function init_player(x,y,dir)
	p={}
	p.x,p.y=x*_tile_size,y*_tile_size --position
	p.cx,p.cy=0,4       --hitbox pos
	p.cw,p.ch=6,3       --hitbox size
	p.ani={							      --animations
			[⬅️]={006,007},
	 	[➡️]={006,007},
			[⬆️]={038,039},
	 	[⬇️]={022,023}
	}
	p.dir=dir 										--direction
	p.t,p.f,p.stp=0,2,8 --animation vars
 p.spd=0.7 										--speed
end

function draw_player()
	spr(p.ani[p.dir][p.f],p.x,p.y,1,1,p.dir==⬅️)
end

function move_player()
 local dx,dy=0,0
 
 --guard opposite directions
 if btn(⬆️) and btn(⬇️) or btn(⬅️) and btn(➡️) 
 	then return
 end
	
	if btn(⬆️) then
	 dy-=p.spd
	 p.dir=⬆️
	elseif btn(⬇️) then
	 dy+=p.spd
	 p.dir=⬇️
	elseif btn(⬅️) then
		dx-=p.spd
		p.dir=⬅️	
 elseif btn(➡️) then
	 dx+=p.spd
	 p.dir=➡️
	end
	
	if btn()>0 then 
		anim_player_walk()
	end
	
	if can_move(p.x+p.cx+dx,p.y+p.cy+dy,p.cw,p.ch) 
	then
		p.x+=dx
		p.y+=dy
	end 
	
	-- horizontal wall strafing
	if (btn(⬆️) or btn(⬇️)) and (btn(⬅️) or btn(➡️)) 
	and not can_move(p.x,p.y+p.cy+dy,p.cw,p.ch) then
		if btn(⬅️) then
		 dx-=p.spd
		 p.dir=⬅️
 	elseif btn(➡️) then
	  dx+=p.spd
	  p.dir=➡️
		end
		if can_move(p.x+p.cx+dx,p.y+p.cy,p.cw,p.ch) then
		 p.x+=dx
		end
	end 
end

function anim_player_walk()
	p.t=(p.t+1)%p.stp
	if p.t==0 then 
		p.f=p.f%#p.ani[p.dir]+1
	 p.t=1
	end
end

function can_move(x,y,w,h)
 local ok=true
	x1,y1=flr(x/_tile_size),flr(y/_tile_size)
 x2,y2=flr((x+w)/_tile_size),
 flr((y+h)/_tile_size)
 if flag(x1,y1)!=0 or flag(x2,y1)!=0 or flag(x2,y2)!=0 or flag(x1,y2)!=0 then
		ok=false
	end
	return ok
end

--map flag helper
function flag(x,y)
	return fget(mget(x,y)) 
end

-->8
-- ui

function get_textbox(txt)
	local w,h,box=0,0,{
	 x=0,
		txt=txt
	}
	for str in all(txt) do
		w=max(w,#str*4+10)
	end
	h=#txt*6+4
	box.x=64-w/2
	box.x2=64+w/2
	box.y=64-h/2
	box.y2=64+h/2+4
	return box
end

function draw_textbox(box)
	local x,y,x2,y2,txt=box.x,box.y,box.x2,box.y2,box.txt
	rectfill(x,y,x2,y2,0) 				-- draw box
	rect(x+1,y+1,x2-1,y2-1,7) -- draw frame
	x+=6
	y+=5
	clip(x,y,x2-x,y2-y)
	for i=1,#txt do
		local str=txt[i]
		for c=1,#str do
		 -- todo: print char by char
			print(sub(str,c,c),x+(c-1)*4,y,7)
		end
		y+=6
	end
	clip()
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
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700770077007700770077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78877887788778877887700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888887788888877888000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78888887788888877888000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07888870078888700788007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00788700007887000078070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07665766657666566576665665766656657666566576665665766656099999944499999065766656657666566576665665766656657666566576665666576660
605555555555555555555555555555555555555555555555555555559444444aaa44444955555555555555555555555555555555555555555555555555555507
65076665666576666665766666657666666576666665766666657666944444a000a4444966657666666576666665766666657666666576666665766665766056
75605555555555555555555555555555555555555555555555555555949994a000a4994955555555555555555555555555555555555555555555555555550656
556507666576665665766656657666566576665665766656657666569444444a0a44444965766656657666566576665665766656657666566576665666605656
65556055555555555555555555555555555555555555555555555555944444a00a44444955555555555555555555555555555555555555555555555555065655
656565076666576666665766666657666666576666665766666657669499994aa499994966665766666657666666576666665766666657666666576660565557
75655560555555555555555555555555555555555555555555555555944444449444444955555555555555555555555555555555555555555555555506555656
65656565566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656575555
5565556565aaaa5065aaaa506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5065aaaa5056565756
656565656a9944a06a9944a0655555506555555065555550655555506555555065555550655555506555555065555550655555506a9944a06a9944a055565656
657565756a9444a06a9444a0655555506555555065555550655555506555555065555550655555506555555065555550655555506a9444a06a9444a056565656
6555655565aaaa5065aaaa506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5065aaaa5056555655
75657565699944406999444065555550655555506555555065555550655555506555555065555550655555506555555065555550699944406999444056575657
55655565699444406994444065555550655555506555555065555550655555506555555065555550655555506555555065555550699444406994444055565556
65756565009944050099440500000005000000050000000500000005000000050000000500000005000000050000000500000005009944050099440556565656
65656565566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656575555
5565556565aaaa5065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5056565756
656565656a9944a06555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506a9944a055565656
657565756a9444a06555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506a9444a056565656
6555655565aaaa5065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5056555655
75657565699944406555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506999444056575657
55655565699444406555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506994444055565556
65756565009944050000000500000005000000050000000500000005000000050000000500000005000000050000000500000005000000050099440556565656
65656565566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656575555
55655565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056565756
65656565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555055565656
65756575655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056565656
65556555655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056555655
75657565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056575657
55655565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555055565556
65756565000000050000000500000005000000050000000500000005000000050000000500000005000000050000000500000005000000050000000556565656
65656565566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656575555
55655565655555506555555065555550655555506555555065555550655555444455555065555550655555506555555065555550655555506555555056565756
65656565655555506555555065555550655555506555555065555550655554f3f345555065555550655555506555555065555550655555506555555055565656
6575657565555550655555506555555065555550655555506555555065555ffffff5555065555550655555506555555065555550655555506555555056565656
655565556555555065555550655555506555555065555550655555506555fcffffc5555065555550655555506555555065555550655555506555555056555655
756575656555555065555550655555506555555065555550655555506555fcccccf5555065555550655555506555555065555550655555506555555056575657
5565556565555550655555506555555065555550655555506555555065555ccccff5555065555550655555506555555065555550655555506555555055565556
6575656500000005000000050000000500000005000000050000000500000cc50330000500000005000000050000000500000005000000050000000556565656
65656565566666665666666656666666566666665666666556666666566663365666666656666665566666665666666656666666566666665666666656575555
55655565655555506555555065555550655555506566665065555550655555506555555065666650655555506555555065555550655555506555555056565756
65656565655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555055565656
65756575655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555056565656
65556555655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555056555655
75657565655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555056575657
55655565655555506555555065555550655555506500005065555550655555506555555065000050655555506555555065555550655555506555555055565556
65756565000000050000000500000005000000055000000500000005000000050000000550000005000000050000000500000005000000050000000556565656
65656565566666665666666656666666566666665666666556666666566666665666666656666665566666665666666656666665566666655666666656575555
55655565655555506555555065555550655555506566665065555550655555506555555065666650655555506555555065666650656666506555555056565756
65656565655555506555555065555550655555506655550065555550655555506555555066555500655555506555555066555500665555006555555055565656
65756575655555506555555065555550655555506655550065555550655555506555555066555500655555506555555066555500665555006555555056565656
65556555655555506555555065555550655555506655550065555550655555506555555066555500655555506555555066555500665555006555555056555655
75657565655555506555555065555550655555506655550065555550655555506555555066555500655555506555555066555500665555006555555056575657
55655565655555506555555065555550655555506500005065555550655555506555555065000050655555506555555065000050650000506555555055565556
65756565000000050000000500000005000000055000000500000005000000050000000550000005000000050000000550000005500000050000000556565656
65656565566666665666666556666666566666665666666556666666999999995666666656666665566666665666666656666665566666655666666656575555
55655565655555506566665065555550655555506566665065555550944444496555555065666650655555506555555065666650656666506555555056565756
65656565655555506655550065555550655555506655550065555550944444496555555066555500655555506555555066555500665555006555555055565656
657565756555555066555500655555506555555066555500655555509449a4496555555066555500655555506555555066555500665555006555555056565656
65556555655555506655550065555550655555506655550065555550aaaaaaaa6555555066555500655555506555555066555500665555006555555056555655
75657565655555506655550065555550655555506655550065555550449449446555555066555500655555506555555066555500665555006555555056575657
55655565655555506500005065555550655555506500005065555550449449446555555065000050655555506555555065000050650000506555555055565556
65756565000000055000000500000005000000055000000500000005aaaaaaaa0000000550000005000000050000000550000005500000050000000556565656
65656565566666665666666656666666566666665666666556666666566666665666666656666665566666665666666656666666566666665666666656575555
55655565655555506555555065555550655555506566665065555550655555506555555065666650655555506555555065555550655555506555555056565756
65656565655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555055565656
65756575655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555056565656
65556555655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555056555655
75657565655555506555555065555550655555506655550065555550655555506555555066555500655555506555555065555550655555506555555056575657
55655565655555506555555065555550655555506500005065555550655555506555555065000050655555506555555065555550655555506555555055565556
65756565000000050000000500000005000000055000000500000005000000050000000550000005000000050000000500000005000000050000000556565656
65656565566666665666666656666666566666665666666556666665566666655666666556666665566666665666666656666666566666665666666656575555
55655565655555506555555065555550655555506566665065666650656666506566665065666650655555506555555065555550655555506555555056565756
65656565655555506555555065555550655555506655550066555500665555006655550066555500655555506555555065555550655555506555555055565656
65756575655555506555555065555550655555506655550066555500665555006655550066555500655555506555555065555550655555506555555056565656
65556555655555506555555065555550655555506655550066555500665555006655550066555500655555506555555065555550655555506555555056555655
75657565655555506555555065555550655555506655550066555500665555006655550066555500655555506555555065555550655555506555555056575657
55655565655555506555555065555550655555506500005065000050650000506500005065000050655555506555555065555550655555506555555055565556
65756565000000050000000500000005000000055000000550000005500000055000000550000005000000050000000500000005000000050000000556565656
65656565566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656575555
55655565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056565756
65656565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555055565656
65756575655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056565656
65556555655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056555655
75657565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555056575657
55655565655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555055565556
65756565000000050000000500000005000000050000000500000005000000050000000500000005000000050000000500000005000000050000000556565656
65656565566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656575555
5565556565aaaa5065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5056565756
656565656a9944a06555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506a9944a055565656
657565756a9444a06555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506a9444a056565656
6555655565aaaa5065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5056555655
75657565699944406555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506999444056575657
55655565699444406555555065555550655555506555555065555550655555506555555065555550655555506555555065555550655555506994444055565556
65756565009944050000000500000005000000050000000500000005000000050000000500000005000000050000000500000005000000050099440556565656
65656565566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656666666566666665666666656575555
5565556565aaaa5065aaaa506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5065aaaa5056565756
656565656a9944a06a9944a0655555506555555065555550655555506555555065555550655555506555555065555550655555506a9944a06a9944a055565656
657565756a9444a06a9444a0655555506555555065555550655555506555555065555550655555506555555065555550655555506a9444a06a9444a056565656
6555655565aaaa5065aaaa506555555065555550655555506555555065555550655555506555555065555550655555506555555065aaaa5065aaaa5056555655
75657565699944406999444065555550655555506555555065555550655555506555555065555550655555506555555065555550699944406999444056575657
55655565699444406994444065555550655555506555555065555550655555506555555065555550655555506555555065555550699444406994444055565556
65756565009944050099440500000005000000050000000500000005000000050000000500000005000000050000000500000005009944050099440556565656
65656560555555555555555555555555555555555555555555555555995555555555559955555555555555555555555555555555555555555555555506555656
65556506656667566566675665666756656667566566675665666756940000000000004965666756656667566566675665666756656667566566675660575656
75657055555555555555555555555555555555555555555555555555940000000000004955555555555555555555555555555555555555555555555555065555
55650667566756665667566656675666566756665667566656675666940000000000004956675666566756665667566656675666566756665667566666505656
65705555555555555555555555555555555555555555555555555555940000000000004955555555555555555555555555555555555555555555555555550655
65066566665667566656675666566756665667566656675666566756940055555555504966566756665667566656675666566756665667566656675667566057
705555555555555555555555555555555555555555555555555555559405ddddddddd54955555555555555555555555555555555555555555555555555555506
06656756667566666675666666756666667566666675666666756666945666666666664966756666667566666675666666756666667566666675666665675660

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
