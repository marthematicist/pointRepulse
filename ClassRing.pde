
class Ring{
  PVector X;  // center
  int N;      // number
  float r;
  float minR;
  float maxR;
  
  // constructor
  Ring( int num ) {
    this.N = num;
    this.r = 0;
    this.X = new PVector( xRes / 2 , yRes / 2 );
    this.minR = 50;
    this.maxR = float(yRes) / 2.0;
  }
  
  void grow( float dr ) {
    this.r += dr;
    if( this.r > this.maxR ) {
      this.r = this.minR;
    }
    if( this.r < this.minR ) {
      this.r = this.maxR;
    } 
  }
  
  
  
  
}
