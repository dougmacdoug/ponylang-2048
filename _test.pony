use "ponytest"

actor TestMain is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestMerge)
//    test(_TestSub)

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
  fun name():String => "Merge"

// TODO: revisit
//cant seem to get this working with tuples
  fun apply(h: TestHelper) =>
    let rows : Array[(ROW, ROW)] = [
     /* TEST 1 */ (/*IN*/( 0,0,0,0 ), /*OUT*/(0,0,0,0) ),
     /* TEST 2 */ (/*IN*/( 0,0,0,1 ), /*OUT*/(1,0,0,0) ),
     /* TEST 3 */ (/*IN*/( 0,0,1,0 ), /*OUT*/(1,0,0,0) ),
     /* TEST 4 */ (/*IN*/( 0,1,0,0 ), /*OUT*/(1,0,0,0) ),
     /* TEST 5 */ (/*IN*/( 1,0,0,0 ), /*OUT*/(1,0,0,0) ),

     /* TEST 6 */ (/*IN*/( 0,0,1,1 ), /*OUT*/(2,0,0,0) ),
     /* TEST 7 */ (/*IN*/( 0,1,0,1 ), /*OUT*/(2,0,0,0) ),
     /* TEST 8 */ (/*IN*/( 1,0,0,1 ), /*OUT*/(2,0,0,0) ),

     /* TEST 9 */ (/*IN*/( 0,1,1,0 ), /*OUT*/(2,0,0,0) ),
     /* TEST 10*/ (/*IN*/( 1,0,1,0 ), /*OUT*/(2,0,0,0) ),
     /* TEST 11*/ (/*IN*/( 1,1,0,0 ), /*OUT*/(2,0,0,0) ),

     /* TEST 12*/ (/*IN*/( 1,1,1,1 ), /*OUT*/(2,2,0,0) ),
     /* TEST 13*/ (/*IN*/( 1,1,1,0 ), /*OUT*/(2,1,0,0) ),
     /* TEST 14*/ (/*IN*/( 1,1,0,1 ), /*OUT*/(2,1,0,0) )

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
