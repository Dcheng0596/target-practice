/* The idea was to create growing and shrinking circles that the player can
 * click on. To gameify this idea I simply kept track of the number of circles
 * they are able to click. There is no winning condition but the goal is to get
 * a high score. The losing condition is when a circle shrinks to nothing. 
 * The two elements of fun that I included was Challenge and Submission with 
 * a hint of Sensation. The Challenge fun was implemented by having the game 
 * increase with difficulty as time goes on by icnreaseing the rate the circles spawn
 * and the speed they grow and shrink. This makes it easy at the start for any player
 * but skill testing for good players and the game goes on. Competition comes from 
 * competing for a higher score showing who has better hand eye coordination with
 * a mouse .Submission fun is because of the fairly mindless task of clicking on
 * circles but is also pleasurable in a visual sense because of the numerous circles
 * constantly changing in size and each one having an unique color.
 */
 
ArrayList<ClrEllipse> gArry; // List of ellipses that are growing
ArrayList<ClrEllipse> sArry; // List of ellipses that are shrinking

int maxSpawnRate; // The fastest ellipses can spawn
int spawnRate;    // The default spawn rate
int spawnROC;     // The rate at which the spawn rate increases

int oldTime;      // Time that has passed since last spawn
int newTime;      // Current time
int deltaTime;    // Difference between old and new time

int score;

float radLimit;   // Maximum raduis an ellipse can grow

float maxGFactor; // The fastest ellipses can grow and shrink
float gFactor;    // The default growth rate
float gFactorROC; // The rate at which the growth rate increases

color bgClr;

boolean gamestart;
boolean gameover;

void setup()
{
  
  size(720, 480);
  bgClr = color(255, 255, 255);
  background(bgClr);
  
  ellipseMode(RADIUS);
  gameover = false;
  gamestart = true;
  
  gArry = new ArrayList<ClrEllipse>();
  sArry = new ArrayList<ClrEllipse>();
  
  radLimit = 20;
  
  spawnRate = 1000;
  maxSpawnRate = 550;
  spawnROC = 8;
  
  gFactor = .1; 
  maxGFactor = .2;
  gFactorROC =.002;
  
  oldTime = 0;
  deltaTime = spawnRate;
  
  score = 0;
}

void draw()
{
  if(gamestart)
     startScreen();
  else {
    spawner();
 
    background(bgClr);
 
    grow();
    shrink();
    if(gameover)
       gameOverScreen();
  }
}

// Checks whether the mouse click was within any of the current ellipses 
// and removes it from the corresponding list if so and increases the score
void mousePressed()
{
  if(gameover)
    return;
    
  for(int i = gArry.size() - 1; i >= 0; i--)
  {
    ClrEllipse e = gArry.get(i);
    if(dist(mouseX, mouseY, e.p.x, e.p.y) <= e.radius)
    {
      gArry.remove(i);
      score +=1;
    }
  }
  
  for(int i = sArry.size() - 1; i >= 0; i--)
  {
    ClrEllipse e = sArry.get(i);
    if(dist(mouseX, mouseY, e.p.x, e.p.y) <= e.radius)
    {
      sArry.remove(i);
      score += 1;
    }
  }
}

void startScreen()
{
  fill(0, 0 ,0);
  textSize(70);
  textAlign(CENTER, CENTER);
  text("Target Practice", width/2, height/4);

  ClrEllipse e = new ClrEllipse(color(0, 255, 0), 360, 302, 60);
  e.draw();
     
  fill(0, 0 ,0);
  textSize(30);
  text("START", width/2, height/1.61);
  if(mousePressed && dist(mouseX, mouseY, e.p.x, e.p.y) <= e.radius) 
       gamestart = false;;
}
// Displays the gameover screen with the score and an option to restart the game
void gameOverScreen()
{
  maxSpawnRate = 10;
  radLimit = random(30, 300);
  
  fill(255, 0 ,0);
  textSize(70);
  textAlign(CENTER, CENTER);
  text("Game Over", width/2, height/4);
  
  fill(0, 0 ,0);
  textSize(50);
  text("Score <" + score + ">" , width/2, height/2.7);
 
  ClrEllipse e = new ClrEllipse(color(0, 255, 0), 360, 302, 60);
  e.draw();
     
  fill(0, 0 ,0);
  textSize(30);
  text("RETRY", width/2, height/1.61);
     
  // Checks if the retry button was pressed
  if(mousePressed && dist(mouseX, mouseY, e.p.x, e.p.y) <= e.radius) 
       setup();
  gamestart = false;
}

// Adds ellipses to the growing array with radius 1 according to the spawn rate
// and growth factor and exponentialy increases them according to the spawn ROC
// and growth factor ROC untill the maximum spawn rate and growth factor is reached
void spawner()
{
  newTime = millis();             // Set up the spawn rate
  deltaTime = newTime - oldTime;
  
  if(deltaTime >= spawnRate)       
  {
    gArry.add(createEllipse(1));
    oldTime = newTime; 
    if(spawnRate - spawnROC >= maxSpawnRate)
      spawnRate -= spawnROC;
    if(gFactor + gFactorROC <= maxGFactor)
    gFactor += gFactorROC;
  }
}

// Creates an ellipse with a random color and position with radius "rad"
ClrEllipse createEllipse(float rad)
{
  color clr = color(random(256), random(256), random(256));
  float radius = rad;
  float x = random(radLimit, width - radLimit);
  float y = random(radLimit, height - radLimit);
  
  ClrEllipse e = new ClrEllipse(clr, x, y, radius);
  
  return e;
}

// Increases the size of all ellipses in the growth list by the growth factor 
// and removes an ellipse once it reaches the raduis limit and adds it to
// the shrink list
void grow()
{
  for(int i = gArry.size() - 1; i >= 0; i--)
  {
    ClrEllipse e = gArry.get(i);
    if(e.radius + gFactor <= radLimit)
      e.grow(gFactor);
    else
    {
      sArry.add(e);
      gArry.remove(i);
    }
    e.draw();
  }
}

// Decreases the size of all ellipses in the shrink list by the growth factor 
// and removes an ellipse once it reaches a radius of 0
// If an ellipse is removed then the gameover flag is set to true
void shrink()
{
  for(int i = sArry.size() - 1; i >= 0; i--)
  {
    ClrEllipse e = sArry.get(i);
    if(e.radius - gFactor >= 0)
      e.shrink(gFactor);
    else
    {
      sArry.remove(i);
      gameover = true;
    }
    e.draw();
  }
}

class Point
{
  float x;
  float y;
  
  Point(float x0, float y0)
  {
    x = x0;
    y = y0;
  }
}

//Colored ellipse class
class ClrEllipse
{
  color clr;
  Point p;
  float radius;
  
  ClrEllipse(color clrx, float px, float py, float rad)
  {
    clr = clrx;
    p = new Point(px, py);
    radius = rad;
  }
  
  void grow(float amount)
  {
    radius += amount;
  }
  
  void shrink(float amount)
  {
    if(radius - amount >= 0)
      radius -= amount;
    else
      radius = 0;
  }
  
  void draw()
  {
    fill(clr);
    ellipse(p.x, p.y, radius, radius);
    noFill();
  }
}
