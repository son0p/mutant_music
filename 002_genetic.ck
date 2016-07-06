// dos melodías intentan alcanzar una melodía de referencia
// a través de mutaciones a melodías aleatorias

// Tempo
333.33::ms => dur tick;
tick * 4 => dur beat;
16 => int loopSize;
int loop4;
0 => int metro;

// esta es la melodía de referencia 
[ 64, 66, 68, 71, 73] @=> int goal[];

// se inicializan los arreglos
int seq[5];
int sequence[goal.cap()];
int sequence2[goal.cap()];

4 => int C; // numero de melodías
Osc s[C];
Pan2 p[C];
ADSR e[C];
JCRev r[C];
Gain master;

// se crean los generadores de sonido
// TODO: no repetir código, crearlos con un for
fun void melodies(float octave, int d, Osc Osc)
{
  for( 0 => int i; i < C; i++ )
    {
      s[i] => e[i] => r[i] => master => p[i] => dac;
      ( 0.02::second, 0.01::second, (1.0/C), 0.6::second ) => e[i].set;
      r[i].mix(0.09);
      s[i].gain(0.3/C);
      for( 0 => int ii; ii < goal.cap()-1; ii++)
        {
          createRandomNote() =>  sequence[ii];
          createRandomNote() =>  sequence2[ii];
        }
    }
  while(true){
    // for ( 0 => int ii ; ii < C ; ++ii ) { e[ii].keyOn(); }
    // e[loop4].keyOn();
    // tick/d => now;

    for ( 0 => int ii ; ii < C ; ++ii ) { e[ii].keyOff(); Math.random2f(-0.5, 0.5) => p[ii].pan; }
    // e[loop4].keyOff();
    // tick/d => now;

    for( 0 => int i; i < (sequence.cap()-1); i++)
      {
        e[i].keyOn();
        Std.mtof(sequence[i]) => s[i].freq;
        d::ms => now;
      }
    intChance(30, 1, 0) => int chance;
    if(chance == 1)
      {
        mutate();
        <<< "muta melodía derecha", " => \n">>>;
      }
  }
}

// se crean secuencias aleatorias
// TODO: encontrar mejor solución
function int createRandomNote()
{
  Math.random2(10, 127) => int note;
  return note;
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
// TODO: una sola función debería poder hacer eso
// TODO: la base de la mutación debe adaptarse a un nuevo arreglo que 
//       ya contiene las notas encontradas
function int mutate()
{
  goal[Math.random2(0, sequence.cap()-1)] =>  sequence[Math.random2(0, goal.cap()-1)];
}
function int mutate2()
{
  goal[Math.random2(0, sequence2.cap()-1)] =>  sequence2[Math.random2(0, goal.cap()-1)];
}

// evalua que tan distante esta de la meta
// TODO: dejar fijas las notas que ya fueron encontradas
// TODO: en un solo if debería poder evaluarse ambas secuencias
// TODO: es feo evaluar cada x milisegundos, esto debería ser
//       comandado por eventos
function void evaluate()
{
  while(true)
    {
      for( 0 => int i; i < goal.cap()-1; i++)
        {
          if(sequence[i] == goal[i])
            {
              <<< "           melodía derecha: ** encontró **  ",  goal[i], "\n" >>>;
            }
          if( sequence2[i] == goal[i])
            {
              <<< "           melodía izquierda: ** encontró ** ",  goal[i], "\n" >>>;
            }
          500::ms => now;
        }
    }
}

SinOsc myOsc;

// llama las funciones
spork~  melodies(1.0, 100, myOsc );
//spork~ evaluate();

// mantiene vivos los spork
while(true){ 10::ms => now;}
