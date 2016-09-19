
class Dots{
  int N;  // number of dots
  PVector[] X;  // positions
  PVector[] V;  // velocities
  PVector[] A;  // accelerations
  float[] M;    // masses
  float[] D;    // distances
  
  // constructor
  Dots(  ) {
    int dotsPerCluster = numDots / numClusters;
    int num = dotsPerCluster * numClusters;
    this.N = num;
    this.X = new PVector[num];
    this.V = new PVector[num];
    this.A = new PVector[num];
    this.M = new float[num];
    this.D = new float[num*num];

    for( int j = 0 ; j < numClusters ; j++ ) {
      float centerX = random( xMin , xMax );
      float centerY = random( yMin , yMax );
      for( int i = j*dotsPerCluster ; i < (j+1)*dotsPerCluster ; i++ ) {
        Boolean validLocation = false;
        while( !validLocation ) {
          this.X[i] = PVector.random2D();
          this.X[i].mult( random( 0 , maxClusterRadius ) );
          this.X[i].add( new PVector( centerX , centerY ) );
          float x = this.X[i].x;
          float y = this.X[i].y;
          if( x > xMin && x < xMax && y > yMin && y < yMax ) {
            validLocation = true;
          }
        }
        //this.X[i] = new PVector( random( float(xRes) * 0.25  , float(xRes) * 0.75 ) , random( float(yRes) * 0.25  , float(yRes) * 0.75 ) );
        this.V[i] = PVector.random2D();
        this.V[i].mult( random( minVel , maxVel ) );
        this.A[i] = new PVector( 0 , 0 );
        //this.M[i] = 80;
        this.M[i] = (abs(randomGaussian())+0.001 ) * 50;
      }
    }
  }
  
  void updateDistances() {
    for( int i = 0 ; i < this.N - 1 ; i++ ) {
      for( int j = i ; j < this.N ; j++ ) {
        float d = this.X[i].dist( this.X[j] ); 
        this.D[i*this.N + j] = d; 
        this.D[j*this.N + 1] = d;
      }
    }
  }
  
  float getDist( int i , int j ) {
    float d = this.D[i*this.N + j];
    return d;
  }
  
  void zeroAccelerations() {
    for( int i = 0 ; i < this.N ; i++ ) {
      this.A[i] = new PVector( 0 , 0 );
    }
  }
  
  void applyFrictionForces() {
    for( int i = 0 ; i < this.N ; i++ ) {
      PVector dA = new PVector( this.V[i].x , this.V[i].y );
      dA.mult( -frictionConstant );
      this.A[i].add( dA );
    }
  }
    
  
  void applyMutualForces() {
    for( int i = 0 ; i < this.N - 1 ; i++ ) {
      for( int j = i + 1 ; j < this.N ; j++ ) {
        float d = this.getDist( i , j );
        float f = universalConstant / pow( d * d + epsilon * epsilon , 1.5 );
        PVector dAi = PVector.sub( this.X[i] , this.X[j] );
        dAi.normalize();
        PVector dAj = new PVector( dAi.x , dAi.y );
        dAi.mult( f * this.M[j] );
        dAj.mult( -f * this.M[i] );
        this.A[i].add( dAi );
        this.A[j].add( dAj ); 
      }
    }
  }
  
  void applyEdgeForces() {
    for( int i = 0 ; i < this.N ; i++ ) {
      float x = this.X[i].x;
      float y = this.X[i].y;
      float m = this.M[i];
      if( x < 0 ) {

          float f = edgeSpringConstant * -x;
          PVector dA = new PVector( f / m , 0 );
          this.A[i].add( dA );

      }
      if( y < 0 ) {

          float f = edgeSpringConstant * ( -y );
          PVector dA = new PVector( 0, f / m );
          this.A[i].add( dA );
 
      }
      if( x > xMax ) {

          float f = edgeSpringConstant * ( x - ( xMax ) );
          PVector dA = new PVector( -f / m , 0 );
          this.A[i].add( dA );
  
      }
      if( y > yMax ) {

          float f = edgeSpringConstant * ( y - ( yMax ) );
          PVector dA = new PVector( 0 , -f / m );
          this.A[i].add( dA );
      }
    }
  }
  
  void evolveHalfStep() {
    this.zeroAccelerations();
    this.updateDistances();
    this.applyMutualForces();
    this.applyEdgeForces();
    this.applyFrictionForces();
    for( int i = 0 ; i < this.N ; i++ ) {
      
      this.V[i].add( PVector.mult( this.A[i] , dt / 2 ) );
    }
  }
  
  void evolveFullStep( int num ) {
    for( int n = 0 ; n < num ; n++ ) {
      for( int i = 0 ; i < this.N ; i++ ) {
        this.X[i].add( PVector.mult( this.V[i] , dt ) );
      }
      this.zeroAccelerations();
      this.updateDistances();
      this.applyMutualForces();
      this.applyEdgeForces();
      this.applyFrictionForces();
      for( int i = 0 ; i < this.N ; i++ ) {
        this.V[i].add( PVector.mult( this.A[i] , dt ) );
      }
    }
  }
      
  void drawDots() {
    for( int i = 0 ; i < this.N ; i++ ) {
      float x = this.X[i].x;
      float y = this.X[i].y;
      point( x , y );
      
    }
  }
  
  void drawDistances(  ) {
    for( int i = 0 ; i < this.N - 1 ; i++ ) {
      for( int j = i + 1 ; j < this.N ; j++ ) {
        float d = getDist( i , j );
        if( d < distThreshold ) {
          float x1 = this.X[i].x;
          float y1 = this.X[i].y;
          float x2 = this.X[j].x;
          float y2 = this.X[j].y;
          if( d > distThreshold - fadeThreshold ) {
            float fadeAlpha = lineAlpha * (distThreshold - d) / fadeThreshold;
            lineColor = color( lineR , lineG , lineB , fadeAlpha );
          } else {
            lineColor = color( lineR , lineG , lineB , lineAlpha );
          }
          stroke( lineColor );
          line( x1 , y1 , x2 , y2 );          
        }
      }
    }
  }
  
}
      
