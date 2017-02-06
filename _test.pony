use "ponytest"

actor TestMain is TestList
  new create(env: Env) =>
    
    PonyTest(env, this)

  new make() =>
    None

 fun tag derp(out: StdStream tag)=>
   out.print("") 

  fun tag tests(test: PonyTest) =>
    test(_TestMerge)
//    test(_TestSub)

// TODO: revisit
//cant seem to get this working with tuples
class RowCmp is (Equatable[RowCmp] & Stringable)
  let _r: ROW
  new ref create(r: ROW) => _r =  r
  fun eq(that: box->RowCmp): Bool => 
      this._r is that._r
        // (this._r._1 == that._r._1) and
        // (this._r._2 == that._r._2) and
        // (this._r._3 == that._r._3) and
        // (this._r._4 == that._r._4)

    fun ne(that: box->RowCmp): Bool => not eq(that)
  fun box string() : String iso^ =>
    let s : String ref = recover String(30) end
      s.append("(")
      s.append(_r._1.string())
      s.append(",")
      s.append(_r._2.string())
      s.append(",")
      s.append(_r._3.string())
      s.append(",")
      s.append(_r._4.string())
      s.append(")")
      s.string()

class iso _TestMerge is UnitTest
  fun name():String => "2048 Merger test"

  fun apply(h: TestHelper) =>
    let rows : Array[(ROW, ROW)] = [
    // auto gen IN with python # [x for x in itertools.product(*[[0,1,2]]*4)]
    // hand jammed OUT
    // some repeats since matcher for 1100 is the same as 2200,
    //  but at least this covers every case
    // MERGE DIRECTION            <<|          |<<<<<<<
    /* TEST  1 */ (/*IN*/ (0, 0, 0, 0) , /*OUT*/(0,0,0,0) ),
    /* TEST  2 */ (/*IN*/ (0, 0, 0, 1) , /*OUT*/(1,0,0,0) ),
    /* TEST  3 */ (/*IN*/ (0, 0, 0, 2) , /*OUT*/(2,0,0,0) ),
    /* TEST  4 */ (/*IN*/ (0, 0, 1, 0) , /*OUT*/(1,0,0,0) ),
    /* TEST  5 */ (/*IN*/ (0, 0, 1, 1) , /*OUT*/(2,0,0,0) ),
    /* TEST  6 */ (/*IN*/ (0, 0, 1, 2) , /*OUT*/(1,2,0,0) ),
    /* TEST  7 */ (/*IN*/ (0, 0, 2, 0) , /*OUT*/(2,0,0,0) ),
    /* TEST  8 */ (/*IN*/ (0, 0, 2, 1) , /*OUT*/(2,1,0,0) ),
    /* TEST  9 */ (/*IN*/ (0, 0, 2, 2) , /*OUT*/(4,0,0,0) ),
    /* TEST 10 */ (/*IN*/ (0, 1, 0, 0) , /*OUT*/(1,0,0,0) ),
    /* TEST 11 */ (/*IN*/ (0, 1, 0, 1) , /*OUT*/(2,0,0,0) ),
    /* TEST 12 */ (/*IN*/ (0, 1, 0, 2) , /*OUT*/(1,2,0,0) ),
    /* TEST 13 */ (/*IN*/ (0, 1, 1, 0) , /*OUT*/(2,0,0,0) ),
    /* TEST 14 */ (/*IN*/ (0, 1, 1, 1) , /*OUT*/(2,1,0,0) ),
    /* TEST 15 */ (/*IN*/ (0, 1, 1, 2) , /*OUT*/(2,2,0,0) ),
    /* TEST 16 */ (/*IN*/ (0, 1, 2, 0) , /*OUT*/(1,2,0,0) ),
    /* TEST 17 */ (/*IN*/ (0, 1, 2, 1) , /*OUT*/(1,2,1,0) ),
    /* TEST 18 */ (/*IN*/ (0, 1, 2, 2) , /*OUT*/(1,4,0,0) ),
    /* TEST 19 */ (/*IN*/ (0, 2, 0, 0) , /*OUT*/(2,0,0,0) ),
    /* TEST 20 */ (/*IN*/ (0, 2, 0, 1) , /*OUT*/(2,1,0,0) ),
    /* TEST 21 */ (/*IN*/ (0, 2, 0, 2) , /*OUT*/(4,0,0,0) ),
    /* TEST 22 */ (/*IN*/ (0, 2, 1, 0) , /*OUT*/(2,1,0,0) ),
    /* TEST 23 */ (/*IN*/ (0, 2, 1, 1) , /*OUT*/(2,2,0,0) ),
    /* TEST 24 */ (/*IN*/ (0, 2, 1, 2) , /*OUT*/(2,1,2,0) ),
    /* TEST 25 */ (/*IN*/ (0, 2, 2, 0) , /*OUT*/(4,0,0,0) ),
    /* TEST 26 */ (/*IN*/ (0, 2, 2, 1) , /*OUT*/(4,1,0,0) ),
    /* TEST 27 */ (/*IN*/ (0, 2, 2, 2) , /*OUT*/(4,2,0,0) ),

    /* TEST 28 */ (/*IN*/ (1, 0, 0, 0) , /*OUT*/(1,0,0,0) ),
    /* TEST 29 */ (/*IN*/ (1, 0, 0, 1) , /*OUT*/(2,0,0,0) ),
    /* TEST 30 */ (/*IN*/ (1, 0, 0, 2) , /*OUT*/(1,2,0,0) ),
    /* TEST 31 */ (/*IN*/ (1, 0, 1, 0) , /*OUT*/(2,0,0,0) ),
    /* TEST 32 */ (/*IN*/ (1, 0, 1, 1) , /*OUT*/(2,1,0,0) ),
    /* TEST 33 */ (/*IN*/ (1, 0, 1, 2) , /*OUT*/(2,2,0,0) ),
    /* TEST 34 */ (/*IN*/ (1, 0, 2, 0) , /*OUT*/(1,2,0,0) ),
    /* TEST 35 */ (/*IN*/ (1, 0, 2, 1) , /*OUT*/(1,2,1,0) ),
    /* TEST 36 */ (/*IN*/ (1, 0, 2, 2) , /*OUT*/(1,4,0,0) ),
    /* TEST 37 */ (/*IN*/ (1, 1, 0, 0) , /*OUT*/(2,0,0,0) ),
    /* TEST 38 */ (/*IN*/ (1, 1, 0, 1) , /*OUT*/(2,1,0,0) ),
    /* TEST 39 */ (/*IN*/ (1, 1, 0, 2) , /*OUT*/(2,2,0,0) ),
    /* TEST 40 */ (/*IN*/ (1, 1, 1, 0) , /*OUT*/(2,1,0,0) ),
    /* TEST 41 */ (/*IN*/ (1, 1, 1, 1) , /*OUT*/(2,2,0,0) ),
    /* TEST 42 */ (/*IN*/ (1, 1, 1, 2) , /*OUT*/(2,1,2,0) ),
    /* TEST 43 */ (/*IN*/ (1, 1, 2, 0) , /*OUT*/(2,2,0,0) ),
    /* TEST 44 */ (/*IN*/ (1, 1, 2, 1) , /*OUT*/(2,2,1,0) ),
    /* TEST 45 */ (/*IN*/ (1, 1, 2, 2) , /*OUT*/(2,4,0,0) ),
    /* TEST 46 */ (/*IN*/ (1, 2, 0, 0) , /*OUT*/(1,2,0,0) ),
    /* TEST 47 */ (/*IN*/ (1, 2, 0, 1) , /*OUT*/(1,2,1,0) ),
    /* TEST 48 */ (/*IN*/ (1, 2, 0, 2) , /*OUT*/(1,4,0,0) ),
    /* TEST 49 */ (/*IN*/ (1, 2, 1, 0) , /*OUT*/(1,2,1,0) ),
    /* TEST 50 */ (/*IN*/ (1, 2, 1, 1) , /*OUT*/(1,2,2,0) ),
    /* TEST 51 */ (/*IN*/ (1, 2, 1, 2) , /*OUT*/(1,2,1,2) ),
    /* TEST 52 */ (/*IN*/ (1, 2, 2, 0) , /*OUT*/(1,4,0,0) ),
    /* TEST 53 */ (/*IN*/ (1, 2, 2, 1) , /*OUT*/(1,4,1,0) ),
    /* TEST 54 */ (/*IN*/ (1, 2, 2, 2) , /*OUT*/(1,4,2,0) ),

    /* TEST 55 */ (/*IN*/ (2, 0, 0, 0) , /*OUT*/(2,0,0,0) ),
    /* TEST 56 */ (/*IN*/ (2, 0, 0, 1) , /*OUT*/(2,1,0,0) ),
    /* TEST 57 */ (/*IN*/ (2, 0, 0, 2) , /*OUT*/(4,0,0,0) ),
    /* TEST 58 */ (/*IN*/ (2, 0, 1, 0) , /*OUT*/(2,1,0,0) ),
    /* TEST 59 */ (/*IN*/ (2, 0, 1, 1) , /*OUT*/(2,2,0,0) ),
    /* TEST 60 */ (/*IN*/ (2, 0, 1, 2) , /*OUT*/(2,1,2,0) ),
    /* TEST 61 */ (/*IN*/ (2, 0, 2, 0) , /*OUT*/(4,0,0,0) ),
    /* TEST 62 */ (/*IN*/ (2, 0, 2, 1) , /*OUT*/(4,1,0,0) ),
    /* TEST 63 */ (/*IN*/ (2, 0, 2, 2) , /*OUT*/(4,2,0,0) ),
    /* TEST 64 */ (/*IN*/ (2, 1, 0, 0) , /*OUT*/(2,1,0,0) ),
    /* TEST 65 */ (/*IN*/ (2, 1, 0, 1) , /*OUT*/(2,2,0,0) ),
    /* TEST 66 */ (/*IN*/ (2, 1, 0, 2) , /*OUT*/(2,1,2,0) ),
    /* TEST 67 */ (/*IN*/ (2, 1, 1, 0) , /*OUT*/(2,2,0,0) ),
    /* TEST 68 */ (/*IN*/ (2, 1, 1, 1) , /*OUT*/(2,2,1,0) ),
    /* TEST 69 */ (/*IN*/ (2, 1, 1, 2) , /*OUT*/(2,2,2,0) ),
    /* TEST 70 */ (/*IN*/ (2, 1, 2, 0) , /*OUT*/(2,1,2,0) ),
    /* TEST 71 */ (/*IN*/ (2, 1, 2, 1) , /*OUT*/(2,1,2,1) ),
    /* TEST 72 */ (/*IN*/ (2, 1, 2, 2) , /*OUT*/(2,1,4,0) ),
    /* TEST 73 */ (/*IN*/ (2, 2, 0, 0) , /*OUT*/(4,0,0,0) ),
    /* TEST 74 */ (/*IN*/ (2, 2, 0, 1) , /*OUT*/(4,1,0,0) ),
    /* TEST 75 */ (/*IN*/ (2, 2, 0, 2) , /*OUT*/(4,2,0,0) ),
    /* TEST 76 */ (/*IN*/ (2, 2, 1, 0) , /*OUT*/(4,1,0,0) ),
    /* TEST 77 */ (/*IN*/ (2, 2, 1, 1) , /*OUT*/(4,2,0,0) ),
    /* TEST 78 */ (/*IN*/ (2, 2, 1, 2) , /*OUT*/(4,1,2,0) ),
    /* TEST 79 */ (/*IN*/ (2, 2, 2, 0) , /*OUT*/(4,2,0,0) ),
    /* TEST 80 */ (/*IN*/ (2, 2, 2, 1) , /*OUT*/(4,2,1,0) ),
    /* TEST 81 */ (/*IN*/ (2, 2, 2, 2) , /*OUT*/(4,4,0,0) )
    ]

    var i : U32 = 0
    for (rin, rout) in rows.values() do
      i = i + 1
      var out = RowCmp(Merger(rin))
      var expect : RowCmp   = RowCmp(rout)
      h.assert_eq[RowCmp](expect, out, "@TEST#" + i.string())
    end

// fun apply(h: TestHelper) =>
    // var out : ROW box
    // out = Merger((0,0,0,0))
    // var dat : ROW  box= (0,0,0,0)
    // h.assert_eq[ROW  box](out, dat) 
