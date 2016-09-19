var setupGlobalVariables = function() {
  xRes = 400;
  yRes = 400;
  minRes = min( xRes , yRes );
  maxRes = max( xRes , yRes );
  
  distThreshold = 200;
  fadeThreshold = 150;
  
  lineR = 255;
  lineG = 255;
  lineB = 255;
  lineAlpha = 255;
  lineColor = color( lineR , lineG , lineB , lineAlpha );
  
  dt = 1.0 / ( 40 * 5 );
  
  xMin = 0;
  xMax = xRes;
  yMin = 0;
  yMax = yRes;
  edgeWidth = xMax * 0.1;
  edgeSpringConstant = 50000;
  frictionConstant = 1;

  numDots = 10;
  
  minVel = 0;
  maxVel = 2;
  
  avgMass = 50;

  universalConstant = 250;
  epsilon = 10;

  frameCounter = 0;
  generateNew = false;
}


class Dots{
  // constructor
  constructor( N ) {
    this.N = N;
    this.X = new Array( this.N );
    this.V = new Array( this.N );
    this.A = new Array( this.N );
    this.M = new Array( this.N );
    var nSquared = this.N*this.N;
    this.D = new Array(  );
    
    for( var i = 0 ; i < this.N ; i++ ) {
      this.X.push( createVector( random(xMin,xMax) , random(yMin , yMax) ) );
      this.V.push( p5.Vector.random2D() );
      this.V[i].mult( random(minVel,maxVel) );
      this.A.push( createVector( 0 , 0 ) );
      this.M.push( avgMass );
    }
  }
}
    
    
    
    /*
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
    */
  
Dots.prototype.updateDistances = function() {
  for( var i = 0 ; i < this.N - 1 ; i++ ) {
    for( var j = i ; j < this.N ; j++ ) {
      var d = this.X[i].dist( this.X[j] ); 
      this.D[i*this.N + j] = d; 
      this.D[j*this.N + 1] = d;
    }
  }
}

Dots.prototype.getDist = function( i , j ) {
  var d = this.D[i*this.N + j];
  return d;
}
  
Dots.prototype.zeroAccelerations = function() {
  for( var i = 0 ; i < this.N ; i++ ) {
    this.A[i] = createVector( 0 , 0 );
  }
}
  
  Dots.prototype.applyFrictionForces = function() {
    for( var i = 0 ; i < this.N ; i++ ) {
      dA = createVector( this.V[i].x , this.V[i].y );
      dA.mult( -frictionConstant );
      this.A[i].add( dA );
    }
  }
    
  Dots.prototype.applyMutualForces = function() {
    for( var i = 0 ; i < this.N - 1 ; i++ ) {
      for( var j = i + 1 ; j < this.N ; j++ ) {
        var d = this.getDist( i , j );
        var f = universalConstant / pow( d * d + epsilon * epsilon , 1.5 );
        var dAi = p5.Vector.sub( this.X[i] , this.X[j] );
        dAi.normalize();
        var dAj = createVector( dAi.x , dAi.y );
        dAi.mult( f * this.M[j] );
        dAj.mult( -f * this.M[i] );
        this.A[i].add( dAi );
        this.A[j].add( dAj ); 
      }
    }
  }
  
  Dots.prototype.applyEdgeForces = function() {
    for( var i = 0 ; i < this.N ; i++ ) {
      var x = this.X[i].x;
      var y = this.X[i].y;
      var m = this.M[i];
      if( x < 0 ) {
          var f = edgeSpringConstant * -x;
          var dA = createVector( f / m , 0 );
          this.A[i].add( dA );
      }
      if( y < 0 ) {
          var f = edgeSpringConstant * ( -y );
          var dA = createVector( 0, f / m );
          this.A[i].add( dA );
      }
      if( x > xMax ) {
          var f = edgeSpringConstant * ( x - ( xMax ) );
          var dA = createVector( -f / m , 0 );
          this.A[i].add( dA );
      }
      if( y > yMax ) {
          var f = edgeSpringConstant * ( y - ( yMax ) );
          var dA = createVector( 0 , -f / m );
          this.A[i].add( dA );
      }
    }
  }
  
  Dots.prototype.evolveHalfStep = function() {
    this.zeroAccelerations();
    this.updateDistances();
    this.applyMutualForces();
    this.applyEdgeForces();
    this.applyFrictionForces();
    for( var i = 0 ; i < this.N ; i++ ) {
      
      this.V[i].add( p5.Vector.mult( this.A[i] , dt / 2 ) );
    }
  }
  
  Dots.prototype.evolveFullStep = function( num ) {
    for( var n = 0 ; n < num ; n++ ) {
      for( var i = 0 ; i < this.N ; i++ ) {
        this.X[i].add( p5.Vector.mult( this.V[i] , dt ) );
      }
      this.zeroAccelerations();
      this.updateDistances();
      this.applyMutualForces();
      this.applyEdgeForces();
      this.applyFrictionForces();
      for( var i = 0 ; i < this.N ; i++ ) {
        this.V[i].add( p5.Vector.mult( this.A[i] , dt ) );
      }
    }
  }
      
  Dots.prototype.drawDots = function() {
    for( var i = 0 ; i < this.N ; i++ ) {
      var x = this.X[i].x;
      var y = this.X[i].y;
      ellipse( x , y , 10 , 10 );
      console.log(x , y);
      
    }
  }
  
  Dots.prototype.drawDistances = function(  ) {
    for( var i = 0 ; i < this.N - 1 ; i++ ) {
      for( var j = i + 1 ; j < this.N ; j++ ) {
        var d = getDist( i , j );
        if( d < distThreshold ) {
          var x1 = this.X[i].x;
          var y1 = this.X[i].y;
          var x2 = this.X[j].x;
          var y2 = this.X[j].y;
          if( d > distThreshold - fadeThreshold ) {
            var fadeAlpha = lineAlpha * (distThreshold - d) / fadeThreshold;
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



setup = function() {
  console.log( 'Setting up global variables...' );
  setupGlobalVariables();
  createCanvas( xRes , yRes );
  console.log( 'setting up Dots object' );
  d = new Dots(  );
  console.log( 'evolving half step');
  d.evolveHalfStep();
  background( 0 , 0 , 0 , 255 );
}

draw = function() {
  //console.log( 'draw function: setting upt canvas' );
  background( 0 , 0 , 0 , 255 );
  fill( 255 , 255 , 255 , 255 );
  noStroke();
  //strokeWeight(2);
  //console.log( 'draw function: evolving full step' );
  d.evolveFullStep(5);
  
  console.log( 'drawing dots' );
  d.drawDots();
  //d.drawDistances(  );

  frameCounter++;
  
  /*
  if( frameCounter == 200 ) {
    frictionConstant = 0.00;
  }
  if( frictionConstant == 0 ) {
    println( "low friction!" );
  }
  
  if( generateNew ) {
    generateNew = false;
    d = new Dots(  );
    //exit();
  }
  */
}
