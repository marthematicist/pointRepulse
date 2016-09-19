int xRes = 600;
int yRes = 400;

float distThreshold = 200;
float fadeThreshold = 150;

float lineR = 255;
float lineG = 255;
float lineB = 255;
float lineAlpha = 255;
color lineColor = color( lineR , lineG , lineB , lineAlpha );

float dt = 1.0 / ( 40 * 5 );

float xMin = 0;
float xMax = float(xRes);
float yMin = 0;
float yMax = float(yRes);
float edgeWidth = xMax * 0.1;
float edgeSpringConstant = 50000;
float frictionConstant = 1;
//7751

int numDots = 100;
int numClusters = 0;
int maxNumClusters = 1;
int minClusters = 1;
float maxClusterRadius = 0.1 * yMax;

float minVel = 0;
float maxVel = 0;

float universalConstant = 250;
float epsilon = 10;

int frameCounter = 0;
Boolean savingPDF = false;
Boolean generateNew = false;

