import processing.pdf.*;

Dots d;



void setup() {
  size( xRes , yRes );
  numClusters = floor( random( minClusters , maxNumClusters ) );
  println( "number of clusters:" + numClusters );
  maxClusterRadius = sqrt( pow( maxClusterRadius*0.5 , 2.0 ) / float(numClusters) );
  d = new Dots(  );
  d.evolveHalfStep();
  background( 0 , 0 , 0 , 255 );
}

void draw() {
  if( savingPDF ){ 
    beginRecord( PDF, nf(month(),2) + "_" + nf(day(),2) + "_" + nf(hour(),2) + "_" + nf(minute(),2) + "_" + nf(second(),2) + ".pdf" );
  }
  background( 0 , 0 , 0 , 255 );
  fill( 255 );
  //strokeWeight(2);
  d.evolveFullStep(5);
  //d.drawDots();
  d.drawDistances(  );
  if( savingPDF ) {
    endRecord();
    savingPDF = false;
  }
  //save( "images/frame" + nf(frameCount,6) + ".png");
  frameCounter++;
  println( frameCounter );
  if( frameCounter == 200 ) {
    frictionConstant = 0.00;
  }
  if( frictionConstant == 0 ) {
    println( "low friction!" );
  }
  if( generateNew ) {
    generateNew = false;
    numClusters = floor( random( minClusters , maxNumClusters ) );
    println( "number of clusters:" + numClusters );
    maxClusterRadius = sqrt( pow( yMax*0.25 , 2.0 ) / float(numClusters) );
    d = new Dots(  );
    //exit();
  }
}

void keyPressed()
{
  if (key == 'p') {
    savingPDF = true;
  }
  if (key == 'g') {
    generateNew = true;
  }
}
  
