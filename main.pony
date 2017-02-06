/*********************************
Ponylang 2048 (ANSI terminal)
@author macdougall.doug@gmail.com

TODO:
* win condition
* lose condition
* finish ANSI color scheme
* learn more pony, make it better
**********************************/

use "term"
use "random"
use "time"

primitive QUIT
primitive LEFT
primitive RIGHT
primitive UP
primitive DOWN
type Move is (LEFT|RIGHT|UP|DOWN|QUIT)

class  KeyboardHandler is ANSINotify
   let _game : Game tag
   var _count : U32 = 0

   new iso create(game : Game tag) =>
      _game = game

   fun ref apply(term: ANSITerm ref, input: U8 val) =>
     _game.move(QUIT)
     term.dispose()

   fun ref left(ctrl: Bool, alt: Bool, shift: Bool) =>
      _game.move(LEFT)
   fun ref down(ctrl: Bool, alt: Bool, shift: Bool) =>
      _game.move(DOWN)
   fun ref up(ctrl: Bool, alt: Bool, shift: Bool) =>
      _game.move(UP)
   fun ref right(ctrl: Bool, alt: Bool, shift: Bool) =>
      _game.move(RIGHT)
   fun ref closed() =>
        _game.move(QUIT)

type ROW is (U32,U32,U32,U32)

primitive Merger
    fun tag apply(r : ROW) : ROW =>
      match r
      | (0,0,0,_) => (r._4,0,0,0)
      | (0,0,_,r._3) => (r._3<<1,0,0,0)
      | (0,0,_,_) => (r._3,r._4,0,0)
      | (0,_,r._2,_) => (r._2<<1,r._4,0,0)
      | (0,_,0,r._2) => (r._2<<1,0,0,0)
      | (0,_,0,_) => (r._2,r._4,0,0)
      | (0,_,_,r._3) => (r._2,r._3<<1,0,0)
      | (0,_,_,_) => (r._2,r._3,r._4,0)
      | (_, r._1, _, r._3) => (r._1<<1, r._3<<1, 0, 0)
      | (_, r._1, 0, _) => (r._1<<1, r._4, 0, 0)
      | (_, r._1, _, _) => (r._1<<1, r._3, r._4, 0)
      | (_, 0,r._1, _) => (r._1<<1,r._4,0,0)
      | (_, 0,0, r._1) => (r._1<<1,0,0,0)
      | (_, 0,0, _) => (r._1,r._4,0,0)
      | (_, 0,_, r._3) => (r._1, r._3<<1,0,0)
      | (_, 0,_, _) => (r._1, r._3,r._4,0)
      | (_,_,r._2,_) => (r._1, r._2<<1,r._4,0)
      | (_,_,0,r._2) => (r._1, r._2<<1,0,0)
      | (_,_,0,_) => (r._1, r._2,r._4,0)
      | (_,_,_,r._3) => (r._1, r._2,r._3<<1,0)
      else
         r
      end

actor Game
  embed _grid : Array[U32]
  let _rand : Random = MT(Time.millis())
  let _env : Env
  var _c : U32 =  0
  let _board : String ref = recover String(1024) end

  new create(env: Env)=>
    _env = consume env    
    _grid = Array[U32](4*4)
    var i : U32 = 0
    while i < 16 do
      _grid.push(0)
      i = i + 1
    end
    _add_block()
    _add_block()
    _draw()

  fun ref _merge(ridx : ROW) =>
    let rval : ROW = (_get(ridx._1),_get(ridx._2),_get(ridx._3),_get(ridx._4))
    var rout = Merger(rval)
    _set(ridx._1, rout._1)
    _set(ridx._2, rout._2)
    _set(ridx._3, rout._3)
    _set(ridx._4, rout._4)


  fun ref _left()=>
    let row :Array[U32]= [0,4,8,12]
    for r in row.values() do
      _merge( (r,r+1,r+2,r+3) )
    end

  fun ref _right()  =>
    let row :Array[U32]= [3,7,11,15]
    for r in row.values() do
      _merge( (r, r-1, r-2, r-3) )
    end

  fun ref _up() =>
    let row :Array[U32]= [0,1,2,3]
    for r in row.values() do
      _merge( (r,r+4,r+8,r+12) )
    end

  fun ref _down() =>
    let row :Array[U32]= [12,13,14,15]
    for r in row.values() do
      _merge( (r, r-4, r-8, r-12) )
    end

  fun _fmt(i : U32) : String =>
    match i
    | 0 => " __ "
    | 2 => "\x1B[91m  2 \x1B[0m"
    | 4 => "\x1B[92m  4 \x1B[0m"
    | 8 => "\x1B[93m  8 \x1B[0m"
    | 16 => "\x1B[94m 16 \x1B[0m"
    | 32 => "\x1B[95m 32 \x1B[0m"
    | 64 => "\x1B[96m 64 \x1B[0m"
    | 128 => "\x1B[91m128 \x1B[0m"
    | 256 => "\x1B[91m256 \x1B[0m"
    | 512 => "\x1B[91m512 \x1B[0m"
    | 1024 => "\x1B[91m1024\x1B[0m"
    | 2048 => "\x1B[91m2048\x1B[0m"
    else
      i.string()
    end

  fun ref _draw() =>
    let s : String ref = _board
    s.truncate(0)
    var i : U32 = 0
    repeat
      if (i % 4) == 0 then
          s.append("-----------------------\n")
      end
      s.append(_fmt(_get(i)))
      s.append(" ")
      i = i + 1
      if (i % 4) == 0 then
          s.append("\n")
      end
    until i==16 end
    _env.out.print(s.string())
    _env.out.print("Arrow keys to move. Any other key to quit.")

   fun ref _set(i:U32, v : U32) =>
     try
       _grid.update(i.usize(),v)
     else
       _env.out.print("cant update!")
     end

  fun ref _add_block() =>
    var c : U64 = 0
    for v in _grid.values() do
      c = c + if v == 0 then 0 else 1 end
    end

    if c == 16 then return end

    var hit =  _rand.int(16 - c)
    var i : U32 = 0
    while i < 16 do
      let n = _get(i)
      if (n == 0) then
        if hit == 0 then
          _set(i, if  _rand.int(10) > 0 then 2 else 4 end)
          break
        end
        hit = hit - 1
      end
      i = i + 1
    end

  fun _get(i : U32) : U32 =>
    let i' = i.usize()
    try  _grid(i') else 0  end

  be move(QUIT) =>
    _env.exitcode(0)
    _env.input.dispose()

  be move(m: Move) =>
    match m
      | LEFT =>  _left()
      | RIGHT => _right()
      | UP =>    _up()
      | DOWN =>  _down()
    end

    _add_block()
    _draw()


actor Main
  new create(env: Env) =>
    ifdef "test" then
      TestMain(env)
      return
    end
// real main follows..
    let input : Stdin tag = env.input
    env.out.print("Welcome to ponylang-2048...")
    let game = Game(env)
    let term = ANSITerm(KeyboardHandler(game), input)

    let notify : StdinNotify iso = object iso
        let term: ANSITerm = term
        let _in: Stdin tag = input
        fun ref apply(data: Array[U8] iso) => term(consume data)
        fun ref dispose() =>
          _in.dispose()
    end

    input(consume notify)
   