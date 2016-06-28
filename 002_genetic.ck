SinOsc s;
Pan2 p;
JCRev r;
0.05 => s.gain;
-1.0 => p.pan;
0.03 => r.mix;

SinOsc s2;
Pan2  p2;
JCRev r2;
1.0 => p2.pan;
0.05 => s2.gain;
0.03 => r2.mix;
s => r => p => dac;
s2 => r2 => p2 => dac;

// esta es la melodía que el sistema debe alcanzar
[ 64, 66, 68, 71, 73] @=> int goal[];

// se inicializan los arreglos
int seq[5];
int sequence[goal.cap()];
int sequence2[goal.cap()];

// se crean secuencias aleatorias
for( 0 => int i; i < goal.cap()-1; i++)
  {
    Math.random2(10, 127) =>  sequence[i];
    Math.random2(10, 127) =>  sequence2[i];
  }

// una función para probabilidad
function int intChance( int percent, int value1, int value2)
{
    int percentArray[100];
    for( 0 => int i; i < 100; i++)
        {
            if( i < percent ) value1 => percentArray[i];
            if( i >= percent ) value2 => percentArray[i];
        }
    percentArray[Math.random2(0, percentArray.cap()-1)] => int selected;
    return selected;
}

// funciones para mutar los arreglos aleatorios
function int mutate(){
    goal[Math.random2(0, sequence.cap()-1)] =>  sequence[Math.random2(0, goal.cap()-1)];
}
function int mutate2(){
    goal[Math.random2(0, sequence2.cap()-1)] =>  sequence2[Math.random2(0, goal.cap()-1)];
}

// evalua que tan distante esta de la meta
function void evaluate()
{
  while(true)
    {
      for( 0 => int i; i < goal.cap()-1; i++)
        {
          if(sequence[i] == goal[i])
            {
              <<< "melodía 1: encontró ",  goal[i]>>>;
            }
          if( sequence2[i] == goal[i])
            {
              <<< "melodía 2: encontró ",  goal[i]>>>;
            }
          500::ms => now;
        }
    }
 
}

// suena las secuencias
function void playSequence (int sequence[]){
    while (true){
        for( 0 => int i; i < (sequence.cap()-1); i++){
            Std.mtof(sequence[i]) => s.freq;
            122::ms => now;
        }
        intChance(30, 1, 0) => int chance;
        if(chance == 1)
            {
                mutate();
                <<< "muta 1">>>;
            }
    }
}

function void playSequence2 (int seq2[]){
    while (true){
        for( 0 => int i; i < (sequence2.cap()-1); i++){
            Std.mtof(seq2[i])  => s2.freq;
            100::ms => now;
        }
        intChance(10, 1, 0) => int chance;
        if(chance == 1)
            {
                mutate2();
                <<< "muta 2">>>;
            }
    }
}

spork~ evaluate();
spork~  playSequence(sequence);
spork~  playSequence2(sequence2);
while(true){ 10::ms => now;}
