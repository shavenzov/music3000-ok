package pbjAS.ops
{
  import pbjAS.regs.PBJReg;
  
  public class OpIntToFloat implements PBJOpcode
  {
     public var dst:PBJReg;
     public var src:PBJReg;
     
     public function OpIntToFloat(dst:PBJReg, src:PBJReg)
     {
       this.dst = dst;
       this.src = src;
     }
  }
}