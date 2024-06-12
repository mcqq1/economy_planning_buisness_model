{string} INDUSTRIES = ...;

int MAX_YEARS = ...;
range Years = 1..MAX_YEARS;

float INPUT_OUTPUT[INDUSTRIES][INDUSTRIES] = ...;
float INPUT_CAPACITY[INDUSTRIES][INDUSTRIES] = ...;
float EX_DEMAND[INDUSTRIES] = ...;
float MANPOWER_OUTPUT[INDUSTRIES] = ...;
float MANPOWER_CAPACITY[INDUSTRIES] = ...;
float MANPOWER_LIMIT = ...;
float INIT_CAPACITY[INDUSTRIES] = ...;
float INIT_STOCK[INDUSTRIES] = ...;
float INPUT_STATIC[INDUSTRIES] = ...;
int  OBJ1 = 1;
int  OBJ2 = 1;
int  OBJ3 = 1;

range R = 1..MAX_YEARS+2;
range R1= 0..MAX_YEARS;

dvar float+ output[i in INDUSTRIES][y in R];
dvar float+ stock[i in INDUSTRIES][y in R];
dvar float+ addcap[INDUSTRIES][R];
dvar float+ cap[INDUSTRIES][Years];
dvar float+ manpower_used[R1];


maximize
  OBJ1 * (sum(i in INDUSTRIES) cap[i][MAX_YEARS]) +
  OBJ2 * (sum(i in INDUSTRIES, y in 4..5) output[i][y]) +  
  OBJ3 * (sum(y in Years) manpower_used[y]);

subject to {
  // Year 0
  forall(i in INDUSTRIES){
    sum(j in INDUSTRIES) INPUT_OUTPUT[i][j] * output[j][1]
      + sum(j in INDUSTRIES) INPUT_CAPACITY[i][j] * addcap[j][2]
        <= INIT_STOCK[i] - stock[i][1];
    output[i][1]<=INIT_CAPACITY[i];
  };

  // Total output
  forall(i in INDUSTRIES, y in Years)
    sum(j in INDUSTRIES) INPUT_OUTPUT[i][j] * output[j][y+1]
      + sum(j in INDUSTRIES) INPUT_CAPACITY[i][j] * addcap[j][y+2]
        <= output[i][y] + stock[i][y] - stock[i][y+1] - EX_DEMAND[i] * (1-OBJ2);

  // Manpower
  forall(y in 0..MAX_YEARS)
    sum(j in INDUSTRIES) MANPOWER_OUTPUT[j] * output[j][y+1]
      + sum(j in INDUSTRIES) MANPOWER_CAPACITY[j] * addcap[j][y+2] 
        == manpower_used[y];
         
  if ( OBJ3 < 1 ) {
    forall(y in 0..MAX_YEARS)
       manpower_used[y] <= MANPOWER_LIMIT;
  };

  // Productive capacity
  forall(i in INDUSTRIES, y in Years) {
    cap[i][y] == INIT_CAPACITY[i] + sum(k in Years: k <= y) addcap[i][k]; 
    output[i][y] <= cap[i][y]; 
  };
   

  // Initial stocks
  forall(i in INDUSTRIES) {     
    addcap[i][1] == 0.0;
  }; 
  
  // Horizon conditions
  forall(i in INDUSTRIES) {
    output[i][MAX_YEARS+1] >= INPUT_STATIC[i];
    output[i][MAX_YEARS+2] >= INPUT_STATIC[i];
    addcap[i][MAX_YEARS+1] == 0.00;
    addcap[i][MAX_YEARS+2] == 0.0;
  };

};


tuple capSolutionT{ 
	string INDUSTRIES; 
	int Years; 
	float value; 
};
{capSolutionT} capSolution = {<i0,i1,cap[i0][i1]> | i0 in INDUSTRIES,i1 in Years};
tuple outputSolutionT{ 
	string INDUSTRIES; 
	int R; 
	float value; 
};
{outputSolutionT} outputSolution = {<i0,i1,output[i0][i1]> | i0 in INDUSTRIES,i1 in R};
tuple manpower_usedSolutionT{ 
	int R1; 
	float value; 
};
{manpower_usedSolutionT} manpower_usedSolution = {<i0,manpower_used[i0]> | i0 in R1};
tuple addcapSolutionT{ 
	string INDUSTRIES; 
	int R; 
	float value; 
};
{addcapSolutionT} addcapSolution = {<i0,i1,addcap[i0][i1]> | i0 in INDUSTRIES,i1 in R};
tuple stockSolutionT{ 
	string INDUSTRIES; 
	int R; 
	float value; 
};
{stockSolutionT} stockSolution = {<i0,i1,stock[i0][i1]> | i0 in INDUSTRIES,i1 in R};
