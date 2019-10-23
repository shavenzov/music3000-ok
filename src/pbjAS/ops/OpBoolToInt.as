package pbjAS.ops
{
  import pbjAS.regs.PBJReg;
  
  public class OpBoolToInt implements PBJOpcode
  {
     public var dst:PBJReg;
     public var src:PBJReg;
     
     public function OpBoolToInt(dst:PBJReg, src:PBJReg)
     {
       this.dst = dst;
       this.src = src;
     }
  }
}