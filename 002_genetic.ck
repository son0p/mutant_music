// dos melodías intentan alcanzar una melodía de referencia
// a través de mutaciones a melodías aleatorias

// Tempo
33::ms => dur tick;
tick * 4 => dur beat;
16 => int loopSize;
int loop4;
0 => int metro;

// esta es la  base de posibilidades
[ 64, 66, 68, 71, 73] @=> int base[];

// esta es la secuencia de referencia 
[ 68, 66, 64, 71, 73] @=> int goal[];

2 => int C; // numero de melodías BUG:: se desborda el array si son mas de goal
int melodyNumber;
Osc s[C];
Pan2 p[C];
ADSR e[C];
JCRev r[C];
Gain master;

// se inicializan los arreglos
int sequence[C][goal.cap()];

// se llenan los arrays con notas aleatorias
for (0 => int i; i < C; i++)
{
  for( 0 => int ii; ii < goal.cap(); ii++)
  {
    createRandomNote() => sequence[i][ii];
    <<< sequence[i][ii] >>>;
  }  
}


// se crean los generadores de sonido
fun void melodies(float octave, int d, Osc Osc)
{
  for( 0 => int i; i < C; i++ )
  {
    s[i] => e[i] => r[i] => master => p[i] => dac;
    ( 0.03::second, 0.01::second, (1.0/C), 0.01::second ) => e[i].set;
    r[i].mix(0.09);
    s[i].gain(0.3/C);
    e[i].keyOff();
  }
}

// se crean secuencias aleatorias
// TODO: encontrar mejor solución
function int createRandomNote()
{
  Math.random2(10, 127) => int note;
  return note;
}

// se recorren las secuencias
function void playSequences(int sequenceToPlay)
{
  while(true)
  {
    // TODO: dividir el panorama en el número de melodías con la función
    //       para cambio de rango.
    Math.random2f(-1.0, 1.0) => p[sequenceToPlay].pan;

    for( 0 => int i; i < sequence[sequenceToPlay].cap(); i++ )
      {
        e[sequenceToPlay].keyOn();
        Std.mtof(sequence[sequenceToPlay][i]) => s[sequenceToPlay].freq;
        beat => now;
        e[sequenceToPlay].keyOff();
      }
    2*beat => now; // silencio para diferenciar la melodía

    // según una probabilidad, genera una mutación en una nota
    intChance(50, 1, 0) => int chance;
    if(chance == 1)
      {
        mutate();
      }

    // revisa si lo logró comparando los arrays
    // TODO: esto no esta funcionando bien, reporta antes de estar completas
    for( 0 => int i; i < C; i++ )
    {
      for( 0 => int ii; ii < sequence.cap(); ii++ )
      {
        if( sequence[i][ii] == goal[ii] )
        {
          <<< "Secuencia ", i, " completa " >>>;
        }
      }
    }
  }
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

// funcion para mutar los arreglos aleatorios
// TODO: la base de la mutación debe adaptarse a un nuevo arreglo que
//       ya contiene las notas encontradas
function int mutate()
{
  Math.random2(0, C-1) => int seqToMutate;
  Math.random2(0, base.cap()-1) => int noteToMutate;
  // se evalua si la nota existente es igual a la melodía de referencia,
  if(sequence[seqToMutate][noteToMutate] == goal[noteToMutate])
  {
    <<< ": ** encontró coincidencia**  ",  goal[noteToMutate], "\n" >>>;
  }
  else
  {
    base[Math.random2(0, base.cap()-1)] => sequence[seqToMutate][noteToMutate];
    <<< "muta melodía ",seqToMutate,"\n">>>;
  }
}

// ---------- 
SinOsc myOsc;

// inicializa los osciladores
spork~  melodies(1.0, 200, myOsc);

// ejecuta y suena las secuencias
for( 0 => int i; i < C; i++)
{
  spork~ playSequences(i);
}

// mantiene vivos los spork
while(true){ 10::ms => now;}
